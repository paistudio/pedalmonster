<script setup>
import { computed } from 'vue'

const props = defineProps({
  rank: { type: String, required: true },
})

// Tier colors drawn from design.md's illustrative accent palette.
// Pedal Monster (top tier) reuses the rare white-filled-pill treatment as a prestige marker.
const RANK_STYLES = {
  Cub: { bg: '#7d8187', text: '#ffffff' },
  Scout: { bg: '#a0c3ec', text: '#0a0a0a' },
  Rider: { bg: '#ff7a17', text: '#ffffff' },
  Alpha: { bg: '#7c3aed', text: '#ffffff' },
  'Pedal Monster': { bg: '#ffffff', text: '#0a0a0a' },
}

const style = computed(() => RANK_STYLES[props.rank] ?? RANK_STYLES.Cub)
</script>

<template>
  <span class="rank-badge" :style="{ background: style.bg, color: style.text }">{{ rank }}</span>
</template>

<style scoped>
.rank-badge {
  display: inline-flex;
  align-items: center;
  font-size: 10px;
  font-weight: 400;
  padding: 2px 7px;
  border-radius: 999px;
  line-height: 1.4;
  white-space: nowrap;
}
</style>
