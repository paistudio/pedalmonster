<script setup>
import { computed } from 'vue'
import PostCard from '../components/PostCard.vue'
import FilterSheet from '../components/FilterSheet.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useMarketFilters } from '../composables/useMarketFilters'
import { useUserLocation } from '../composables/useUserLocation'
import { distanceBetweenCities } from '../utils/geo'

const store = useFeedStore()
const { query, isFilterOpen, filters, closeFilters } = useMarketFilters()
const { state: locationState } = useUserLocation()

const listings = computed(() => {
  const q = query.value.trim().toLowerCase()
  const min = Number(filters.priceMin) || 0
  const max = Number(filters.priceMax) || Infinity

  let result = store.posts.filter((post) => {
    if (post.type !== 'listing') return false
    if (post.type_data.status === 'sold') return false
    if (filters.category !== 'all' && post.type_data.category !== filters.category) return false
    if (filters.condition !== 'all' && post.type_data.condition !== filters.condition) return false
    if (post.type_data.price < min || post.type_data.price > max) return false
    if (filters.locationCityId && post.location_city_id !== filters.locationCityId) {
      return false
    }
    if (q && !post.title.toLowerCase().includes(q) && !post.description.toLowerCase().includes(q)) {
      return false
    }
    return true
  })

  if (filters.sort === 'price-low') {
    result = [...result].sort((a, b) => a.type_data.price - b.type_data.price)
  } else if (filters.sort === 'price-high') {
    result = [...result].sort((a, b) => b.type_data.price - a.type_data.price)
  } else if (filters.sort === 'nearest' && locationState.resolvedCityId) {
    result = [...result].sort((a, b) => {
      const distA = distanceBetweenCities(locationState.resolvedCityId, a.location_city_id)
      const distB = distanceBetweenCities(locationState.resolvedCityId, b.location_city_id)
      if (distA == null) return 1
      if (distB == null) return -1
      return distA - distB
    })
  } else {
    result = [...result].sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
  }

  return result
})
</script>

<template>
  <div class="market">
    <div class="market-grid">
      <PostCard v-for="post in listings" :key="post.id" :post="post" layout="grid" />
      <p v-if="!listings.length" class="empty">No listings match your filters.</p>
    </div>

    <FilterSheet :open="isFilterOpen" :filters="filters" @close="closeFilters" />
  </div>
</template>

<style scoped>
.market {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.market-grid {
  flex: 1;
  overflow-y: auto;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  align-content: start;
  padding: 76px 16px 88px;
}

.empty {
  grid-column: 1 / -1;
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 40px 0;
}
</style>
