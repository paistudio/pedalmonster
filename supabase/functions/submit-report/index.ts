// Validates the "description required unless post_id is set" rule from
// docs/02-data-model.md's Report entity before inserting. reports has no select RLS policy
// (write-only from the client, see docs/19-supabase-only-backend-plan.md), so this returns a
// plain success status rather than the inserted row.
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const CATEGORIES = ["bug", "content", "spam", "harassment", "account", "other"];

interface Payload {
  category?: string;
  description?: string;
  post_id?: string;
}

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    const callerId = ctx.userClaims!.id;
    const { category, description, post_id } = (await req.json()) as Payload;

    if (!category || !CATEGORIES.includes(category)) {
      return Response.json({ error: `category must be one of: ${CATEGORIES.join(", ")}` }, { status: 400 });
    }
    if (!post_id && !description?.trim()) {
      return Response.json({ error: "description is required unless post_id is set" }, { status: 400 });
    }

    const { error } = await ctx.supabase.from("reports").insert({
      user_id: callerId,
      category,
      description: description?.trim() || null,
      post_id: post_id ?? null,
    });

    if (error) {
      return Response.json({ error: error.message }, { status: 400 });
    }

    return Response.json({ status: "submitted" }, { status: 201 });
  }),
};
