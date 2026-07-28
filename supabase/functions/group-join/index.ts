// Joins a group, silently no-oping (not erroring) if the caller is on the group's
// blocked_user_ids list — this exact "no-op, not an error" UX (docs/10-groups.md's
// Moderation: "the join action silently no-ops for a blocked user rather than erroring") is
// awkward to express as a plain RLS policy alone, since a blocked insert attempt would
// normally surface as a policy-violation error to the client. See
// docs/19-supabase-only-backend-plan.md.
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    const callerId = ctx.userClaims!.id;
    const { group_id } = (await req.json()) as { group_id?: string };

    if (!group_id) {
      return Response.json({ error: "group_id is required" }, { status: 400 });
    }

    const { data: group, error: groupError } = await ctx.supabase
      .from("groups")
      .select("id, blocked_user_ids, member_count")
      .eq("id", group_id)
      .maybeSingle();

    if (groupError) {
      return Response.json({ error: groupError.message }, { status: 400 });
    }
    if (!group) {
      return Response.json({ error: "Group not found" }, { status: 404 });
    }

    if ((group.blocked_user_ids ?? []).includes(callerId)) {
      return Response.json({ member_count: group.member_count, joined: false });
    }

    // ignoreDuplicates makes a repeat join idempotent (matches the Rails plan's
    // find_or_create_by behavior) — the unique index on (group_id, user_id) backs this.
    const { error: joinError } = await ctx.supabase
      .from("group_memberships")
      .upsert(
        { group_id, user_id: callerId },
        { onConflict: "group_id,user_id", ignoreDuplicates: true },
      );

    if (joinError) {
      return Response.json({ error: joinError.message }, { status: 400 });
    }

    const { data: updatedGroup } = await ctx.supabase
      .from("groups")
      .select("member_count")
      .eq("id", group_id)
      .single();

    return Response.json({ member_count: updatedGroup?.member_count ?? group.member_count, joined: true });
  }),
};
