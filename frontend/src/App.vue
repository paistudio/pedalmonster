<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import BottomNav from './components/BottomNav.vue'
import InstallBanner from './components/InstallBanner.vue'
import AppHeader from './components/AppHeader.vue'
import TabBar from './components/TabBar.vue'
import { useAppState } from './composables/useAppState'
import { useMarketFilters } from './composables/useMarketFilters'
import { useFeedStore } from './composables/useFeedStore'
import { useGroupStore } from './composables/useGroupStore'
import { useAuth } from './composables/useAuth'
import { formatPrice, formatRelativeTime } from './utils/formatters'

const route = useRoute()
const router = useRouter()
const { state, toggleDrawer, closeDrawer, openInbox, closeInbox, toggleInboxTab, markInboxRead } = useAppState()
const marketFilters = useMarketFilters()
const feedStore = useFeedStore()
const groupStore = useGroupStore()
const { signOut } = useAuth()
const showShell = computed(() => !route.meta.hideShell)
const isMarket = computed(() => route.name === 'market')
const isGroups = computed(() => route.name === 'groups')

const confirmingLogout = ref(false)
const drawerQuery = ref('')
const inboxTabItems = [
  { value: 'notifications', label: 'Notifications' },
  { value: 'chat', label: 'Chat' },
]

const RESULT_ICONS = {
  listing: 'iconoir:label',
  community_post: 'iconoir:chat-bubble',
  group_post: 'iconoir:group',
  group: 'iconoir:group',
}

const drawerSearchResults = computed(() => {
  const q = drawerQuery.value.trim().toLowerCase()
  if (!q) return []

  const postResults = feedStore.posts
    .filter(
      (post) =>
        (post.title || '').toLowerCase().includes(q) ||
        post.description.toLowerCase().includes(q) ||
        (post.tags || []).some((tag) => tag.toLowerCase().includes(q)),
    )
    .map((post) => ({
      id: `post-${post.id}`,
      kind: post.type,
      title: post.title || post.description,
      subtitle: post.type === 'listing' ? formatPrice(post.type_data.price) : post.author.username,
      icon: RESULT_ICONS[post.type],
      onSelect: () => {
        if (post.type === 'listing') router.push(`/market/${post.id}`)
        else if (post.type === 'community_post') router.push(`/posts/${post.id}`)
        else router.push(`/groups/${post.type_data.group_id}`)
      },
    }))

  const groupResults = groupStore.groups
    .filter((group) => group.name.toLowerCase().includes(q) || group.description.toLowerCase().includes(q))
    .map((group) => ({
      id: `group-${group.id}`,
      kind: 'group',
      title: group.name,
      subtitle: `${group.member_count} members`,
      icon: RESULT_ICONS.group,
      onSelect: () => router.push(`/groups/${group.id}`),
    }))

  return [...postResults, ...groupResults]
})

function newPostCountForTag(tag) {
  const cutoff = Date.now() - 3 * 24 * 60 * 60 * 1000
  return feedStore.posts.filter(
    (post) => (post.tags || []).includes(tag) && new Date(post.created_at).getTime() >= cutoff,
  ).length
}

watch(
  () => route.fullPath,
  () => {
    closeDrawer()
    closeInbox()
  },
)

watch(
  () => state.drawerOpen,
  (open) => {
    if (!open) {
      confirmingLogout.value = false
      drawerQuery.value = ''
    }
  },
)

function handleTagClick(tag) {
  closeDrawer()
  router.push({ name: 'topic-detail', params: { tag } })
}

function selectSearchResult(result) {
  closeDrawer()
  result.onSelect()
}

function openAccountSettings() {
  closeDrawer()
  router.push({ name: 'account-settings' })
}

function openLikedPosts() {
  closeDrawer()
  router.push({ name: 'liked-posts' })
}

function openReportProblem() {
  closeDrawer()
  router.push({ name: 'report-problem' })
}

function openCreateGroup() {
  router.push('/groups/create')
}

