<script setup>
import { ref, computed } from 'vue'
import { Icon } from '@iconify/vue'
import PullToRefresh from '../components/PullToRefresh.vue'
import PostCard from '../components/PostCard.vue'
import TabBar from '../components/TabBar.vue'
import LocationPickerSheet from '../components/LocationPickerSheet.vue'
import { useFeedStore } from '../composables/useFeedStore'
import { useUserLocation } from '../composables/useUserLocation'
import { distanceBetweenCities, NEARBY_RADIUS_KM } from '../utils/geo'
import { getCityById } from '../mocks'

const PAGE_SIZE = 6

const FEED_TABS = [
  { value: 'for-you', label: 'For You' },
  { value: 'nearby', label: 'Nearby' },
]

const store = useFeedStore()
const { state: locationState, openPicker, closePicker, setManualCity } = useUserLocation()
const visibleCount = ref(PAGE_SIZE)
const activeTab = ref('for-you')
const switchToNearbyOnPick = ref(false)

const cityName = computed(() => getCityById(locationState.resolvedCityId)?.name || '')

function nearbyDistance(post) {
  if (!locationState.resolvedCityId || !post.location_city_id) return null
  return distanceBetweenCities(locationState.resolvedCityId, post.location_city_id)
}

const nearbyPosts = computed(() => {
  if (!locationState.resolvedCityId) return []
  return store.posts
    .map((post) => ({ post, distance: nearbyDistance(post) }))
    .filter(({ distance }) => distance != null && distance <= NEARBY_RADIUS_KM)
    .sort((a, b) => a.distance - b.distance || new Date(b.post.created_at) - new Date(a.post.created_at))
    .map(({ post }) => post)
})

const feedPosts = computed(() => (activeTab.value === 'nearby' ? nearbyPosts.value : store.posts))
const visiblePosts = computed(() => feedPosts.value.slice(0, visibleCount.value))
const hasMore = computed(() => visibleCount.value < feedPosts.value.length)

function onScroll(event) {
  const el = event.target
  if (hasMore.value && el.scrollTop + el.clientHeight >= el.scrollHeight - 200) {
    visibleCount.value += PAGE_SIZE
  }
}

function selectTab(value) {
  if (value === 'nearby' && !locationState.resolvedCityId) {
    switchToNearbyOnPick.value = true
    openPicker()
    return
  }
  activeTab.value = value
}

function openLocationPill() {
  switchToNearbyOnPick.value = false
  openPicker()
}

function onLocationPicked(cityId) {
  setManualCity(cityId)
  if (switchToNearbyOnPick.value) {
    activeTab.value = 'nearby'
    switchToNearbyOnPick.value = false
  }
}
</script>

<template>
  <div class="home">
    <PullToRefresh class="feed-scroll" :on-refresh="store.refresh" @scroll="onScroll">
      <div class="feed-list">
        <TabBar class="feed-tabs" :tabs="FEED_TABS" :model-value="activeTab" @update:model-value="selectTab" />

        <button v-if="activeTab === 'nearby' && cityName" class="location-label" @click="openLocationPill">
          <Icon icon="iconoir:map-pin" width="16" height="16" />
          {{ cityName }}
        </button>

        <PostCard v-for="post in visiblePosts" :key="post.id" :post="post" />
        <p v-if="!visiblePosts.length" class="empty">
          {{ activeTab === 'nearby' ? 'No posts near you yet.' : 'No posts in this category yet.' }}
        </p>
      </div>
    </PullToRefresh>

    <LocationPickerSheet
      :open="locationState.isPickerOpen"
      :model-value="locationState.resolvedCityId"
      @update:model-value="onLocationPicked"
      @close="closePicker"
    />
  </div>
</template>

<style scoped>
.home {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.feed-scroll {
  flex: 1;
  min-height: 0;
}

.feed-list {
  display: flex;
  flex-direction: column;
  padding: 72px 12px 88px 16px;
  --feed-pad-left: 16px;
  --feed-pad-right: 12px;
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 40px 0;
}

.location-label {
  align-self: stretch;
  width: calc(100% + var(--feed-pad-left) + var(--feed-pad-right));
  margin-left: calc(var(--feed-pad-left) * -1);
  display: flex;
  align-items: center;
  gap: 7px;
  border: none;
  background: none;
  color: var(--color-text-secondary);
  padding: 12px var(--feed-pad-right) 12px var(--feed-pad-left);
  font-size: 15px;
  margin-top: 4px;
  margin-bottom: 4px;
  text-align: left;
}

.feed-tabs {
  margin-bottom: 4px;
}
</style>
