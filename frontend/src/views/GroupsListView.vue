<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import TabBar from '../components/TabBar.vue'
import { useGroupStore } from '../composables/useGroupStore'
import { useUserLocation } from '../composables/useUserLocation'
import { distanceBetweenCities } from '../utils/geo'

const GROUP_TABS = [
  { value: 'mine', label: 'My Groups' },
  { value: 'discover', label: 'Discover' },
]

const router = useRouter()
const store = useGroupStore()
const { state: locationState } = useUserLocation()
const activeTab = ref('mine')

const visibleGroups = computed(() => {
  const filtered = store.groups.filter((group) =>
    activeTab.value === 'mine' ? store.isJoined(group.id) : !store.isJoined(group.id),
  )

  if (activeTab.value === 'discover' && locationState.resolvedCityId) {
    return [...filtered].sort((a, b) => {
      const distA = distanceBetweenCities(locationState.resolvedCityId, a.location_city_id)
      const distB = distanceBetweenCities(locationState.resolvedCityId, b.location_city_id)
      if (distA == null) return 1
      if (distB == null) return -1
      return distA - distB
    })
  }

  return filtered
})
</script>

<template>
  <div class="groups">
    <TabBar class="groups-tabs" :tabs="GROUP_TABS" v-model="activeTab" />

    <div class="group-list">
      <div
        v-for="group in visibleGroups"
        :key="group.id"
        class="group-row"
        @click="router.push(`/groups/${group.id}`)"
      >
        <img class="group-photo" :src="group.photo_url" :alt="group.name" />
        <div class="group-meta">
          <span class="group-name">{{ group.name }}</span>
          <span class="group-members">{{ group.member_count }} members</span>
        </div>
        <button
          class="join-btn"
          :class="{ 'join-btn--joined': store.isJoined(group.id) }"
          @click.stop="store.toggleMembership(group.id)"
        >
          {{ store.isJoined(group.id) ? 'Joined' : 'Join' }}
        </button>
      </div>

      <p v-if="!visibleGroups.length" class="empty">
        {{ activeTab === 'mine' ? "You haven't joined any groups yet." : 'No more groups to discover.' }}
      </p>
    </div>
  </div>
</template>

<style scoped>
.groups {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.groups-tabs {
  padding: 76px 16px 0;
  flex-shrink: 0;
}

.group-list {
  flex: 1;
  overflow-y: auto;
  padding: 4px 16px 88px;
}

.group-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 0;
  border-bottom: 1px solid var(--color-border);
}

.group-row:last-child {
  border-bottom: none;
}

.group-photo {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
}

.group-meta {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0;
  line-height: 1.8;
}

.group-name {
  font-size: 14px;
  line-height: 1.8;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.group-members {
  font-size: 12px;
  line-height: 1.8;
  color: var(--color-text-muted);
}

.join-btn {
  flex-shrink: 0;
  border: 1px solid var(--color-pill-border);
  background: transparent;
  color: var(--color-text);
  padding: 6px 16px;
  border-radius: 999px;
  font-size: 12px;
}

.join-btn--joined {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: var(--color-on-primary);
}

.empty {
  text-align: center;
  color: var(--color-text-muted);
  font-size: 13px;
  padding: 40px 0;
}
</style>
