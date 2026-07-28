<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import CreationHeader from '../../components/create/CreationHeader.vue'
import PhotoPicker from '../../components/create/PhotoPicker.vue'
import { useFeedStore } from '../../composables/useFeedStore'

const router = useRouter()
const store = useFeedStore()

const photos = ref([])
const description = ref('')
const isUploading = ref(false)

const errors = reactive({})

function validate() {
  errors.description = description.value.trim() ? '' : 'Write something to post'
  return !errors.description
}

async function submit() {
  if (isUploading.value) return
  if (!validate()) return
  // Activity points (+2) are awarded server-side by a DB trigger on insert, not here — see
  // docs/19-supabase-only-backend-plan.md.
  await store.createPost({
    type: 'community_post',
    title: null,
    description: description.value.trim(),
    media_urls: photos.value,
    location: null,
    type_data: {},
  })
  router.push('/')
}
</script>

<template>
  <div class="form-screen">
    <CreationHeader title="Post" />

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
        <PhotoPicker v-model="photos" v-model:uploading="isUploading" :max="3" folder="posts" />
      </div>
    </div>

    <footer class="form-footer">
      <button class="btn btn-secondary" @click="router.push('/')">Cancel</button>
      <button class="btn btn-primary" :disabled="isUploading" @click="submit">Post</button>
    </footer>
  </div>
</template>
