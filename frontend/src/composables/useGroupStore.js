import { reactive } from 'vue'
import { supabase } from '../lib/supabase'
import { useAuth } from './useAuth'

const state = reactive({
  groups: [],
  loaded: false,
  myMembershipGroupIds: [],
  myMembershipsLoaded: false,
  membersByGroup: {},
})

const { state: authState } = useAuth()

async function loadGroups() {
  const { data, error } = await supabase.from('groups').select('*').order('name')
  if (error) return
  state.groups.splice(0, state.groups.length, ...data)
  state.loaded = true
}

let loadPromise = null
function ensureLoaded() {
  if (!loadPromise) loadPromise = loadGroups()
  return loadPromise
}

// Kept separate from ensureLoaded/loadPromise (which only ever run once) because
// authState.currentUser may still be null the first time this module is touched —
// router navigation and useAuth's init() race independently. Only flip
// myMembershipsLoaded once currentUser is actually known, so a later call (once
// login resolves) retries instead of caching an empty result forever.
function ensureMyMembershipsLoaded() {
  if (!authState.currentUser || state.myMembershipsLoaded) return Promise.resolve()
  return supabase
    .from('group_memberships')
    .select('group_id')
    .eq('user_id', authState.currentUser.id)
    .then(({ data }) => {
      state.myMembershipGroupIds.splice(0, state.myMembershipGroupIds.length, ...(data || []).map((m) => m.group_id))
      state.myMembershipsLoaded = true
    })
}

// Attaches each membership's profile — same "separate query + client-side merge" pattern
// as useFeedStore's attachAuthors, so the exact FK relationship name never matters.
async function loadMembers(groupId) {
  const { data: memberships } = await supabase
    .from('group_memberships')
    .select('user_id')
    .eq('group_id', groupId)
  const userIds = (memberships || []).map((m) => m.user_id)
  if (!userIds.length) {
    state.membersByGroup[groupId] = []
    return
  }
  const { data: profiles } = await supabase.from('profiles').select('*').in('id', userIds)
  state.membersByGroup[groupId] = profiles || []
}

export function useGroupStore() {
  ensureLoaded()
  ensureMyMembershipsLoaded()

  function isJoined(groupId) {
    return state.myMembershipGroupIds.includes(groupId)
  }

  function membersOf(groupId) {
    return state.membersByGroup[groupId] || []
  }

  function isOwner(groupId) {
    const group = state.groups.find((g) => g.id === groupId)
    return group ? group.created_by === authState.currentUser?.id : false
  }

  function isBlocked(groupId, userId) {
    const group = state.groups.find((g) => g.id === groupId)
    return group ? (group.blocked_user_ids || []).includes(userId) : false
  }

  async function toggleMembership(groupId) {
    const group = state.groups.find((g) => g.id === groupId)
    if (!group) return
    const userId = authState.currentUser.id

    if (isJoined(groupId)) {
      const { error } = await supabase
        .from('group_memberships')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', userId)
      if (error) return
      const idx = state.myMembershipGroupIds.indexOf(groupId)
      if (idx !== -1) state.myMembershipGroupIds.splice(idx, 1)
      group.member_count = Math.max(0, group.member_count - 1)
      if (state.membersByGroup[groupId]) {
        state.membersByGroup[groupId] = state.membersByGroup[groupId].filter((u) => u.id !== userId)
      }
    } else {
      // Uses the group-join Edge Function rather than a plain insert — it encodes the
      // "silently no-op if blocked" business logic (RLS alone would throw an error instead).
      const { data, error } = await supabase.functions.invoke('group-join', {
        body: { group_id: groupId },
      })
      if (error || !data?.joined) return
      state.myMembershipGroupIds.push(groupId)
      group.member_count += 1
      if (state.membersByGroup[groupId]) {
        state.membersByGroup[groupId].push(authState.currentUser)
      }
    }
  }

  // Owner-only: removes the member and prevents them from rejoining (the group-join
  // Edge Function no-ops for a blocked user, and the RLS insert policy backstops it).
  async function blockUser(groupId, userId) {
    const group = state.groups.find((g) => g.id === groupId)
    if (!group) return
    const nextBlocked = [...new Set([...(group.blocked_user_ids || []), userId])]
    const { error } = await supabase.from('groups').update({ blocked_user_ids: nextBlocked }).eq('id', groupId)
    if (error) return
    group.blocked_user_ids = nextBlocked

    const { error: deleteError } = await supabase
      .from('group_memberships')
      .delete()
      .eq('group_id', groupId)
      .eq('user_id', userId)
    if (!deleteError) {
      group.member_count = Math.max(0, group.member_count - 1)
      if (state.membersByGroup[groupId]) {
        state.membersByGroup[groupId] = state.membersByGroup[groupId].filter((u) => u.id !== userId)
      }
    }
  }

  // Owner-only: edits name/description/photo of an existing group.
  async function updateGroup(groupId, { name, description, photo_url } = {}) {
    const group = state.groups.find((g) => g.id === groupId)
    if (!group) return
    const patch = {}
    if (name != null) patch.name = name.trim()
    if (description != null) patch.description = description.trim()
    if (photo_url != null) patch.photo_url = photo_url
    if (!Object.keys(patch).length) return
    const { error } = await supabase.from('groups').update(patch).eq('id', groupId)
    if (!error) Object.assign(group, patch)
  }

  // Owner-only: permanently removes the group. Memberships and group posts cascade
  // server-side (FK ON DELETE CASCADE / cascade_group_post_delete trigger).
  async function deleteGroup(groupId) {
    const { error } = await supabase.from('groups').delete().eq('id', groupId)
    if (error) return
    const idx = state.groups.findIndex((g) => g.id === groupId)
    if (idx !== -1) state.groups.splice(idx, 1)
    delete state.membersByGroup[groupId]
    const memberIdx = state.myMembershipGroupIds.indexOf(groupId)
    if (memberIdx !== -1) state.myMembershipGroupIds.splice(memberIdx, 1)
  }

  // auto_join_own_group() trigger handles adding the creator's membership + points
  // server-side, so this only needs to insert the group row itself.
  async function createGroup({ name, photo_url, description, location_city_id = null }) {
    const { data, error } = await supabase
      .from('groups')
      .insert({
        name: name.trim(),
        photo_url,
        description: description.trim(),
        created_by: authState.currentUser.id,
        location_city_id,
      })
      .select()
      .single()
    if (error) throw error
    // auto_join_own_group() joins the creator via a separate cascaded statement after this
    // INSERT's RETURNING already captured the row, so member_count here is stale (0) — it's
    // always exactly 1 immediately after creation, so set it locally rather than refetching.
    data.member_count = 1
    state.groups.push(data)
    state.myMembershipGroupIds.push(data.id)
    return data
  }

  return {
    groups: state.groups,
    isJoined,
    membersOf,
    loadMembers,
    isOwner,
    isBlocked,
    toggleMembership,
    blockUser,
    updateGroup,
    deleteGroup,
    createGroup,
  }
}
