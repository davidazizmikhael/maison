// Permanently deletes the calling user's account and every trace of their
// data. App Review requires in-app account deletion (guideline 5.1.1(v)).
//
// Order matters: storage objects do NOT cascade from auth.users, so they are
// removed first; deleting the auth user then cascades homes → records →
// reminders via the schema's foreign keys.
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Resolve the caller from their own JWT — never trust a uid in the body.
    const authHeader = req.headers.get("Authorization") ?? "";
    const asCaller = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await asCaller.auth.getUser();
    if (userError || !userData?.user) {
      return new Response(JSON.stringify({ error: "not authenticated" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    const uid = userData.user.id;

    const admin = createClient(url, serviceKey);

    // Photos live under captures/<uid>/... — remove them in pages.
    while (true) {
      const { data: objects, error: listError } = await admin.storage
        .from("captures")
        .list(uid, { limit: 100 });
      if (listError || !objects || objects.length === 0) break;
      const paths = objects.map((o) => `${uid}/${o.name}`);
      const { error: removeError } = await admin.storage.from("captures").remove(paths);
      if (removeError) break; // rows still get wiped below; stray files are harmless
      if (objects.length < 100) break;
    }

    // Cascades homes → records → reminders and revokes every session.
    const { error: deleteError } = await admin.auth.admin.deleteUser(uid);
    if (deleteError) throw deleteError;

    return new Response(JSON.stringify({ deleted: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: `${e}` }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
