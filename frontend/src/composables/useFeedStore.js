import { reactive } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuth } from './useAuth'
import { useGroupStore } from './useGroupStore'

const state = reactive({
  posts: [],
  loaded: false,
})

const { state: authState } = useAuth()

// Attaches each post's author profile — a plain second query + client-side merge rather
// than a PostgREST embed, so the exact FK relationship name never matters.
async function attachAuthors(posts) {
  const userIds = [...new Set(posts.map((p) => p.user_id))]
  if (!userIds.length) return posts
  const { data: authors } = await supabase.from('profiles').select('*').in('id', userIds)
  const authorsById = Object.fromEntries((authors || []).map((a) => [a.id, a]))
  return posts.map((p) => ({ ...p, author: authorsById[p.user_id] }))
}

async function loadFeed() {
  const { data, error } = await supabase
    .from('posts')
    .select('*')
    .neq('type', 'comment')
    .order('created_at', { ascending: false })
  if (error) return
  const withAuthors = await attachAuthors(data)
  // Mutate in place, don't reassign — useFeedStore() returns `posts: state.posts` as a plain
  // value, captured once per call. Reassigning state.posts would leave every component that
  // already called useFeedStore() (before this async load resolves) holding a stale reference
  // that never updates. Splicing keeps everyone pointed at the same reactive array.
  state.posts.splice(0, state.posts.length, ...withAuthors)
  state.loaded = true
}

let loadPromise = null
function ensureLoaded() {
  if (!loadPromise) loadPromise = loadFeed()
  return loadPromise
}

export function useFeedStore() {
  ensureLoaded()

  // Group membership lives in useGroupStore (single source of truth); these
  // stay as pass-throughs so PostCard and the creation flow keep one store API.
  const groupStore = useGroupStore()
  const isGroupJoined = groupStore.isJoined
  const toggleGroupMembership = groupStore.toggleMembership

  async function refresh() {
    await loadFeed()
  }

  async function createPost(draft) {
    const { data, error } = await supabase
      .from('posts')
      .insert({
        user_id: authState.currentUser.id,
        type: draft.type,
        title: draft.title ?? null,
        description: draft.description ?? '',
        media_urls: draft.media_urls ?? [],
        tags: draft.tags ?? [],
        location: draft.location ?? null,
        location_city_id: draft.location_city_id ?? null,
        type_data: draft.type_data ?? {},
      })
      .select()
      .single()
    if (error) throw error
    const post = { ...data, author: authState.currentUser }
    state.posts.unshift(post)
    return post
  }

  async function markSold(post) {
    const nextTypeData = { ...post.type_data, status: 'sold' }
    const { error } = await supabase.from('posts').update({ type_data: nextTypeData }).eq('id', post.id)
    if (!error) post.type_data = nextTypeData
  }

  function isPostOwner(post) {
    return post?.user_id === authState.currentUser?.id
  }

  // Owner-only: edits description/photos of an existing post in place.
  async function updatePost(post, { description, media_urls } = {}) {
    const patch = {}
    if (description != null) patch.description = description.trim()
    if (media_urls != null) patch.media_urls = media_urls
    if (!Object.keys(patch).length) return
    const { error } = await supabase.from('posts').update(patch).eq('id', post.id)
    if (!error) Object.assign(post, patch)
  }

  // Owner-only: removes the post. Comments cascade automatically via the DB's
  // ON DELETE CASCADE on posts.parent_id — no separate cleanup call needed.
  async function deletePost(postId) {
    const { error } = await supabase.from('posts').delete().eq('id', postId)
    if (error) return
    const idx = state.posts.findIndex((p) => p.id === postId)
    if (idx !== -1) state.posts.splice(idx, 1)
  }

  // Called after a group owner deletes their group (DB-cascaded already) so the
  // local reactive feed state matches without a full reload.
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
