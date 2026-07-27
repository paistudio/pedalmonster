import { reactive } from 'vue'

const state = reactive({
  drawerOpen: false,
  inboxOpen: false,
  unreadInbox: true,
  followedTags: ['MTB', 'Trail', 'Commuter'],
  likedPostIds: ['p7', 'p10'],
  inboxTabs: ['notifications', 'chat'],
  activeInboxTab: 'notifications',
  notifications: [
    { id: 'n1', title: 'New comment on your post', body: 'A rider replied with a recommendation.', time: '2h', unread: true, postId: 'p8' },
    { id: 'n2', title: 'Someone joined your group', body: 'A new member joined MTB Trail Hunter Bogor.', time: '1d', unread: false, groupId: 'g2' },
  ],
  chats: [
    { id: 'c1', userId: 'u6', preview: 'Is the fork still original?', time: '5m', unread: true },
    { id: 'c2', userId: 'u8', preview: 'Masih ready gak groupsetnya?', time: '1d', unread: false },
  ],
})

export function useAppState() {
  function toggleDrawer() {
    state.drawerOpen = !state.drawerOpen
  }

  function closeDrawer() {
    state.drawerOpen = false
  }

  function openInbox() {
    state.inboxOpen = true
    state.drawerOpen = false
  }

  function closeInbox() {
    state.inboxOpen = false
  }

  function toggleInboxTab(tab) {
    state.activeInboxTab = tab
  }

  function markInboxRead() {
    state.unreadInbox = false
    state.notifications = state.notifications.map((item) => ({ ...item, unread: false }))
    state.chats = state.chats.map((item) => ({ ...item, unread: false }))
  }

  function isPostLiked(postId) {
    return state.likedPostIds.includes(postId)
  }

  function toggleLike(post) {
    const wasLiked = isPostLiked(post.id)
    state.likedPostIds = wasLiked
      ? state.likedPostIds.filter((id) => id !== post.id)
      : [...state.likedPostIds, post.id]
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
  }
}