function openNotification(item) {
  markInboxRead()
  closeInbox()
  if (item.groupId) {
    router.push(`/groups/${item.groupId}`)
    return
  }
  const post = feedStore.posts.find((p) => p.id === item.postId)
  if (!post) return
  if (post.type === 'listing') router.push(`/market/${post.id}`)
  else if (post.type === 'community_post' || post.type === 'comment') router.push(`/posts/${post.parent_id || post.id}`)
  else if (post.type === 'group_post') router.push(`/groups/${post.type_data.group_id}`)
}

function openChatItem(item) {
  markInboxRead()
  closeInbox()
  if (item.userId) router.push(`/chat/${item.userId}`)
}

async function confirmLogout() {
  confirmingLogout.value = false
  closeDrawer()
  await signOut()
  router.push('/login')
}
</script>

<template>
  <div class="shell">
    <InstallBanner v-if="showShell" />
    <AppHeader
      v-if="showShell"
      :drawer-open="state.drawerOpen"
      :has-unread="state.unreadInbox"
      @toggle-menu="toggleDrawer"
      @open-inbox="openInbox"
    >
      <template v-if="isMarket" #center>
        <div class="header-search">
          <Icon icon="iconoir:search" width="16" height="16" />
          <input v-model="marketFilters.query.value" placeholder="Search listings..." />
        </div>
      </template>
      <template v-else-if="isGroups" #center>
        <span class="app-header__title">Groups</span>
      </template>

      <template v-if="isMarket" #right>
        <button class="app-header__icon" aria-label="Filter" @click="marketFilters.openFilters()">
          <Icon icon="iconoir:filter" width="20" height="20" />
          <span v-if="marketFilters.activeFilterCount.value" class="header-filter-count">{{ marketFilters.activeFilterCount.value }}</span>
        </button>
      </template>
      <template v-else-if="isGroups" #right>
        <button class="app-header__icon" aria-label="Create group" @click="openCreateGroup">
          <Icon icon="iconoir:plus" width="20" height="20" />
        </button>
      </template>
    </AppHeader>

    <aside v-if="showShell" class="drawer" :class="{ 'drawer--open': state.drawerOpen }">
      <div class="drawer__top">
        <button class="drawer__close" aria-label="Close menu" @click="closeDrawer">
          <Icon icon="iconoir:xmark" width="20" height="20" />
        </button>
      </div>

      <div class="drawer__search-field">
        <Icon icon="iconoir:search" width="16" height="16" />
        <input
          v-model="drawerQuery"
          class="drawer__search-input"
          placeholder="Search posts, tags, and more"
        />
        <button v-if="drawerQuery" class="drawer__search-clear" aria-label="Clear search" @click="drawerQuery = ''">
          <Icon icon="iconoir:xmark" width="14" height="14" />
        </button>
      </div>

      <div class="drawer__scroll">
        <template v-if="drawerQuery">
          <div class="drawer__results">
            <button
              v-for="result in drawerSearchResults"
              :key="result.id"
              class="drawer__result"
              @click="selectSearchResult(result)"
            >
              <Icon :icon="result.icon" width="17" height="17" class="drawer__result-icon" />
              <span class="drawer__result-text">
                <span class="drawer__result-title">{{ result.title }}</span>
                <span class="drawer__result-subtitle">{{ result.subtitle }}</span>
              </span>
            </button>
            <p v-if="!drawerSearchResults.length" class="drawer__empty">No results for "{{ drawerQuery }}".</p>
          </div>
        </template>

        <template v-else>
          <div class="drawer__section">
            <p class="drawer__label">Topics</p>
            <div v-if="state.followedTags.length" class="drawer__topic-list">
              <button
                v-for="tag in state.followedTags"
                :key="tag"
                class="drawer__topic-row"
                @click="handleTagClick(tag)"
              >
                <span class="drawer__topic-name">
                  <Icon icon="iconoir:hashtag" width="12" height="12" />{{ tag }}
                </span>
                <span v-if="newPostCountForTag(tag)" class="drawer__topic-count">
                  {{ newPostCountForTag(tag) }} new
                </span>
              </button>
            </div>
            <p v-else class="drawer__empty">Follow a tag to see it here.</p>
          </div>

          <div class="drawer__divider" />

          <div class="drawer__section">
            <button class="drawer__item" @click="openAccountSettings">
              <Icon icon="iconoir:settings" width="17" height="17" class="drawer__item-icon" />
              <span class="drawer__item-label">Settings</span>
              <Icon icon="iconoir:nav-arrow-right" width="16" height="16" class="drawer__item-chevron" />
            </button>
            <button class="drawer__item" @click="openLikedPosts">
              <Icon icon="iconoir:heart" width="17" height="17" class="drawer__item-icon" />
              <span class="drawer__item-label">Liked</span>
              <Icon icon="iconoir:nav-arrow-right" width="16" height="16" class="drawer__item-chevron" />
            </button>
            <button class="drawer__item" @click="openReportProblem">
              <Icon icon="iconoir:triangle-flag" width="17" height="17" class="drawer__item-icon" />
              <span class="drawer__item-label">Report a problem</span>
              <Icon icon="iconoir:nav-arrow-right" width="16" height="16" class="drawer__item-chevron" />
            </button>
          </div>
        </template>
      </div>

      <div class="drawer__divider" />

      <div class="drawer__section drawer__section--logout">
        <div v-if="!confirmingLogout" class="drawer__item" @click="confirmingLogout = true">
          <Icon icon="iconoir:log-out" width="17" height="17" class="drawer__item-icon" />
          <span class="drawer__item-label">Logout</span>
        </div>
        <div v-else class="drawer__logout-confirm">
          <span>Log out of Pedal Monster?</span>
          <div class="drawer__logout-actions">
            <button class="drawer__logout-cancel" @click="confirmingLogout = false">Cancel</button>
            <button class="drawer__logout-confirm-btn" @click="confirmLogout">Logout</button>
          </div>
        </div>
      </div>
    </aside>

    <section v-if="showShell && state.inboxOpen" class="inbox-sheet">
      <div class="inbox-sheet__header">
        <h2>Inbox</h2>
        <button class="inbox-sheet__close" aria-label="Close inbox" @click="closeInbox">
          <Icon icon="iconoir:xmark" width="20" height="20" />
        </button>
      </div>
      <TabBar
        class="inbox-sheet__tabs"
        :tabs="inboxTabItems"
        :model-value="state.activeInboxTab"
        @update:model-value="toggleInboxTab"
      />
      <div class="inbox-list">
        <template v-if="state.activeInboxTab === 'notifications'">
          <button v-for="item in state.notifications" :key="item.id" class="inbox-item" @click="openNotification(item)">
            <span class="inbox-item__icon"><Icon icon="iconoir:bell" width="16" height="16" /></span>
            <span class="inbox-item__text">
              <span class="inbox-item__title" :class="{ 'inbox-item__title--unread': item.unread }">{{ item.title }}</span>
              <span class="inbox-item__body">{{ item.body }}</span>
            </span>
            <span class="inbox-item__meta">
              <span class="inbox-item__time">{{ formatRelativeTime(item.time) }}</span>
              <span v-if="item.unread" class="inbox-item__dot" />
            </span>
          </button>
          <p v-if="!state.notifications.length" class="inbox-empty">No notifications yet.</p>
        </template>
        <template v-else>
          <button v-for="item in state.chats" :key="item.id" class="inbox-item" @click="openChatItem(item)">
            <img
              v-if="item.otherUser"
              class="inbox-item__avatar"
              :src="item.otherUser.avatar_url"
              :alt="item.otherUser.username"
            />
            <span class="inbox-item__text">
              <span class="inbox-item__title" :class="{ 'inbox-item__title--unread': item.unread }">{{ item.otherUser?.username }}</span>
              <span class="inbox-item__body">{{ item.preview }}</span>
            </span>
            <span class="inbox-item__meta">
              <span class="inbox-item__time">{{ formatRelativeTime(item.time) }}</span>
              <span v-if="item.unread" class="inbox-item__dot" />
            </span>
          </button>
          <p v-if="!state.chats.length" class="inbox-empty">No chats yet.</p>
        </template>
      </div>
    </section>

    <RouterView class="shell-content" :class="{ 'shell-content--bare': !showShell }" />
    <BottomNav v-if="showShell" />
  </div>
