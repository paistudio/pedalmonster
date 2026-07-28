<script setup>
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import CreationHeader from '../components/create/CreationHeader.vue'
import PhotoPicker from '../components/create/PhotoPicker.vue'
import LocationPickerSheet from '../components/LocationPickerSheet.vue'
import { useGroupStore } from '../composables/useGroupStore'
import { useCities, getCityById } from '../composables/useCities'

useCities()

const router = useRouter()
const store = useGroupStore()

const name = ref('')
const description = ref('')
const photos = ref([])
const locationCityId = ref(null)
const isLocationPickerOpen = ref(false)
const isUploading = ref(false)

const errors = reactive({})

const selectedCityName = computed(() => getCityById(locationCityId.value)?.name || '')

function validate() {
  errors.name = name.value.trim() ? '' : 'Group name is required'
  errors.description = description.value.trim() ? '' : 'Add a short description'
  return !errors.name && !errors.description
}

async function submit() {
  if (isUploading.value) return
  if (!validate()) return
  const group = await store.createGroup({
    name: name.value,
    description: description.value,
    photo_url: photos.value[0] ?? `https://picsum.photos/seed/${Date.now()}/300/300`,
    location_city_id: locationCityId.value,
  })
  router.replace(`/groups/${group.id}`)
}
</script>

<template>
  <div class="form-screen">
    <CreationHeader title="New Group" />

    <div class="form-step">
      <div class="field">
        <label class="field-label">Group name</label>
        <input
          v-model="name"
          class="field-input"
          :class="{ 'field-input--error': errors.name }"
          placeholder="e.g. Bandung Morning Riders"
        />
        <span v-if="errors.name" class="field-error">{{ errors.name }}</span>
      </div>

      <div class="field">
        <label class="field-label">Description</label>
        <textarea
          v-model="description"
          class="field-textarea"
          :class="{ 'field-textarea--error': errors.description }"
          placeholder="What is this group about?"
        />
        <span v-if="errors.description" class="field-error">{{ errors.description }}</span>
      </div>

      <div class="field">
        <label class="field-label">Group photo (optional)</label>
        <PhotoPicker v-model="photos" v-model:uploading="isUploading" :max="1" folder="groups" />
      </div>

      <div class="field">
        <label class="field-label">Location (optional)</label>
        <button type="button" class="field-input location-trigger" @click="isLocationPickerOpen = true">
          <span>{{ selectedCityName || 'Choose a city' }}</span>
          <Icon icon="iconoir:nav-arrow-right" width="16" height="16" />
        </button>
      </div>
    </div>

    <footer class="form-footer">
      <button class="btn btn-secondary" @click="router.back()">Cancel</button>
      <button class="btn btn-primary" :disabled="isUploading" @click="submit">Create Group</button>
    </footer>

    <LocationPickerSheet
      :open="isLocationPickerOpen"
      :model-value="locationCityId"
      @update:model-value="locationCityId = $event"
      @close="isLocationPickerOpen = false"
    />
  </div>
</template>

<style scoped>
.location-trigger {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  color: var(--color-text);
  text-align: left;
}
</style>
