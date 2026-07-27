import { computed, reactive } from 'vue'

// Shared between MarketView (the listing list) and App.vue (the top app bar's
// search input + filter icon while on the Market screen) — module-level
// singleton so both read/write the same state without prop-drilling through the shell.
const state = reactive({
  query: '',
  isFilterOpen: false,
  filters: {
    category: 'all',
    condition: 'all',
    priceMin: '',
    priceMax: '',
    locationCityId: null,
    sort: 'newest',
  },
})

export function useMarketFilters() {
  const activeFilterCount = computed(() => {
    let count = 0
    if (state.filters.category !== 'all') count += 1
    if (state.filters.condition !== 'all') count += 1
    if (state.filters.priceMin) count += 1
    if (state.filters.priceMax) count += 1
    if (state.filters.locationCityId) count += 1
    if (state.filters.sort !== 'newest') count += 1
    return count
  })

  function openFilters() {
    state.isFilterOpen = true
  }

  function closeFilters() {
    state.isFilterOpen = false
  }

  return {
    query: computed({
      get: () => state.query,
      set: (value) => { state.query = value },
    }),
    isFilterOpen: computed(() => state.isFilterOpen),
    filters: state.filters,
    activeFilterCount,
    openFilters,
    closeFilters,
  }
}
