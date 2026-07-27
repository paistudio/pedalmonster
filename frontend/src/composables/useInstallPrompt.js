import { ref } from 'vue'

const deferredPrompt = ref(null)
const isInstallable = ref(false)

window.addEventListener('beforeinstallprompt', (event) => {
  event.preventDefault()
  deferredPrompt.value = event
  isInstallable.value = true
})

window.addEventListener('appinstalled', () => {
  deferredPrompt.value = null
  isInstallable.value = false
})

export function useInstallPrompt() {
  async function promptInstall() {
    if (!deferredPrompt.value) return
    deferredPrompt.value.prompt()
    await deferredPrompt.value.userChoice
    deferredPrompt.value = null
    isInstallable.value = false
  }

  return { isInstallable, promptInstall }
}
