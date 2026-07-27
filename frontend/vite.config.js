import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'
import preloaderLogo from './build/preloader-logo.js'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    preloaderLogo(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg'],
      manifest: {
        name: 'Pedal Monster',
        short_name: 'Pedal Monster',
        description: 'Community platform for bike enthusiasts — marketplace, events, Q&A, groups.',
        theme_color: '#0A0A0A',
        background_color: '#0A0A0A',
        display: 'standalone',
        start_url: '/',
        scope: '/',
        icons: [
          { src: '/icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png' },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,svg,png}'],
      },
    }),
  ],
  server: {
    port: Number(process.env.PORT) || 5173,
    strictPort: true,
  },
})
