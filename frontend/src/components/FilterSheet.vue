<script setup>
import { computed, ref } from 'vue'
import BottomSheet from './BottomSheet.vue'
import LocationPickerSheet from './LocationPickerSheet.vue'
import { useCities, getCityById } from '../composables/useCities'

useCities()

const props = defineProps({
  open: { type: Boolean, required: true },
  filters: { type: Object, required: true },
})
const emit = defineEmits(['close'])

const isLocationPickerOpen = ref(false)
const selectedCityName = computed(() => getCityById(props.filters.locationCityId)?.name || 'Any location')

function resetFilters() {
  Object.assign(props.filters, {
    category: 'all',
    condition: 'all',
    priceMin: '',
    priceMax: '',
    locationCityId: null,
    sort: 'newest',
  })
}
</script>

<template>
  <BottomSheet :open="open" @close="emit('close')">
    <h2 class="sheet-title">Filter &amp; Sort</h2>

    <div class="filter-field">
      <span class="filter-label">Category</span>
      <div class="option-row">
        <button
          v-for="opt in ['all', 'bike', 'part']"
          :key="opt"
          type="button"
          class="option-chip"
          :class="{ 'option-chip--active': filters.category === opt }"
          @click="filters.category = opt"
        >
          {{ opt === 'all' ? 'All' : opt === 'bike' ? 'Bike' : 'Part' }}
        </button>
      </div>
    </div>

    <div class="filter-field">
      <span class="filter-label">Condition</span>
      <div class="option-row">
        <button
          v-for="opt in ['all', 'new', 'used']"
          :key="opt"
          type="button"
          class="option-chip"
          :class="{ 'option-chip--active': filters.condition === opt }"
          @click="filters.condition = opt"
        >
          {{ opt === 'all' ? 'All' : opt === 'new' ? 'New' : 'Used' }}
        </button>
      </div>
    </div>

    <div class="filter-field">
      <span class="filter-label">Price range (Rp)</span>
      <div class="price-row">
        <input v-model="filters.priceMin" type="number" inputmode="numeric" class="field-input" placeholder="Min" />
        <span class="price-sep">–</span>
        <input v-model="filters.priceMax" type="number" inputmode="numeric" class="field-input" placeholder="Max" />
      </div>
    </div>

    <div class="filter-field">
      <span class="filter-label">Location</span>
      <button type="button" class="field-input location-trigger" @click="isLocationPickerOpen = true">
        <span>{{ selectedCityName }}</span>
      </button>
    </div>

    <div class="filter-field">
      <span class="filter-label">Sort by</span>
      <div class="option-row">
        <button
          v-for="opt in [{ v: 'newest', l: 'Newest' }, { v: 'price-low', l: 'Price: Low' }, { v: 'price-high', l: 'Price: High' }, { v: 'nearest', l: 'Nearest' }]"
          :key="opt.v"
          type="button"
          class="option-chip"
          :class="{ 'option-chip--active': filters.sort === opt.v }"
          @click="filters.sort = opt.v"
        >
          {{ opt.l }}
        </button>
      </div>
    </div>

    <div class="sheet-actions">
      <button class="btn btn-secondary" @click="resetFilters">Reset</button>
      <button class="btn btn-primary" @click="emit('close')">Apply</button>
    </div>

    <LocationPickerSheet
      :open="isLocationPickerOpen"
      :model-value="filters.locationCityId"
      @update:model-value="filters.locationCityId = $event"
      @close="isLocationPickerOpen = false"
    />
  </BottomSheet>
</template>

<style scoped>
.sheet-title {
  font-size: 16px;
  margin: 0 0 14px;
  text-align: center;
}

.filter-field {
  margin-bottom: 14px;
}

.filter-label {
  display: block;
  font-size: 13px;
  font-weight: 400;
  color: var(--color-text);
  margin-bottom: 6px;
}

.price-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.price-row .field-input {
  flex: 1;
}

.price-sep {
  color: var(--color-text-muted);
}

.location-trigger {
  width: 100%;
  display: flex;
  align-items: center;
  color: var(--color-text);
  text-align: left;
}

.sheet-actions {
  display: flex;
  gap: 10px;
  margin-top: 8px;
}
</style>
