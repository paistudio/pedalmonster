<script setup>
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import CreationHeader from '../../components/create/CreationHeader.vue'
import PhotoPicker from '../../components/create/PhotoPicker.vue'
import LocationPickerSheet from '../../components/LocationPickerSheet.vue'
import { useFeedStore } from '../../composables/useFeedStore'
import { useCities, getCityById } from '../../composables/useCities'

useCities()

const router = useRouter()
const store = useFeedStore()

const TOTAL_STEPS = 3
const step = ref(1)

const photos = ref([])
const title = ref('')
const category = ref('')
const condition = ref('')
const price = ref('')
const locationCityId = ref(null)
const isLocationPickerOpen = ref(false)
const description = ref('')
const isUploading = ref(false)

const errors = reactive({})

const selectedCityName = computed(() => getCityById(locationCityId.value)?.name || '')

function validateStep1() {
  errors.photos = photos.value.length ? '' : 'Add at least 1 photo'
  return !errors.photos
}

function validateStep2() {
  errors.title = title.value.trim() ? '' : 'Title is required'
  errors.category = category.value ? '' : 'Pick a category'
  errors.condition = condition.value ? '' : 'Pick a condition'
  errors.price = Number(price.value) > 0 ? '' : 'Enter a valid price'
  errors.location = locationCityId.value ? '' : 'Location is required'
  return !errors.title && !errors.category && !errors.condition && !errors.price && !errors.location
}

function validateStep3() {
  errors.description = description.value.trim() ? '' : 'Description is required'
  return !errors.description
}

function next() {
  if (step.value === 1 && !validateStep1()) return
  if (step.value === 2 && !validateStep2()) return
  step.value += 1
}

function back() {
  if (step.value > 1) {
    step.value -= 1
  } else {
    router.push('/')
  }
}

async function submit() {
  if (isUploading.value) return
  if (!validateStep3()) return
  // Activity points (+2) are awarded server-side by a DB trigger on insert, not here — see
  // docs/19-supabase-only-backend-plan.md.
  await store.createPost({
    type: 'listing',
    title: title.value.trim(),
    description: description.value.trim(),
    media_urls: photos.value,
    location: selectedCityName.value,
    location_city_id: locationCityId.value,
    type_data: {
      category: category.value,
      condition: condition.value,
      price: Number(price.value),
      status: 'available',
    },
  })
  router.push('/')
}
</script>

<template>
  <div class="form-screen">
    <CreationHeader title="Sell" :step="step" :total-steps="TOTAL_STEPS" />

    <div v-show="step === 1" class="form-step">
      <PhotoPicker v-model="photos" v-model:uploading="isUploading" :max="5" folder="listings" />
      <p v-if="errors.photos" class="field-error">{{ errors.photos }}</p>
    </div>

    <div v-show="step === 2" class="form-step">
      <div class="field">
        <label class="field-label">Title</label>
        <input v-model="title" class="field-input" :class="{ 'field-input--error': errors.title }" placeholder="e.g. Polygon Xtrada 7 MTB" />
        <span v-if="errors.title" class="field-error">{{ errors.title }}</span>
      </div>

      <div class="field">
        <label class="field-label">Category</label>
        <div class="option-row">
          <button
            type="button"
            class="option-chip"
            :class="{ 'option-chip--active': category === 'bike' }"
            @click="category = 'bike'"
          >
            Bike
          </button>
          <button
            type="button"
            class="option-chip"
            :class="{ 'option-chip--active': category === 'part' }"
            @click="category = 'part'"
          >
            Part
          </button>
        </div>
        <span v-if="errors.category" class="field-error">{{ errors.category }}</span>
      </div>

      <div class="field">
        <label class="field-label">Condition</label>
        <div class="option-row">
          <button
            type="button"
            class="option-chip"
            :class="{ 'option-chip--active': condition === 'new' }"
            @click="condition = 'new'"
          >
            New
          </button>
          <button
            type="button"
            class="option-chip"
            :class="{ 'option-chip--active': condition === 'used' }"
            @click="condition = 'used'"
          >
            Used
          </button>
        </div>
        <span v-if="errors.condition" class="field-error">{{ errors.condition }}</span>
      </div>

      <div class="field">
        <label class="field-label">Price (Rp)</label>
        <input
          v-model="price"
          type="number"
          inputmode="numeric"
          class="field-input"
          :class="{ 'field-input--error': errors.price }"
          placeholder="0"
        />
        <span v-if="errors.price" class="field-error">{{ errors.price }}</span>
      </div>

      <div class="field">
        <label class="field-label">Location</label>
        <button
          type="button"
          class="field-input location-trigger"
          :class="{ 'field-input--error': errors.location }"
          @click="isLocationPickerOpen = true"
        >
          <span>{{ selectedCityName || 'Choose a city' }}</span>
          <Icon icon="iconoir:nav-arrow-right" width="16" height="16" />
        </button>
        <span v-if="errors.location" class="field-error">{{ errors.location }}</span>
      </div>
    </div>

    <div v-show="step === 3" class="form-step">
      <div class="field">
        <label class="field-label">Description</label>
        <textarea
          v-model="description"
          class="field-textarea"
          :class="{ 'field-textarea--error': errors.description }"
          placeholder="Condition, what's included, reason for selling..."
        />
        <span v-if="errors.description" class="field-error">{{ errors.description }}</span>
      </div>
    </div>

    <footer class="form-footer">
      <button class="btn btn-secondary" @click="back">
        {{ step === 1 ? 'Cancel' : 'Back' }}
      </button>
      <button v-if="step < TOTAL_STEPS" class="btn btn-primary" @click="next">Next</button>
      <button v-else class="btn btn-primary" :disabled="isUploading" @click="submit">Post Listing</button>
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
