<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import TabBar from '../components/TabBar.vue'
import PostCard from '../components/PostCard.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useGroupStore } from '../composables/useGroupStore'
import { useAuth } from '../composables/useAuth'
import { avatarSrc } from '../utils/avatar'

const PROFILE_TABS = [
  { value: 'posts', label: 'My Posts' },
  { value: 'groups', label: 'My Groups' },
]

const router = useRouter()
const feedStore = useFeedStore()
const groupStore = useGroupStore()
const { state: authState } = useAuth()
const currentUser = computed(() => authState.currentUser || {})
const activeTab = ref('posts')

const myPosts = computed(() => feedStore.posts.filter((post) => post.user_id === authState.currentUser?.id))
const myGroups = computed(() => groupStore.groups.filter((group) => groupStore.isJoined(group.id)))
</script>

<template>
  <div class="profile">
    <div class="profile-scroll">
      <header class="profile-header">
        <img class="avatar" :src="avatarSrc(currentUser)" :alt="currentUser.username" />
        <div class="identity">
          <h1 class="username">{{ currentUser.username }}</h1>
          <p v-if="currentUser.location" class="location">{{ currentUser.location }}</p>
        </div>
      </header>

      <TabBar class="profile-tabs" :tabs="PROFILE_TABS" v-model="activeTab" />

      <div class="tab-content">
        <template v-if="activeTab === 'posts'">
          <PostCard v-for="post in myPosts" :key="post.id" :post="post" />
          <p v-if="!myPosts.length" class="empty">You haven't posted anything yet.</p>
        </template>

        <template v-else-if="activeTab === 'groups'">
          <div
            v-for="group in myGroups"
            :key="group.id"
            class="group-row"
            @click="router.push(`/groups/${group.id}`)"
          >
            <img class="group-photo" :src="group.photo_url" :alt="group.name" />
            <div class="group-meta">
              <span class="group-name">{{ group.name }}</span>
              <span class="group-members">{{ group.member_count }} members</span>
            </div>
          </div>
          <p v-if="!myGroups.length" class="empty">You haven't joined any groups yet.</p>
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>
.profile {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.profile-scroll {
  flex: 1;
  overflow-y: auto;
  padding-top: 72px;
  padding-bottom: 88px;
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 0 16px;
  margin-bottom: 20px;
}

.avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.username {
  font-size: 18px;
  line-height: 1.8;
  margin: 0;
}

.location {
  font-size: 13px;
  line-height: 1.8;
  color: var(--color-text-muted);
  margin: 0;
}

.profile-tabs {
  padding: 0 16px;
}

.tab-content {
  padding: 12px 16px 16px;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 40px 0;
}

.group-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 0;
  border-bottom: 1px solid var(--color-border);
}

.group-row:last-child {
  border-bottom: none;
}

.group-photo {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
}

.group-meta {
  display: flex;
  flex-direction: column;
  gap: 0;
  min-width: 0;
  line-height: 1.8;
}

.group-name {
  font-size: 14px;
  line-height: 1.8;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.group-members {
  font-size: 12px;
  line-height: 1.8;
  color: var(--color-text-muted);
}

</style>
