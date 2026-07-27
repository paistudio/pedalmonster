import { createApp } from 'vue'
import { addCollection } from '@iconify/vue'
import iconoirIcons from '@iconify-json/iconoir/icons.json'
import fa6SolidIcons from '@iconify-json/fa6-solid/icons.json'
import './style.css'
import './styles/forms.css'
import App from './App.vue'
import router from './router'

addCollection(iconoirIcons)
addCollection(fa6SolidIcons)

createApp(App).use(router).mount('#app')

// Dismisses the preloader overlay in index.html once the first route has
// actually rendered. See docs/16-app-preloader-splash.md
router.isReady().then(() => window.__pmAppReady?.())
