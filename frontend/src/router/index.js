import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/market', name: 'market', component: () => import('../views/MarketView.vue') },
    {
      path: '/market/:id',
      name: 'listing-detail',
      component: () => import('../views/ListingDetailView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/posts/:id',
      name: 'post-detail',
      component: () => import('../views/PostDetailView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/posts/:id/edit',
      name: 'post-edit',
      component: () => import('../views/EditPostView.vue'),
      meta: { hideShell: true },
    },
    { path: '/groups', name: 'groups', component: () => import('../views/GroupsListView.vue') },
    {
      path: '/groups/create',
      name: 'group-create',
      component: () => import('../views/CreateGroupView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/groups/:id',
      name: 'group-detail',
      component: () => import('../views/GroupDetailView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/groups/:id/edit',
      name: 'group-edit',
      component: () => import('../views/EditGroupView.vue'),
      meta: { hideShell: true },
    },
    { path: '/profile', name: 'profile', component: () => import('../views/ProfileView.vue') },
    {
      path: '/profile/:id',
      name: 'user-profile',
      component: () => import('../views/UserProfileView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('../views/RegisterView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/chat/:userId',
      name: 'chat-thread',
      component: () => import('../views/ChatThreadView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/topics/:tag',
      name: 'topic-detail',
      component: () => import('../views/TopicDetailView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/create/listing',
      name: 'create-listing',
      component: () => import('../views/create/CreateListingView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/create/post',
      name: 'create-post',
      component: () => import('../views/create/CreatePostView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/create/group',
      name: 'create-group',
      component: () => import('../views/create/CreateGroupPostView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/settings/account',
      name: 'account-settings',
      component: () => import('../views/AccountSettingsView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/liked',
      name: 'liked-posts',
      component: () => import('../views/LikedPostsView.vue'),
      meta: { hideShell: true },
    },
    {
      path: '/report',
      name: 'report-problem',
      component: () => import('../views/ReportProblemView.vue'),
      meta: { hideShell: true },
    },
  ],
})

export default router
