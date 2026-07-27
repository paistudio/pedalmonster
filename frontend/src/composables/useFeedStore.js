import { reactive } from 'vue'
import { getFeed, currentUser, incomingPost } from '../mocks'
import { useGroupStore } from './useGroupStore'
import { useCommentStore } from './useCommentStore'

const state = reactive({
  posts: getFeed(),
  incomingDelivered: false,
})

export function useFeedStore() {
  // Group membership lives in useGroupStore (single source of truth); these
  // stay as pass-throughs so PostCard and the creation flow keep one store API.
  const groupStore = useGroupStore()
  const isGroupJoined = groupStore.isJoined
  const toggleGroupMembership = groupStore.toggleMembership

  async function refresh() {
    await new Promise((resolve) => setTimeout(resolve, 700))
    if (!state.incomingDelivered) {
      state.posts.unshift({ ...incomingPost, author: currentUser })
      state.incomingDelivered = true
    }
  }

  function createPost(draft) {
    const post = {
      id: `p-${Date.now()}`,
      user_id: currentUser.id,
      parent_id: null,
      created_at: new Date().toISOString(),
      author: currentUser,
      like_count: 0,
      ...draft,
    }
    state.posts.unshift(post)
    return post
  }

  function markSold(post) {
    post.type_data.status = 'sold'
  }

  function isPostOwner(post) {
    return post?.user_id === currentUser.id
  }

  // Owner-only: edits description/photos of an existing post in place.
  function updatePost(post, { description, media_urls } = {}) {
    if (description != null) post.description = description.trim()
    if (media_urls != null) post.media_urls = media_urls
  }

  // Owner-only: removes the post and every comment left on it.
  function deletePost(postId) {
    const idx = state.posts.findIndex((p) => p.id === postId)
    if (idx === -1) return
    state.posts.splice(idx, 1)
    useCommentStore().removeCommentsForPost(postId)
  }

  // Called when a group owner deletes their group, so its posts don't linger in the feed.
  function removeGroupPosts(groupId) {
    for (let i = state.posts.length - 1; i >= 0; i -= 1) {
      const post = state.posts[i]
      if (post.type === 'group_post' && post.type_data.group_id === groupId) {
        state.posts.splice(i, 1)
      }
    }
  }

  return {
    posts: state.posts,
    isGroupJoined,
    toggleGroupMembership,
    refresh,
    createPost,
    markSold,
    isPostOwner,
    updatePost,
    deletePost,
    removeGroupPosts,
  }
}
