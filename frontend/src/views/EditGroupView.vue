<script setup>
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Icon } from '@iconify/vue'
import PhotoPicker from '../components/create/PhotoPicker.vue'
import { useGroupStore } from '../composables/useGroupStore'

const route = useRoute()
const router = useRouter()
const store = useGroupStore()

const group = computed(() => store.groups.find((g) => g.id === route.params.id))
const isOwner = computed(() => (group.value ? store.isOwner(group.value.id) : false))

const name = ref(group.value?.name ?? '')
const description = ref(group.value?.description ?? '')
const photos = ref(group.value?.photo_url ? [group.value.photo_url] : [])

const errors = reactive({})

function validate() {
  errors.name = name.value.trim() ? '' : 'Group name is required'
  errors.description = description.value.trim() ? '' : 'Add a short description'
  return !errors.name && !errors.description
}

function submit() {
  if (!validate()) return
  store.updateGroup(group.value.id, {
    name: name.value,
    description: description.value,
    photo_url: photos.value[0] ?? group.value.photo_url,
  })
  router.replace(`/groups/${group.value.id}`)
}
</script>

<template>
  <div v-if="group && isOwner" class="settings-screen">
    <header class="screen-header">
      <button class="icon-btn" aria-label="Back" @click="router.back()">
        <Icon icon="iconoir:arrow-left" width="20" height="20" />
      </button>
      <span class="screen-title">Edit Group</span>
      <div class="spacer" />
    </header>

    <div class="settings-body">
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
        <label class="field-label">Group photo</label>
        <PhotoPicker v-model="photos" :max="1" />
      </div>

      <button class="btn btn-primary" @click="submit">Save changes</button>
    </div>
  </div>

  <div v-else class="not-found">
    <p>Group not found.</p>
    <button class="btn btn-secondary" @click="router.push('/groups')">Back to Groups</button>
  </div>
</template>

<style scoped>
.settings-screen {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.screen-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px;
}

.screen-title {
  font-size: 16px;
  color: var(--color-text);
}

.spacer {
  width: 40px;
  flex-shrink: 0;
}

.icon-btn {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 999px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  color: var(--color-text);
  transition: background-color 0.15s ease, transform 0.1s ease;
}

.icon-btn:active {
  background: rgba(255, 255, 255, 0.08);
  transform: scale(0.94);
}

.settings-body {
  flex: 1;
  overflow-y: auto;
  padding: 4px 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.btn {
  flex: none;
  width: 100%;
}

.not-found {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  color: var(--color-text-muted);
}
</style>