</template>

<style scoped>
.shell {
  height: 100svh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
}

.shell-content {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  box-sizing: border-box;
}

.shell-content--bare {
  padding-top: 0;
  padding-bottom: 0;
}

.app-header__icon {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 999px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  background: transparent;
  color: var(--color-text);
  transition: background-color 0.15s ease, transform 0.1s ease;
}

.app-header__icon:active {
  background: rgba(255, 255, 255, 0.08);
  transform: scale(0.94);
}

.app-header__title {
  color: var(--color-text);
  font-size: 16px;
  font-weight: 400;
}

.header-search {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 10px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-surface-input);
  color: var(--color-text-muted);
}

.header-search input {
  flex: 1;
  min-width: 0;
  border: none;
  outline: none;
  background: none;
  font: inherit;
  font-size: 14px;
  color: var(--color-text);
}

.header-filter-count {
  position: absolute;
  top: 2px;
  right: 2px;
  background: var(--color-accent);
  color: #fff;
  font-size: 10px;
  min-width: 16px;
  height: 16px;
  border-radius: 999px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.drawer {
  position: absolute;
  inset: 0;
  width: 100%;
  padding: calc(12px + env(safe-area-inset-top)) 16px 24px;
  background: var(--color-bg);
  opacity: 0;
  transform: translateX(-16px);
  pointer-events: none;
  transition: opacity 0.2s ease, transform 0.2s ease;
  z-index: 33;
  display: flex;
  flex-direction: column;
}

.drawer--open {
  opacity: 1;
  transform: translateX(0);
  pointer-events: auto;
}

.drawer__top {
  flex-shrink: 0;
  display: flex;
  justify-content: flex-start;
  padding-bottom: 8px;
}

.drawer__close {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 999px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  color: var(--color-text);
  transition: background-color 0.15s ease, transform 0.1s ease;
}

.drawer__close:active {
  background: rgba(255, 255, 255, 0.08);
  transform: scale(0.94);
}

.drawer__search-field {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  margin-bottom: 16px;
  padding: 10px 12px;
  border: 1px solid var(--color-border);
  border-radius: 999px;
  background: var(--color-surface);
  color: var(--color-text-muted);
}

.drawer__search-input {
  flex: 1;
  min-width: 0;
  border: none;
  outline: none;
  background: none;
  font: inherit;
  font-size: 14px;
  color: var(--color-text);
}

.drawer__search-clear {
  flex-shrink: 0;
  border: none;
  background: none;
  color: var(--color-text-muted);
  display: flex;
}

.drawer__scroll {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
}

.drawer__results {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 4px 0;
}

.drawer__result {
  display: flex;
  align-items: center;
  gap: 12px;
  border: none;
  background: transparent;
  color: var(--color-text);
  text-align: left;
  padding: 11px 10px;
  border-radius: 10px;
}

.drawer__result:active {
  background: rgba(255, 255, 255, 0.08);
}

.drawer__result-icon {
  flex-shrink: 0;
  color: var(--color-text-muted);
}

.drawer__result-text {
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0;
  line-height: 1.8;
}

.drawer__result-title {
  font-size: 14px;
  line-height: 1.8;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.drawer__result-subtitle {
  font-size: 12px;
  line-height: 1.8;
  color: var(--color-text-muted);
}

.drawer__section {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 12px 0;
}

.drawer__section--logout {
  margin-top: auto;
  flex-shrink: 0;
  padding-bottom: 0;
}

.drawer__divider {
  height: 1px;
  background: var(--color-border);
  flex-shrink: 0;
}

.drawer__label {
  font-family: var(--font-mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 1.2px;
  color: var(--color-text-muted);
  margin: 0 0 6px;
}

.drawer__topic-list {
  display: flex;
  flex-direction: column;
}

.drawer__topic-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  border: none;
  border-bottom: 1px solid var(--color-border);
  background: transparent;
  color: var(--color-text);
  text-align: left;
  padding: 12px 4px;
}

.drawer__topic-row:last-child {
  border-bottom: none;
}

.drawer__topic-row:active {
  background: rgba(255, 255, 255, 0.06);
}

.drawer__topic-name {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
  color: var(--color-accent-alt);
}

.drawer__topic-count {
  flex-shrink: 0;
  font-size: 11px;
  color: var(--color-text-muted);
}

.drawer__empty {
  font-size: 13px;
  color: var(--color-text-muted);
  margin: 0;
}

.drawer__item {
  display: flex;
  align-items: center;
  gap: 12px;
  border: none;
  background: transparent;
  color: var(--color-text);
  text-align: left;
  padding: 11px 10px;
  border-radius: 10px;
  font-size: 14px;
  cursor: pointer;
}

.drawer__item:active {
  background: rgba(255, 255, 255, 0.08);
}

.drawer__item-icon {
  flex-shrink: 0;
  color: var(--color-text-muted);
}

.drawer__item-label {
  flex: 1;
}

.drawer__item-chevron {
  flex-shrink: 0;
  color: var(--color-text-muted);
}

.drawer__logout-confirm {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 11px 10px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.06);
  font-size: 13px;
  color: var(--color-text);
}

.drawer__logout-actions {
  display: flex;
  gap: 8px;
}

.drawer__logout-cancel,
.drawer__logout-confirm-btn {
  flex: 1;
  border-radius: 999px;
  padding: 8px 0;
  font-size: 13px;
  text-align: center;
}

.drawer__logout-cancel {
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text);
}

