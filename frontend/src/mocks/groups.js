import { reactive } from 'vue'

// Group + GroupMembership entities per docs/02-data-model.md
// Reactive so member_count updates live when users join/leave.
export const groups = reactive([
  {
    id: 'g1',
    name: 'Bandung Morning Riders',
    photo_url: 'https://picsum.photos/seed/gowes-bandung/300/300',
    description: 'Casual group ride every Sunday morning, route around Dago and nearby.',
    visibility: 'public',
    member_count: 3,
    created_by: 'u1',
    location_city_id: 'city-bandung',
    blocked_user_ids: [],
  },
  {
    id: 'g2',
    name: 'MTB Trail Hunter Bogor',
    photo_url: 'https://picsum.photos/seed/mtb-bogor/300/300',
    description: 'Downhill & trail community — sharing routes and part setups.',
    visibility: 'public',
    member_count: 2,
    created_by: 'u6',
    location_city_id: 'city-bogor',
    blocked_user_ids: [],
  },
  {
    id: 'g3',
    name: 'Gravel Explorer Bandung',
    photo_url: 'https://picsum.photos/seed/gravel-bandung/300/300',
    description: 'Exploring West Java gravel routes every weekend.',
    visibility: 'public',
    member_count: 1,
    created_by: 'u7',
    location_city_id: 'city-bandung',
    blocked_user_ids: [],
  },
])

export const groupMemberships = [
  { group_id: 'g1', user_id: 'u1', joined_at: '2024-11-05T08:00:00Z' },
  { group_id: 'g1', user_id: 'u3', joined_at: '2025-03-22T09:00:00Z' },
  { group_id: 'g1', user_id: 'u4', joined_at: '2025-05-15T09:00:00Z' },
  { group_id: 'g2', user_id: 'u6', joined_at: '2024-08-20T09:00:00Z' },
  { group_id: 'g2', user_id: 'u2', joined_at: '2025-01-20T09:00:00Z' },
  { group_id: 'g3', user_id: 'u7', joined_at: '2025-02-10T09:00:00Z' },
]

export function getGroupById(id) {
  return groups.find((group) => group.id === id)
}
