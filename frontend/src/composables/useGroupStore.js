import { reactive } from 'vue'
import { groups, groupMemberships, currentUser, addPoints } from '../mocks'

const state = reactive({
  memberships: groupMemberships.map((m) => ({ ...m })),
})

export function useGroupStore() {
  function isJoined(groupId) {
    return state.memberships.some((m) => m.group_id === groupId && m.user_id === currentUser.id)
  }

  function membersOf(groupId) {
    return state.memberships.filter((m) => m.group_id === groupId).map((m) => m.user_id)
  }

  function isOwner(groupId) {
    const group = groups.find((g) => g.id === groupId)
    return group ? group.created_by === currentUser.id : false
  }

  function isBlocked(groupId, userId) {
    const group = groups.find((g) => g.id === groupId)
    return group ? (group.blocked_user_ids || []).includes(userId) : false
  }

  function toggleMembership(groupId) {
    const group = groups.find((g) => g.id === groupId)
    if (!group) return
    if (isBlocked(groupId, currentUser.id)) return

    const idx = state.memberships.findIndex(
      (m) => m.group_id === groupId && m.user_id === currentUser.id,
    )
    if (idx === -1) {
      state.memberships.push({
        group_id: groupId,
        user_id: currentUser.id,
        joined_at: new Date().toISOString(),
      })
      group.member_count += 1
      addPoints(1)
    } else {
      state.memberships.splice(idx, 1)
      group.member_count -= 1
    }
  }

  // Owner-only: removes the member and prevents them from rejoining (toggleMembership
  // no-ops for a blocked user, see isBlocked guard above).
  function blockUser(groupId, userId) {
    const group = groups.find((g) => g.id === groupId)
    if (!group) return
    if (!group.blocked_user_ids) group.blocked_user_ids = []
    if (!group.blocked_user_ids.includes(userId)) group.blocked_user_ids.push(userId)

    const idx = state.memberships.findIndex((m) => m.group_id === groupId && m.user_id === userId)
    if (idx !== -1) {
      state.memberships.splice(idx, 1)
      group.member_count = Math.max(0, group.member_count - 1)
    }
  }

  // Owner-only: edits name/description/photo of an existing group.
  function updateGroup(groupId, { name, description, photo_url } = {}) {
    const group = groups.find((g) => g.id === groupId)
    if (!group) return
    if (name != null) group.name = name.trim()
    if (description != null) group.description = description.trim()
    if (photo_url != null) group.photo_url = photo_url
  }

  // Owner-only: permanently removes the group and every membership in it.
  // Caller (Group Detail) is also responsible for removing the group's posts
  // from the feed store, which useGroupStore can't reach without a circular import.
  function deleteGroup(groupId) {
    const idx = groups.findIndex((g) => g.id === groupId)
    if (idx === -1) return
    groups.splice(idx, 1)
    for (let i = state.memberships.length - 1; i >= 0; i -= 1) {
      if (state.memberships[i].group_id === groupId) state.memberships.splice(i, 1)
    }
  }

  function createGroup({ name, photo_url, description, location_city_id = null }) {
    const group = {
      id: `g-${Date.now()}`,
      name: name.trim(),
      photo_url,
      description: description.trim(),
      visibility: 'public',
      member_count: 1,
      created_by: currentUser.id,
      location_city_id,
      blocked_user_ids: [],
    }
    groups.push(group)
    state.memberships.push({
      group_id: group.id,
      user_id: currentUser.id,
      joined_at: new Date().toISOString(),
    })
    addPoints(1)
    return group
  }

  return {
    groups,
    isJoined,
    membersOf,
    isOwner,
    isBlocked,
    toggleMembership,
    blockUser,
    updateGroup,
    deleteGroup,
    createGroup,
  }
}
