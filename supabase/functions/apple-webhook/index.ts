/// <reference lib="deno.ns" />
/// <reference lib="dom" />

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const jsonHeaders = {
  "content-type": "application/json",
  "cache-control": "no-store",
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function base64UrlToString(input: string): string {
  const normalized = input.replace(/-/g, "+").replace(/_/g, "/");
  const padLen = (4 - (normalized.length % 4)) % 4;
  const padded = normalized + "=".repeat(padLen);
  const bytes = Uint8Array.from(atob(padded), (c) => c.charCodeAt(0));
  return new TextDecoder().decode(bytes);
}

function decodeJwtPayload<T = Record<string, unknown>>(jwt: string): T {
  const parts = jwt.split(".");
  if (parts.length < 2) {
    throw new Error("Invalid JWT");
  }
  const json = base64UrlToString(parts[1]);
  return JSON.parse(json) as T;
}

function parseMillisToIso(millis?: number | string | null): string | null {
  if (millis === null || millis === undefined) return null;
  const n = typeof millis === "string" ? Number(millis) : millis;
  if (!Number.isFinite(n)) return null;
  return new Date(n).toISOString();
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: { ...corsHeaders } });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ ok: false, error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, ...jsonHeaders },
    });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const signedPayload = body?.signedPayload;
    if (!signedPayload || typeof signedPayload !== "string") {
      return new Response(JSON.stringify({ ok: false, error: "Missing signedPayload" }), {
        status: 400,
        headers: { ...corsHeaders, ...jsonHeaders },
      });
    }

    const payload = decodeJwtPayload<Record<string, unknown>>(signedPayload);
    const notificationType = String(payload["notificationType"] ?? "unknown");
    const notificationTypeUpper = notificationType.toUpperCase();
    const subtype = payload["subtype"] ? String(payload["subtype"]) : null;
    const data = (payload["data"] as Record<string, unknown> | undefined) ?? undefined;

    const signedTransactionInfo = data?.["signedTransactionInfo"];
    const signedRenewalInfo = data?.["signedRenewalInfo"];

    let transaction: Record<string, unknown> | null = null;
    let renewal: Record<string, unknown> | null = null;

    if (typeof signedTransactionInfo === "string") {
      transaction = decodeJwtPayload<Record<string, unknown>>(signedTransactionInfo);
    }

    if (typeof signedRenewalInfo === "string") {
      renewal = decodeJwtPayload<Record<string, unknown>>(signedRenewalInfo);
    }

    const originalTransactionId =
      (transaction?.["originalTransactionId"] as string | undefined) ??
      (transaction?.["original_transaction_id"] as string | undefined) ??
      null;

    const transactionId =
      (transaction?.["transactionId"] as string | undefined) ??
      (transaction?.["transaction_id"] as string | undefined) ??
      null;

    const productId =
      (transaction?.["productId"] as string | undefined) ??
      (transaction?.["product_id"] as string | undefined) ??
      null;

    const expiresDateMs =
      (transaction?.["expiresDate"] as number | string | undefined) ??
      (transaction?.["expiresDateMs"] as number | string | undefined) ??
      (transaction?.["expires_date_ms"] as number | string | undefined) ??
      null;

    const purchaseDateMs =
      (transaction?.["purchaseDate"] as number | string | undefined) ??
      (transaction?.["purchaseDateMs"] as number | string | undefined) ??
      (transaction?.["purchase_date_ms"] as number | string | undefined) ??
      null;

    const environment = (payload["environment"] as string | undefined) ??
      (transaction?.["environment"] as string | undefined) ??
      null;

    const isSandbox = environment === "Sandbox" ? true : environment === "Production" ? false : null;

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(JSON.stringify({ ok: false, error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY" }), {
        status: 500,
        headers: { ...corsHeaders, ...jsonHeaders },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    if (!originalTransactionId) {
      return new Response(JSON.stringify({ ok: true, handled: false, reason: "missing_original_transaction_id" }), {
        status: 200,
        headers: { ...corsHeaders, ...jsonHeaders },
      });
    }

    const { data: existing, error: findError } = await supabase
      .from("subscriptions")
      .select("id,user_id,status")
      .eq("original_transaction_id", originalTransactionId)
      .limit(1)
      .maybeSingle();

    if (findError) {
      return new Response(JSON.stringify({ ok: false, error: "db_lookup_failed" }), {
        status: 500,
        headers: { ...corsHeaders, ...jsonHeaders },
      });
    }

    if (!existing) {
      return new Response(JSON.stringify({ ok: true, handled: false, reason: "subscription_not_found" }), {
        status: 200,
        headers: { ...corsHeaders, ...jsonHeaders },
      });
    }

    const now = Date.now();
    const expiresIso = parseMillisToIso(expiresDateMs);
    const purchaseIso = parseMillisToIso(purchaseDateMs);

    const expiresMsNum = expiresDateMs === null ? null : Number(expiresDateMs);
    const isActiveByExpiry = expiresMsNum !== null && Number.isFinite(expiresMsNum) && expiresMsNum > now;

    let newStatus = existing.status as string;

    if (notificationTypeUpper === "REFUND") {
      newStatus = "refunded";
    } else if (notificationTypeUpper === "REVOKE") {
      newStatus = "canceled";
    } else if (notificationTypeUpper === "EXPIRED" || notificationTypeUpper === "GRACE_PERIOD_EXPIRED") {
      newStatus = "expired";
    } else if (notificationTypeUpper === "DID_FAIL_TO_RENEW") {
      newStatus = isActiveByExpiry ? "grace_period" : "expired";
    } else if (isActiveByExpiry) {
      newStatus = "active";
    } else {
      newStatus = "expired";
    }

    const updatePayload: Record<string, unknown> = {
      status: newStatus,
      updated_at: new Date().toISOString(),
    };

    if (productId) updatePayload.product_id = productId;
    if (transactionId) updatePayload.latest_transaction_id = transactionId;
    if (expiresIso) updatePayload.expires_at = expiresIso;
    if (purchaseIso) updatePayload.purchase_date = purchaseIso;
    if (isSandbox !== null) updatePayload.sandbox = isSandbox;

    if (notificationTypeUpper === "DID_FAIL_TO_RENEW") {
      updatePayload.billing_issue = true;
    }

    const { error: updateError } = await supabase
      .from("subscriptions")
      .update(updatePayload)
      .eq("id", existing.id);

    if (updateError) {
      return new Response(JSON.stringify({ ok: false, error: "db_update_failed" }), {
        status: 500,
        headers: { ...corsHeaders, ...jsonHeaders },
      });
    }

    await supabase.from("subscription_events").insert({
      id: crypto.randomUUID(),
      subscription_id: existing.id,
      user_id: existing.user_id,
      event_type: notificationType.toLowerCase(),
      platform: "ios",
      product_id: productId,
      transaction_id: transactionId,
      details: {
        subtype,
        environment,
        payload,
        transaction,
        renewal,
      },
    });

    return new Response(JSON.stringify({ ok: true, handled: true }), {
      status: 200,
      headers: { ...corsHeaders, ...jsonHeaders },
    });
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, error: e instanceof Error ? e.message : String(e) }), {
      status: 500,
      headers: { ...corsHeaders, ...jsonHeaders },
    });
  }
});
