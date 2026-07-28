<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import PostCard from '../components/PostCard.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useAuth } from '../composables/useAuth'
import { supabase } from '../lib/supabase'
import { avatarSrc } from '../utils/avatar'

const route = useRoute()
const router = useRouter()
const feedStore = useFeedStore()
const { state: authState } = useAuth()

const user = ref(null)

async function loadUser(id) {
  if (!id) {
    user.value = null
    return
  }
  const { data } = await supabase.from('profiles').select('*').eq('id', id).maybeSingle()
  user.value = data
}

watch(() => route.params.id, loadUser, { immediate: true })

const isSelf = computed(() => route.params.id === authState.currentUser?.id)

const memberSince = computed(() =>
  user.value
    ? new Intl.DateTimeFormat('en-US', { month: 'long', year: 'numeric' }).format(new Date(user.value.created_at))
    : '',
)

const listings = computed(() =>
  feedStore.posts.filter(
    (post) => post.user_id === user.value?.id && post.type === 'listing' && post.type_data.status !== 'sold',
  ),
)

function openChat() {
  router.push(`/chat/${user.value.id}`)
}
</script>

<template>
  <div v-if="user" class="user-profile">
    <header class="profile-header-bar">
      <button class="back-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
    </header>

    <div class="profile-scroll">
      <div class="identity">
        <img class="avatar" :src="avatarSrc(user)" :alt="user.username" />
        <h1 class="username">{{ user.username }}</h1>
        <p v-if="user.location" class="location">
          <Icon icon="iconoir:map-pin" width="13" height="13" />
          {{ user.location }}
        </p>
        <p v-if="user.bio" class="bio">{{ user.bio }}</p>
        <p class="member-since">Member since {{ memberSince }}</p>
      </div>

      <div v-if="listings.length" class="listings">
        <h2 class="listings-heading">Listings</h2>
        <div class="listings-grid">
          <PostCard v-for="post in listings" :key="post.id" :post="post" layout="grid" />
        </div>
      </div>
    </div>

    <footer v-if="!isSelf" class="cta-bar">
      <button class="btn btn-primary" @click="openChat">Chat</button>
    </footer>
  </div>

  <div v-else class="not-found">
    <p>User not found.</p>
    <button class="btn btn-secondary" @click="router.push('/')">Back Home</button>
  </div>
</template>

<style scoped>
.user-profile {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.profile-header-bar {
  padding: 10px 12px;
  flex-shrink: 0;
}

.back-btn {
  border: none;
  background: none;
  color: var(--color-text);
  display: flex;
  padding: 4px;
}

.profile-scroll {
  flex: 1;
  overflow-y: auto;
  padding: 0 16px 16px;
}

.identity {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 4px;
  padding: 8px 0 20px;
}

.avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  object-fit: cover;
  margin-bottom: 8px;
}

.username {
  font-size: 18px;
  line-height: 1.8;
  margin: 0;
}

.location {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  line-height: 1.8;
  color: var(--color-text-muted);
  margin: 0;
}

.bio {
  font-size: 13px;
  line-height: 1.8;
  color: var(--color-text-secondary);
  margin: 4px 0 0;
  max-width: 320px;
}

.member-since {
  font-size: 12px;
  line-height: 1.8;
  color: var(--color-text-muted);
  margin: 4px 0 0;
}

.listings-heading {
  font-size: 14px;
  margin: 0 0 10px;
  color: var(--color-text);
}

.listings-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.cta-bar {
  flex-shrink: 0;
  display: flex;
  padding: 12px 16px calc(12px + env(safe-area-inset-bottom));
  border-top: 1px solid var(--color-border);
  background: var(--color-surface);
}

.cta-bar .btn-primary {
  background: rgba(54, 58, 63, 0.72);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.14);
  color: #ffffff;
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
