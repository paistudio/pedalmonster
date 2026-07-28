import { reactive } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuth } from './useAuth'

const state = reactive({
  drawerOpen: false,
  inboxOpen: false,
  unreadInbox: false,
  followedTags: [],
  followedTagsLoaded: false,
  likedPostIds: [],
  likedLoaded: false,
  inboxTabs: ['notifications', 'chat'],
  activeInboxTab: 'notifications',
  notifications: [],
  notificationsLoaded: false,
  chats: [],
  chatsLoaded: false,
})

const { state: authState } = useAuth()

// Loads once per login — which posts the current user has already liked, so isPostLiked
// works without a network round trip per post.
let likedLoadPromise = null
function ensureLikedLoaded() {
  if (!authState.currentUser || state.likedLoaded) return Promise.resolve()
  if (!likedLoadPromise) {
    likedLoadPromise = supabase
      .from('post_likes')
      .select('post_id')
      .eq('user_id', authState.currentUser.id)
      .then(({ data }) => {
        state.likedPostIds = (data || []).map((like) => like.post_id)
        state.likedLoaded = true
      })
  }
  return likedLoadPromise
}

function ensureFollowedTagsLoaded() {
  if (!authState.currentUser || state.followedTagsLoaded) return Promise.resolve()
  return supabase
    .from('tag_follows')
    .select('tag_name')
    .eq('user_id', authState.currentUser.id)
    .then(({ data }) => {
      state.followedTags = (data || []).map((row) => row.tag_name)
      state.followedTagsLoaded = true
    })
}

async function toggleTagFollow(tagName) {
  if (!authState.currentUser) return
  const userId = authState.currentUser.id
  if (state.followedTags.includes(tagName)) {
    const { error } = await supabase.from('tag_follows').delete().eq('user_id', userId).eq('tag_name', tagName)
    if (error) return
    state.followedTags = state.followedTags.filter((t) => t !== tagName)
  } else {
    const { error } = await supabase.from('tag_follows').insert({ user_id: userId, tag_name: tagName })
    if (error) return
    state.followedTags = [...state.followedTags, tagName]
  }
}

function ensureNotificationsLoaded() {
  if (!authState.currentUser || state.notificationsLoaded) return Promise.resolve()
  return supabase
    .from('notifications')
    .select('*')
    .eq('user_id', authState.currentUser.id)
    .order('created_at', { ascending: false })
    .then(({ data }) => {
      state.notifications = (data || []).map((n) => ({
        id: n.id,
        title: n.title,
        body: n.body,
        postId: n.post_id,
        groupId: n.group_id,
        time: n.created_at,
        unread: !n.read_at,
      }))
      state.notificationsLoaded = true
      refreshUnreadFlag()
    })
}

function refreshUnreadFlag() {
  state.unreadInbox = state.notifications.some((n) => n.unread) || state.chats.some((c) => c.unread)
}

// Attaches each thread's other participant + latest message — same "separate query + merge"
// pattern as useFeedStore's attachAuthors, so PostgREST embed syntax never has to be guessed.
async function ensureChatsLoaded() {
  if (!authState.currentUser || state.chatsLoaded) return
  const userId = authState.currentUser.id

  const { data: threads } = await supabase
    .from('chat_threads')
    .select('*')
    .or(`user_one_id.eq.${userId},user_two_id.eq.${userId}`)
  if (!threads?.length) {
    state.chatsLoaded = true
    return
  }

  const threadIds = threads.map((t) => t.id)
  const [{ data: messages }, { data: reads }] = await Promise.all([
    supabase.from('chat_messages').select('*').in('chat_thread_id', threadIds).order('created_at', { ascending: false }),
    supabase.from('chat_thread_reads').select('*').eq('user_id', userId).in('chat_thread_id', threadIds),
  ])

  const latestByThread = {}
  for (const message of messages || []) {
    if (!latestByThread[message.chat_thread_id]) latestByThread[message.chat_thread_id] = message
  }
  const readByThread = Object.fromEntries((reads || []).map((r) => [r.chat_thread_id, r.last_read_at]))

  const otherUserIds = threads.map((t) => (t.user_one_id === userId ? t.user_two_id : t.user_one_id))
  const { data: profiles } = await supabase.from('profiles').select('*').in('id', otherUserIds)
  const profileById = Object.fromEntries((profiles || []).map((p) => [p.id, p]))

  state.chats.splice(
    0,
    state.chats.length,
    ...threads.map((thread, i) => {
      const latest = latestByThread[thread.id]
      const lastReadAt = readByThread[thread.id]
      return {
        id: thread.id,
        userId: otherUserIds[i],
        otherUser: profileById[otherUserIds[i]],
        preview: latest ? (latest.body || (latest.media_urls?.length ? 'Sent a photo' : '')) : '',
        time: latest?.created_at ?? thread.created_at,
        unread: !!latest && latest.sender_id !== userId && (!lastReadAt || new Date(latest.created_at) > new Date(lastReadAt)),
      }
    }),
  )
  state.chatsLoaded = true
  refreshUnreadFlag()
}

export function useAppState() {
  ensureLikedLoaded()
  ensureFollowedTagsLoaded()

  function toggleDrawer() {
    state.drawerOpen = !state.drawerOpen
  }

  function closeDrawer() {
    state.drawerOpen = false
  }

  function openInbox() {
    state.inboxOpen = true
    state.drawerOpen = false
    ensureNotificationsLoaded()
    ensureChatsLoaded()
  }

  function closeInbox() {
    state.inboxOpen = false
  }

  function toggleInboxTab(tab) {
    state.activeInboxTab = tab
  }

  async function markInboxRead() {
    if (!authState.currentUser) return
    state.unreadInbox = false
    state.notifications = state.notifications.map((item) => ({ ...item, unread: false }))
    state.chats = state.chats.map((item) => ({ ...item, unread: false }))

    await supabase
      .from('notifications')
      .update({ read_at: new Date().toISOString() })
      .eq('user_id', authState.currentUser.id)
      .is('read_at', null)

    const now = new Date().toISOString()
    await Promise.all(
      state.chats.map((chat) =>
        supabase
          .from('chat_thread_reads')
          .upsert(
            { chat_thread_id: chat.id, user_id: authState.currentUser.id, last_read_at: now },
            { onConflict: 'chat_thread_id,user_id' },
          ),
      ),
    )
  }

  function isPostLiked(postId) {
    return state.likedPostIds.includes(postId)
  }

  async function toggleLike(post) {
    if (!authState.currentUser) return
    const userId = authState.currentUser.id
    const wasLiked = isPostLiked(post.id)

    if (wasLiked) {
      const { error } = await supabase.from('post_likes').delete().eq('post_id', post.id).eq('user_id', userId)
      if (error) return
      state.likedPostIds = state.likedPostIds.filter((id) => id !== post.id)
    } else {
      const { error } = await supabase.from('post_likes').insert({ post_id: post.id, user_id: userId })
      if (error) return
      state.likedPostIds = [...state.likedPostIds, post.id]
    }
    post.like_count = (post.like_count || 0) + (wasLiked ? -1 : 1)
  }

  return {
    state,
    toggleDrawer,
    closeDrawer,
    openInbox,
    closeInbox,
    toggleInboxTab,
    markInboxRead,
    isPostLiked,
    toggleLike,
    toggleTagFollow,
  }
}
