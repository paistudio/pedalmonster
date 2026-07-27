<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useChatStore } from '../composables/useChatStore'
import { currentUser, getUserById } from '../mocks'
import { formatPrice } from '../utils/formatters'
import PhotoPicker from '../components/create/PhotoPicker.vue'

const route = useRoute()
const router = useRouter()
const feedStore = useFeedStore()

const otherUser = computed(() => getUserById(route.params.userId))
const isSelf = computed(() => route.params.userId === currentUser.id)

const chat = otherUser.value ? useChatStore(otherUser.value.id) : null
const draft = ref('')
const photos = ref([])
const showPhotoPicker = ref(false)

onMounted(() => {
  const productId = route.query.product
  if (!productId || !chat) return
  const post = feedStore.posts.find((p) => p.id === productId)
  if (post) chat.sendProductMention(post)
})

function send() {
  if (!draft.value.trim() && !photos.value.length) return
  chat.sendMessage(draft.value, photos.value)
  draft.value = ''
  photos.value = []
  showPhotoPicker.value = false
}
</script>

<template>
  <div v-if="otherUser" class="chat">
    <header class="chat-header">
      <button class="back-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <img class="avatar" :src="otherUser.avatar_url" :alt="otherUser.username" />
      <span class="chat-username">{{ otherUser.username }}</span>
    </header>

    <div v-if="isSelf" class="own-listing-note">You can't chat with yourself.</div>

    <template v-else>
      <div class="messages">
        <template v-for="message in chat.messages" :key="message.id">
          <button
            v-if="message.type === 'product'"
            class="product-card"
            @click="router.push(`/market/${message.listing.id}`)"
          >
            <img v-if="message.listing.image" :src="message.listing.image" class="product-card__thumb" alt="" />
            <div class="product-card__meta">
              <span class="product-card__title">{{ message.listing.title }}</span>
              <span class="product-card__price">{{ formatPrice(message.listing.price) }}</span>
            </div>
          </button>
          <div
            v-else
            class="bubble-row"
            :class="{ 'bubble-row--mine': message.sender_id === currentUser.id }"
          >
            <div class="bubble" :class="{ 'bubble--media': message.media_urls?.length && !message.body }">
              <div v-if="message.media_urls?.length" class="bubble-media">
                <img v-for="src in message.media_urls" :key="src" :src="src" alt="" />
              </div>
              <span v-if="message.body">{{ message.body }}</span>
            </div>
          </div>
        </template>
        <p v-if="!chat.messages.length" class="empty">
          Say hi to {{ otherUser.username }}.
        </p>
      </div>

      <div v-if="showPhotoPicker" class="attach-panel">
        <PhotoPicker v-model="photos" :max="4" />
      </div>
      <div v-else-if="photos.length" class="attach-preview">
        <img v-for="src in photos" :key="src" :src="src" alt="" />
      </div>

      <footer class="composer">
        <button
          class="attach-btn"
          aria-label="Attach photos"
          @click="showPhotoPicker = !showPhotoPicker"
        >
          <Icon icon="iconoir:media-image" width="18" height="18" />
        </button>
        <input
          v-model="draft"
          class="composer-input"
          placeholder="Write a message..."
          @keyup.enter="send"
        />
        <button class="send-btn" aria-label="Send" @click="send">
          <Icon icon="iconoir:send" width="18" height="18" />
        </button>
      </footer>
    </template>
  </div>

  <div v-else class="not-found">
    <p>User not found.</p>
    <button class="btn btn-secondary" @click="router.push('/')">Back Home</button>
  </div>
</template>

<style scoped>
.chat {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.chat-header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.back-btn {
  border: none;
  background: none;
  color: var(--color-text);
  display: flex;
  padding: 4px;
  flex-shrink: 0;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.chat-username {
  font-size: 14px;
  font-weight: 400;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 24px 0;
}

.product-card {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  padding: 10px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-surface);
  text-align: left;
}

.product-card__thumb {
  width: 44px;
  height: 44px;
  border-radius: 6px;
  object-fit: cover;
  flex-shrink: 0;
}

.product-card__meta {
  display: flex;
  flex-direction: column;
  min-width: 0;
  line-height: 1.8;
}

.product-card__title {
  font-size: 13px;
  line-height: 1.8;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.product-card__price {
  font-size: 12px;
  line-height: 1.8;
  color: var(--color-text-muted);
}

.bubble-row {
  display: flex;
}

.bubble-row--mine {
  justify-content: flex-end;
}

.bubble {
  max-width: 75%;
  padding: 8px 12px;
  border-radius: 8px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  font-size: 14px;
}

.bubble-row--mine .bubble {
  background: var(--color-primary);
  color: var(--color-on-primary);
  border-color: var(--color-primary);
}

.bubble--media,
.bubble-row--mine .bubble--media {
  background: transparent;
  border: none;
  padding: 0;
}

.bubble-media {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.bubble-media img {
  width: 96px;
  height: 96px;
  border-radius: 8px;
  object-fit: cover;
}

.attach-panel {
  padding: 10px 12px 0;
  flex-shrink: 0;
}

.attach-preview {
  display: flex;
  gap: 6px;
  padding: 10px 12px 0;
  flex-shrink: 0;
}

.attach-preview img {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  object-fit: cover;
}

.composer {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px calc(10px + env(safe-area-inset-bottom));
  border-top: 1px solid var(--color-border);
  flex-shrink: 0;
}

.attach-btn {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  border: none;
  background: none;
  color: var(--color-text-muted);
  display: flex;
  align-items: center;
  justify-content: center;
}

.composer-input {
  flex: 1;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 10px 14px;
  font: inherit;
  font-size: 14px;
  background: var(--color-surface-input);
  color: var(--color-text);
}

.send-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  background: var(--color-primary);
  color: var(--color-on-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.own-listing-note {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-muted);
  font-size: 13px;
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
