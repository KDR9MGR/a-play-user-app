/// <reference lib="deno.ns" />
// Supabase Edge Function: delete-account
//
// Permanently deletes the CALLING user's account (Apple App Store
// Guideline 5.1.1(v) requires in-app account deletion to actually delete
// the account). The user is identified strictly from their JWT - there is
// no userId parameter, so a user can only ever delete themselves.
//
// Flow:
//   1. Validate the caller's JWT and resolve their user id.
//   2. prepare_user_deletion(uid) RPC (service role): removes/nulls the
//      rows whose NO ACTION foreign keys would otherwise block deletion.
//   3. auth.admin.deleteUser(uid): removes the auth user; ON DELETE CASCADE
//      takes care of profiles and everything cascading from it.

import { createClient } from "npm:@supabase/supabase-js@2";

const jsonHeaders = { "content-type": "application/json" };

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: jsonHeaders,
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // Resolve the caller from their JWT
  const authHeader = req.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace(/^Bearer\s+/i, "");
  if (!jwt) {
    return new Response(JSON.stringify({ error: "Missing authorization" }), {
      status: 401,
      headers: jsonHeaders,
    });
  }

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const { data: userData, error: userError } = await admin.auth.getUser(jwt);
  if (userError || !userData?.user) {
    return new Response(JSON.stringify({ error: "Invalid or expired session" }), {
      status: 401,
      headers: jsonHeaders,
    });
  }

  const userId = userData.user.id;
  console.log(`delete-account: deleting user ${userId}`);

  try {
    const { error: prepError } = await admin.rpc("prepare_user_deletion", {
      p_user_id: userId,
    });
    if (prepError) {
      console.error(`prepare_user_deletion failed: ${prepError.message}`);
      return new Response(
        JSON.stringify({ error: `Data cleanup failed: ${prepError.message}` }),
        { status: 500, headers: jsonHeaders },
      );
    }

    const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
    if (deleteError) {
      console.error(`auth.admin.deleteUser failed: ${deleteError.message}`);
      return new Response(
        JSON.stringify({ error: `Account deletion failed: ${deleteError.message}` }),
        { status: 500, headers: jsonHeaders },
      );
    }

    console.log(`delete-account: user ${userId} deleted`);
    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: jsonHeaders,
    });
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    console.error(`delete-account error: ${message}`);
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: jsonHeaders,
    });
  }
});
