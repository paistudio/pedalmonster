export { users, getUserById, currentUser, addPoints } from './users'
export { posts, getPostById, getPostsByType, incomingPost } from './posts'
export { comments, getCommentsForPost } from './comments'
export { groups, groupMemberships, getGroupById } from './groups'
export { RANK_TIERS, getRankForPoints } from './rank'
export { cities, getCityById, findCityByName } from './cities'

import { posts } from './posts'
import { getUserById } from './users'

// Mirrors GET /api/feed — mixed post types, newest first, author attached.
export function getFeed() {
  return [...posts]
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    .map((post) => ({ ...post, author: getUserById(post.user_id) }))
}
