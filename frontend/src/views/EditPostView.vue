<script setup>
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import PhotoPicker from '../components/create/PhotoPicker.vue'
import { useFeedStore } from '../composables/useFeedStore'

const route = useRoute()
const router = useRouter()
const store = useFeedStore()

const post = computed(() =>
  store.posts.find(
    (p) => p.id === route.params.id && (p.type === 'community_post' || p.type === 'group_post'),
  ),
)
const isOwner = computed(() => (post.value ? store.isPostOwner(post.value) : false))

const description = ref(post.value?.description ?? '')
const photos = ref(post.value?.media_urls ? [...post.value.media_urls] : [])

const errors = reactive({})

function validate() {
  errors.description = description.value.trim() ? '' : 'Write something to post'
  return !errors.description
}

function submit() {
  if (!validate()) return
  store.updatePost(post.value, {
    description: description.value,
    media_urls: photos.value,
  })
  router.replace(`/posts/${post.value.id}`)
}
</script>

<template>
  <div v-if="post && isOwner" class="form-screen">
    <header class="screen-header">
      <button class="icon-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <span class="screen-title">Edit Post</span>
      <div class="spacer" />
    </header>

    <div class="form-step">
      <div class="field">
        <label class="field-label">What's on your mind?</label>
        <textarea
          v-model="description"
          class="field-textarea"
          :class="{ 'field-textarea--error': errors.description }"
          placeholder="Ask a question, share a tip, post an update..."
        />
        <span v-if="errors.description" class="field-error">{{ errors.description }}</span>
      </div>

      <div class="field">
        <label class="field-label">Photo (optional)</label>
        <PhotoPicker v-model="photos" :max="3" />
      </div>
    </div>

    <footer class="form-footer">
      <button class="btn btn-secondary" @click="router.back()">Cancel</button>
      <button class="btn btn-primary" @click="submit">Save changes</button>
    </footer>
  </div>

  <div v-else class="not-found">
    <p>Post not found.</p>
    <button class="btn btn-secondary" @click="router.push('/')">Back to Home</button>
  </div>
</template>

<style scoped>
.form-screen {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.screen-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px;
}

.screen-title {
  font-size: 16px;
  color: var(--color-text);
}

.spacer {
  width: 40px;
  flex-shrink: 0;
}

.icon-btn {
  flex-shrink: 0;
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

.icon-btn:active {
  background: rgba(255, 255, 255, 0.08);
  transform: scale(0.94);
}

.form-step {
  flex: 1;
  overflow-y: auto;
  padding: 4px 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-footer {
  flex-shrink: 0;
  display: flex;
  gap: 10px;
  padding: 12px 16px calc(12px + env(safe-area-inset-bottom));
  border-top: 1px solid var(--color-border);
  background: var(--color-surface);
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
