// Finds-or-creates the canonical chat thread for (caller, other_user_id) — sorted so the same
// two people always land in the same thread regardless of who initiates — then inserts the
// message. Same logic as the superseded Rails plan's ChatThread.between, see
// docs/19-supabase-only-backend-plan.md. Uses the caller's own RLS-scoped client throughout;
// the existing chat_threads/chat_messages policies already allow a participant to do this, so
// no admin/service-role escalation is needed.
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

interface Payload {
  other_user_id: string;
  body?: string;
  media_urls?: string[];
}

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    const callerId = ctx.userClaims!.id;
    const { other_user_id, body, media_urls } = (await req.json()) as Payload;

    if (!other_user_id) {
      return Response.json({ error: "other_user_id is required" }, { status: 400 });
    }
    const trimmedBody = body?.trim() || null;
    if (!trimmedBody && !(media_urls && media_urls.length)) {
      return Response.json({ error: "body or media_urls is required" }, { status: 400 });
    }

    const [userOneId, userTwoId] = [callerId, other_user_id].sort();

    const { data: existingThread, error: findError } = await ctx.supabase
      .from("chat_threads")
      .select("id")
      .eq("user_one_id", userOneId)
      .eq("user_two_id", userTwoId)
      .maybeSingle();

    if (findError) {
      return Response.json({ error: findError.message }, { status: 400 });
    }

    let threadId: string | undefined = existingThread?.id;
    if (!threadId) {
      const { data: newThread, error: createError } = await ctx.supabase
        .from("chat_threads")
        .insert({ user_one_id: userOneId, user_two_id: userTwoId })
        .select("id")
        .single();

      if (createError) {
        return Response.json({ error: createError.message }, { status: 400 });
      }
      threadId = newThread.id;
    }

    const { data: message, error: messageError } = await ctx.supabase
      .from("chat_messages")
      .insert({
        chat_thread_id: threadId,
        sender_id: callerId,
        type: "text",
        body: trimmedBody,
        media_urls: media_urls ?? [],
      })
      .select()
      .single();

    if (messageError) {
      return Response.json({ error: messageError.message }, { status: 400 });
    }

    return Response.json(message, { status: 201 });
  }),
};
