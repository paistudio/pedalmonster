import { reactive } from 'vue'
import { comments as seedComments, currentUser, addPoints, users } from '../mocks'

// A "comment" is a Post row with type='comment' and parent_id set — see
// docs/02-data-model.md's unified Post entity. This store manages that slice.
const state = reactive({
  comments: [...seedComments],
  likedByMe: new Set(),
})

// Pulls @username tokens out of a comment's description and resolves them against
// known users, so a mention only "counts" if it matches a real account.
function extractMentionedUserIds(description) {
  const handles = description.match(/@([a-zA-Z0-9._]+)/g) || []
  const usernames = new Set(handles.map((h) => h.slice(1).toLowerCase()))
  return users.filter((u) => usernames.has(u.username.toLowerCase())).map((u) => u.id)
}

export function useCommentStore() {
  function getCommentsForPost(parentId) {
    return state.comments
      .filter((comment) => comment.parent_id === parentId)
      .sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
  }

  function commentCountFor(parentId) {
    return state.comments.filter((comment) => comment.parent_id === parentId).length
  }

  function hasLiked(commentId) {
    return state.likedByMe.has(commentId)
  }

  function toggleLike(comment) {
    if (state.likedByMe.has(comment.id)) {
      state.likedByMe.delete(comment.id)
      comment.like_count -= 1
      if (comment.user_id === currentUser.id) addPoints(-1)
    } else {
      state.likedByMe.add(comment.id)
      comment.like_count += 1
      if (comment.user_id === currentUser.id) addPoints(1)
    }
  }

  function addComment(post, description, media_urls = []) {
    const text = description.trim()
    if (!text && !media_urls.length) return
    const comment = {
      id: `a-${Date.now()}`,
      type: 'comment',
      parent_id: post.id,
      user_id: currentUser.id,
      description: text,
      media_urls,
      mentioned_user_ids: extractMentionedUserIds(text),
      like_count: 0,
      created_at: new Date().toISOString(),
      type_data: {},
    }
    state.comments.push(comment)
    addPoints(3)
    return comment
  }

  function isOwnComment(comment) {
    return comment.user_id === currentUser.id
  }

  function editComment(comment, description) {
    const text = description.trim()
    if (!text) return
    comment.description = text
    comment.mentioned_user_ids = extractMentionedUserIds(text)
  }

  function deleteComment(comment) {
    const idx = state.comments.findIndex((c) => c.id === comment.id)
    if (idx !== -1) state.comments.splice(idx, 1)
  }

  // Called when a post is deleted, so its comments (Post rows with parent_id
  // pointing at it) don't linger orphaned.
  function removeCommentsForPost(parentId) {
    for (let i = state.comments.length - 1; i >= 0; i -= 1) {
      if (state.comments[i].parent_id === parentId) state.comments.splice(i, 1)
    }
  }

  return {
    getCommentsForPost,
    commentCountFor,
    hasLiked,
    toggleLike,
    addComment,
    isOwnComment,
    editComment,
    deleteComment,
    removeCommentsForPost,
  }
}
