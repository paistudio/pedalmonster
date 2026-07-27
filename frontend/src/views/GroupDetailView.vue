<script setup>
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import BottomSheet from '../components/BottomSheet.vue'
import PostCard from '../components/PostCard.vue'
import UserListSheet from '../components/UserListSheet.vue'
import { useGroupStore } from '../composables/useGroupStore'
import { useFeedStore } from '../composables/useFeedStore'
import { currentUser, getUserById } from '../mocks'

const route = useRoute()
const router = useRouter()
const groupStore = useGroupStore()
const feedStore = useFeedStore()
const isMembersSheetOpen = ref(false)
const isMenuOpen = ref(false)
const isDeleteConfirmOpen = ref(false)

const group = computed(() => groupStore.groups.find((g) => g.id === route.params.id))
const isJoined = computed(() => (group.value ? groupStore.isJoined(group.value.id) : false))
const isOwner = computed(() => (group.value ? groupStore.isOwner(group.value.id) : false))
const isBlocked = computed(() => (group.value ? groupStore.isBlocked(group.value.id, currentUser.id) : false))
const memberIds = computed(() => (group.value ? groupStore.membersOf(group.value.id) : []))
const memberPreview = computed(() =>
  memberIds.value.slice(0, 5).map((id) => getUserById(id)).filter(Boolean),
)
const groupPosts = computed(() =>
  feedStore.posts.filter(
    (post) => post.type === 'group_post' && post.type_data.group_id === group.value?.id,
  ),
)

function editGroup() {
  isMenuOpen.value = false
  router.push(`/groups/${group.value.id}/edit`)
}

function requestDeleteGroup() {
  isMenuOpen.value = false
  isDeleteConfirmOpen.value = true
}

function confirmDeleteGroup() {
  const groupId = group.value.id
  feedStore.removeGroupPosts(groupId)
  groupStore.deleteGroup(groupId)
  isDeleteConfirmOpen.value = false
  router.replace('/groups')
}

function blockMember(userId) {
  groupStore.blockUser(group.value.id, userId)
}
</script>

<template>
  <div v-if="group" class="detail">
    <header class="detail-header">
      <button class="back-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <span class="header-title">{{ group.name }}</span>

      <button v-if="isOwner" class="header-icon-btn" aria-label="Group menu" @click="isMenuOpen = true">
        <Icon icon="iconoir:more-horiz" width="22" height="22" />
      </button>
      <button
        v-else
        class="membership-pill"
        :class="{ 'membership-pill--joined': isJoined }"
        :disabled="isBlocked"
        :aria-label="isJoined ? 'Leave group' : 'Join group'"
        @click="groupStore.toggleMembership(group.id)"
      >
        {{ isJoined ? 'Leave' : 'Join' }}
      </button>
    </header>

    <div class="detail-scroll">
      <img class="banner" :src="group.photo_url" :alt="group.name" />

      <div class="detail-body">
        <h1 class="title">{{ group.name }}</h1>
        <p class="description">{{ group.description }}</p>

        <button class="members" @click="isMembersSheetOpen = true">
          <div class="member-avatars">
            <img
              v-for="user in memberPreview"
              :key="user.id"
              class="member-avatar"
              :src="user.avatar_url"
              :alt="user.username"
            />
          </div>
          <span class="member-count">{{ group.member_count }} members · See all</span>
        </button>

        <h2 class="posts-heading">Posts</h2>
        <div class="post-list">
          <PostCard v-for="post in groupPosts" :key="post.id" :post="post" hide-group-footer />
          <p v-if="!groupPosts.length" class="empty">No posts in this group yet.</p>
        </div>
      </div>
    </div>

    <UserListSheet
      :open="isMembersSheetOpen"
      :user-ids="memberIds"
      :title="`${group.member_count} Members`"
      empty-text="No members yet."
      :can-moderate="isOwner"
      @close="isMembersSheetOpen = false"
      @block="blockMember"
    />

    <BottomSheet :open="isMenuOpen" @close="isMenuOpen = false">
      <button class="menu-item" @click="editGroup">
        <Icon icon="iconoir:edit-pencil" width="18" height="18" />
        Edit group info
      </button>
      <button class="menu-item menu-item--danger" @click="requestDeleteGroup">
        <Icon icon="iconoir:trash" width="18" height="18" />
        Delete group
      </button>
    </BottomSheet>

    <BottomSheet :open="isDeleteConfirmOpen" @close="isDeleteConfirmOpen = false">
      <h2 class="sheet-title">Delete this group?</h2>
      <p class="sheet-body">
        This removes the group for everyone. All {{ group.member_count }} members will be removed
        and every post in this group will be deleted. This can't be undone.
      </p>
      <div class="sheet-actions">
        <button class="btn btn-secondary" @click="isDeleteConfirmOpen = false">Cancel</button>
        <button class="btn btn-danger" @click="confirmDeleteGroup">Delete group</button>
      </div>
    </BottomSheet>
  </div>

  <div v-else class="not-found">
    <p>Group not found.</p>
    <button class="btn btn-secondary" @click="router.push('/groups')">Back to Groups</button>
  </div>
</template>

<style scoped>
.detail {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.detail-header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.back-btn {
  flex-shrink: 0;
  border: none;
  background: none;
  color: var(--color-text);
  display: flex;
  padding: 4px;
}

.header-title {
  flex: 1;
  min-width: 0;
  font-size: 15px;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.header-icon-btn {
  flex-shrink: 0;
  border: none;
  background: none;
  color: var(--color-text);
  padding: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.membership-pill {
  flex-shrink: 0;
  border: 1px solid var(--color-accent);
  background: transparent;
  color: var(--color-accent);
  padding: 6px 16px;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 400;
}

.membership-pill--joined {
  border-color: var(--color-pill-border);
  color: var(--color-text-muted);
}

.membership-pill:disabled {
  border-color: var(--color-border);
  color: var(--color-text-muted);
}

.detail-scroll {
  flex: 1;
  overflow-y: auto;
}

.banner {
  width: 100%;
  aspect-ratio: 2 / 1;
  object-fit: cover;
  display: block;
}

.detail-body {
  padding: 16px;
}

.title {
  font-size: 18px;
  margin: 0 0 6px;
}

.description {
  font-size: 14px;
  color: var(--color-text-secondary);
  margin: 0 0 14px;
}

.members {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 12px;
  background: transparent;
  margin-bottom: 20px;
}

.member-avatars {
  display: flex;
}

.member-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid var(--color-bg);
  margin-left: -8px;
}

.member-avatar:first-child {
  margin-left: 0;
}

.member-count {
  font-size: 12px;
  color: var(--color-text-muted);
}

.posts-heading {
  font-size: 14px;
  margin: 0 0 4px;
}

.post-list {
  display: flex;
  flex-direction: column;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 24px 0;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  border: none;
  background: none;
  color: var(--color-text);
  font: inherit;
  font-size: 14px;
  padding: 14px 4px;
  text-align: left;
}

.menu-item--danger {
  color: var(--color-error);
}

.sheet-title {
  font-size: 16px;
  margin: 4px 0 8px;
}

.sheet-body {
  font-size: 13px;
  color: var(--color-text-secondary);
  margin: 0 0 18px;
}

.sheet-actions {
  display: flex;
  gap: 10px;
  padding-bottom: 4px;
}

.btn-danger {
  background: var(--color-error);
  color: #ffffff;
  border-color: var(--color-error);
}

.not-found {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  color: var(--color-text-muted);
}
</style>