.drawer__logout-confirm-btn {
  border: 1px solid var(--color-primary);
  background: var(--color-primary);
  color: var(--color-on-primary);
}

.inbox-sheet {
  position: absolute;
  inset: 0;
  width: 100%;
  background: var(--color-bg);
  z-index: 34;
  display: flex;
  flex-direction: column;
}

.inbox-sheet__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: calc(12px + env(safe-area-inset-top)) 16px 12px;
}

.inbox-sheet__header h2 {
  font-size: 16px;
  margin: 0;
}

.inbox-sheet__close {
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 999px;
  background: transparent;
  color: var(--color-text);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: background-color 0.15s ease, transform 0.1s ease;
}

.inbox-sheet__close:active {
  background: rgba(255, 255, 255, 0.08);
  transform: scale(0.94);
}

.inbox-sheet__tabs {
  padding: 0 16px;
  margin-top: 12px;
}

.inbox-list {
  display: flex;
  flex-direction: column;
  padding: 4px 16px 16px;
  overflow-y: auto;
}

.inbox-item {
  position: relative;
  border: none;
  border-bottom: 1px solid var(--color-border);
  background: transparent;
  color: var(--color-text);
  padding: 14px 0;
  text-align: left;
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.inbox-item:last-child {
  border-bottom: none;
}

.inbox-item__icon {
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  border-radius: 999px;
  border: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-muted);
}

.inbox-item__avatar {
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  border-radius: 999px;
  object-fit: cover;
}

.inbox-item__text {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0;
  line-height: 1.8;
}

.inbox-item__title {
  font-size: 13px;
  line-height: 1.8;
  color: var(--color-text-secondary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.inbox-item__title--unread {
  color: var(--color-text);
}

.inbox-item__body {
  font-size: 12px;
  line-height: 1.8;
  color: var(--color-text-muted);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.inbox-item__meta {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 6px;
  padding-top: 2px;
}

.inbox-item__time {
  font-size: 11px;
  color: var(--color-text-muted);
}

.inbox-item__dot {
  width: 8px;
  height: 8px;
  border-radius: 999px;
  background: var(--color-error);
  align-self: flex-end;
}

.inbox-empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 32px 0;
  margin: 0;
}
</style>
