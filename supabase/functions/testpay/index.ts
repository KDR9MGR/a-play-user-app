// ============================================================
// PASTE THIS INTO:
// Supabase Dashboard → Edge Functions → testpay → Code tab
// then click "Deploy"
//
// No auth wrapper — testpay uses ONLY the Paystack TEST secret key
// (sandbox credentials, zero real charges possible).
// Application-level auth (session checks in the UI) already ensures
// only logged-in users reach the payment screen.
//
// Required secret: PAYSTACK_TEST_SECRET_KEY = sk_test_...
// ============================================================

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }

  try {
    const secretKey = Deno.env.get("PAYSTACK_TEST_SECRET_KEY");
    if (!secretKey) {
      return Response.json(
        { status: false, message: "PAYSTACK_TEST_SECRET_KEY secret is not set in Supabase Secrets" },
        { status: 500, headers: CORS },
      );
    }

    const body = await req.json();
    const { email, amount, currency = "GHS", reference, metadata } = body;

    // ── Verify an existing payment ────────────────────────────────────────
    if (reference && !email) {
      const res = await fetch(
        `https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`,
        { headers: { Authorization: `Bearer ${secretKey}` } },
      );
      const data = await res.json();
      return Response.json(data, { status: res.ok ? 200 : res.status, headers: CORS });
    }

    // ── Initialize a new payment ──────────────────────────────────────────
    if (!email || !amount) {
      return Response.json(
        { status: false, message: "email and amount are required to initialize a payment" },
        { status: 400, headers: CORS },
      );
    }

    const payload: Record<string, unknown> = { email, amount, currency };
    if (reference) payload.reference = reference;
    if (metadata)  payload.metadata  = metadata;

    const res = await fetch("https://api.paystack.co/transaction/initialize", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${secretKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const data = await res.json();
    return Response.json(data, { status: res.ok ? 200 : res.status, headers: CORS });

  } catch (err) {
    return Response.json(
      { status: false, message: String(err) },
      { status: 500, headers: CORS },
    );
  }
});
