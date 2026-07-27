// Comments are Post rows with type='comment' and parent_id set — see docs/02-data-model.md's
// unified Post entity. Kept in their own seed file purely for readability; the shape matches Post.
export const comments = [
  {
    id: 'a1',
    type: 'comment',
    parent_id: 'p7',
    user_id: 'u1',
    description: "Try the Vittoria Mezcal — great for light trail riding and holds up well. About 450k per tire.",
    media_urls: [],
    mentioned_user_ids: [],
    like_count: 4,
    created_at: '2026-07-22T04:00:00Z',
    type_data: {},
  },
  {
    id: 'a2',
    type: 'comment',
    parent_id: 'p7',
    user_id: 'u8',
    description: "Maxxis Ikon is also solid if it's more for commuting — decent grip for light wet conditions.",
    media_urls: [],
    mentioned_user_ids: [],
    like_count: 1,
    created_at: '2026-07-22T06:30:00Z',
    type_data: {},
  },
  {
    id: 'a3',
    type: 'comment',
    parent_id: 'p8',
    user_id: 'u8',
    description: "Try re-bleeding the brake fluid — there's probably air trapped in the caliper.",
    media_urls: [],
    mentioned_user_ids: [],
    like_count: 2,
    created_at: '2026-07-23T09:00:00Z',
    type_data: {},
  },
]

export function getCommentsForPost(parentId) {
  return comments.filter((comment) => comment.parent_id === parentId)
}
