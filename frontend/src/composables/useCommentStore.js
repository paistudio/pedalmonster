import { reactive } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuth } from './useAuth'

// A "comment" is a Post row with type='comment' and parent_id set — see
// docs/02-data-model.md's unified Post entity. This store manages that slice.
// mentioned_user_ids and like_count/comment_count are maintained by DB triggers now, not
// client-side logic — see docs/19-supabase-only-backend-plan.md.
const state = reactive({
  commentsByPost: {},
  likedByMe: new Set(),
})

const { state: authState } = useAuth()

async function attachAuthors(comments) {
  const userIds = [...new Set(comments.map((c) => c.user_id))]
  if (!userIds.length) return comments
  const { data: authors } = await supabase.from('profiles').select('*').in('id', userIds)
  const authorsById = Object.fromEntries((authors || []).map((a) => [a.id, a]))
  return comments.map((c) => ({ ...c, author: authorsById[c.user_id] }))
}

export function useCommentStore() {
  function getCommentsForPost(parentId) {
    return state.commentsByPost[parentId] || []
  }

  async function loadComments(parentId) {
    const { data, error } = await supabase
      .from('posts')
      .select('*')
      .eq('parent_id', parentId)
      .eq('type', 'comment')
      .order('created_at', { ascending: true })
    if (error) return
    state.commentsByPost[parentId] = await attachAuthors(data)

    if (authState.currentUser && data.length) {
      const { data: likes } = await supabase
        .from('post_likes')
        .select('post_id')
        .eq('user_id', authState.currentUser.id)
        .in('post_id', data.map((c) => c.id))
      likes?.forEach((like) => state.likedByMe.add(like.post_id))
    }
  }

  function commentCountFor(parentId) {
    return getCommentsForPost(parentId).length
  }

  function hasLiked(commentId) {
    return state.likedByMe.has(commentId)
  }

  async function toggleLike(comment) {
    if (!authState.currentUser) return
    const userId = authState.currentUser.id
    if (state.likedByMe.has(comment.id)) {
      const { error } = await supabase
        .from('post_likes')
        .delete()
        .eq('post_id', comment.id)
        .eq('user_id', userId)
      if (error) return
      state.likedByMe.delete(comment.id)
      comment.like_count -= 1
    } else {
      const { error } = await supabase.from('post_likes').insert({ post_id: comment.id, user_id: userId })
      if (error) return
      state.likedByMe.add(comment.id)
      comment.like_count += 1
    }
  }

  async function addComment(post, description, media_urls = []) {
    const text = description.trim()
    if (!text && !media_urls.length) return

    const { data, error } = await supabase
      .from('posts')
      .insert({
        user_id: authState.currentUser.id,
        type: 'comment',
        parent_id: post.id,
        description: text,
        media_urls,
      })
      .select()
      .single()
    if (error) return

    const comment = { ...data, author: authState.currentUser }
    if (!state.commentsByPost[post.id]) state.commentsByPost[post.id] = []
    state.commentsByPost[post.id].push(comment)
    post.comment_count = (post.comment_count || 0) + 1
    return comment
  }

  function isOwnComment(comment) {
    return comment.user_id === authState.currentUser?.id
  }

  async function editComment(comment, description) {
    const text = description.trim()
    if (!text) return
    const { error } = await supabase.from('posts').update({ description: text }).eq('id', comment.id)
    if (error) return
    comment.description = text
  }

  // Cascade to the parent's comment_count is handled by the DB trigger; this just deletes
  // the row and syncs local reactive state.
  async function deleteComment(comment) {
    const { error } = await supabase.from('posts').delete().eq('id', comment.id)
    if (error) return
    const list = state.commentsByPost[comment.parent_id]
    if (list) {
      const idx = list.findIndex((c) => c.id === comment.id)
      if (idx !== -1) list.splice(idx, 1)
    }
  }

  return {
    getCommentsForPost,
    loadComments,
    commentCountFor,
    hasLiked,
    toggleLike,
    addComment,
    isOwnComment,
    editComment,
    deleteComment,
  }
}
