<script setup>
import { computed, ref } from 'vue'
import { Icon } from '@iconify/vue'
import BottomSheet from './BottomSheet.vue'
import { requestGeolocationCity } from '../utils/geo'
import { cities } from '../mocks'

const props = defineProps({
  open: { type: Boolean, required: true },
  modelValue: { type: String, default: null },
})
const emit = defineEmits(['close', 'update:modelValue'])

const query = ref('')
const status = ref('idle') // idle | requesting | denied | unsupported | error

const filteredCities = computed(() => {
  const q = query.value.trim().toLowerCase()
  if (!q) return cities
  return cities.filter(
    (city) => city.name.toLowerCase().includes(q) || city.province.toLowerCase().includes(q),
  )
})

const errorMessage = computed(() => {
  if (status.value === 'denied') return "Location access denied — pick a city below."
  if (status.value === 'unsupported') return "Location isn't supported on this device — pick a city below."
  if (status.value === 'error') return "Couldn't get your location — pick a city below."
  return ''
})

function selectCity(cityId) {
  emit('update:modelValue', cityId)
  emit('close')
}

async function useGpsLocation() {
  status.value = 'requesting'
  try {
    const city = await requestGeolocationCity(cities)
    status.value = 'idle'
    selectCity(city.id)
  } catch (error) {
    status.value = error.code || 'error'
  }
}
</script>

<template>
  <BottomSheet :open="open" @close="emit('close')">
    <h2 class="sheet-title">Set location</h2>

    <button class="gps-btn" :disabled="status === 'requesting'" @click="useGpsLocation">
      <Icon icon="iconoir:map-pin" width="16" height="16" />
      {{ status === 'requesting' ? 'Locating...' : 'Use my location' }}
    </button>
    <p v-if="errorMessage" class="gps-error">{{ errorMessage }}</p>

    <input v-model="query" class="field-input city-search" placeholder="Search city or province..." />

    <div class="city-list">
      <button
        v-for="city in filteredCities"
        :key="city.id"
        class="city-row"
        :class="{ 'city-row--active': modelValue === city.id }"
        @click="selectCity(city.id)"
      >
        <span class="city-name">{{ city.name }}</span>
        <span class="city-province">{{ city.province }}</span>
      </button>
      <p v-if="!filteredCities.length" class="empty">No cities match "{{ query }}".</p>
    </div>
  </BottomSheet>
</template>

<style scoped>
.sheet-title {
  font-size: 16px;
  margin: 0 0 14px;
  text-align: center;
}

.gps-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px;
  border-radius: 999px;
  background: var(--color-primary);
  color: var(--color-on-primary);
  border: 1px solid var(--color-primary);
  font-size: 14px;
  margin-bottom: 6px;
}

.gps-btn:disabled {
  background: var(--color-surface-input);
  border-color: var(--color-border);
  color: var(--color-text-muted);
}

.gps-error {
  font-size: 12px;
  color: var(--color-error);
  text-align: center;
  margin: 0 0 12px;
}

.city-search {
  width: 100%;
  margin-bottom: 8px;
  box-sizing: border-box;
}

.city-list {
  max-height: 40vh;
  overflow-y: auto;
}

.city-row {
  width: 100%;
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 8px;
  border: none;
  border-bottom: 1px solid var(--color-border);
  background: transparent;
  color: var(--color-text);
  text-align: left;
  padding: 12px 4px;
}

.city-row:last-child {
  border-bottom: none;
}

.city-row--active {
  color: var(--color-accent-alt);
}

.city-name {
  font-size: 14px;
}

.city-province {
  flex-shrink: 0;
  font-size: 12px;
  color: var(--color-text-muted);
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 24px 0;
}
</style>
