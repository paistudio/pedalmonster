<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import CreationHeader from '../../components/create/CreationHeader.vue'
import PhotoPicker from '../../components/create/PhotoPicker.vue'
import { useFeedStore } from '../../composables/useFeedStore'
import { useGroupStore } from '../../composables/useGroupStore'

const router = useRouter()
const store = useFeedStore()
const groupStore = useGroupStore()

const myGroups = computed(() => groupStore.groups.filter((group) => store.isGroupJoined(group.id)))

const groupId = ref(myGroups.value[0]?.id ?? '')
// Groups + memberships load asynchronously — myGroups is often still empty at setup time,
// so the ref() default above misses it. Fill it in once the real data arrives.
watch(myGroups, (list) => {
  if (!groupId.value && list.length) groupId.value = list[0].id
})
const description = ref('')
const photos = ref([])
const isUploading = ref(false)

const errors = reactive({})

function validate() {
  errors.groupId = groupId.value ? '' : 'Pick a group'
  errors.description = description.value.trim() ? '' : 'Write something to post'
  return !errors.groupId && !errors.description
}

async function submit() {
  if (isUploading.value) return
  if (!validate()) return
  await store.createPost({
    type: 'group_post',
    title: null,
    description: description.value.trim(),
    media_urls: photos.value,
    location: null,
    type_data: {
      group_id: groupId.value,
    },
  })
  router.push('/')
}
</script>

<template>
  <div class="form-screen">
    <CreationHeader title="Group Post" />

    <div class="form-step">
      <div v-if="!myGroups.length" class="empty-state">
        You haven't joined any groups yet. Join a group from the Home feed first.
      </div>

      <template v-else>
        <div class="field">
          <label class="field-label">Post to</label>
          <select v-model="groupId" class="field-select" :class="{ 'field-select--error': errors.groupId }">
            <option v-for="group in myGroups" :key="group.id" :value="group.id">
              {{ group.name }}
            </option>
          </select>
          <span v-if="errors.groupId" class="field-error">{{ errors.groupId }}</span>
        </div>

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
          <PhotoPicker v-model="photos" v-model:uploading="isUploading" :max="3" folder="group-posts" />
        </div>
      </template>
    </div>

    <footer class="form-footer">
      <button class="btn btn-secondary" @click="router.push('/')">Cancel</button>
      <button class="btn btn-primary" :disabled="!myGroups.length || isUploading" @click="submit">Post</button>
    </footer>
  </div>
</template>

<style scoped>
.empty-state {
  font-size: 13px;
  color: var(--color-text-muted);
  text-align: center;
  padding: 32px 16px;
}
</style>
