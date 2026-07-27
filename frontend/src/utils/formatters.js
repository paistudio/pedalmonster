export function formatRelativeTime(dateString, now = new Date()) {
  const diffMs = now - new Date(dateString)
  const diffMin = diffMs / 60000
  if (diffMin < 1) return 'Just now'
  if (diffMin < 60) return `${Math.floor(diffMin)}m ago`
  const diffHour = diffMin / 60
  if (diffHour < 24) return `${Math.floor(diffHour)}h ago`
  const diffDay = diffHour / 24
  if (diffDay < 7) return `${Math.floor(diffDay)}d ago`
  return new Intl.DateTimeFormat('en-US', { day: 'numeric', month: 'short', year: 'numeric' }).format(
    new Date(dateString),
  )
}

export function formatPrice(amount) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0,
  }).format(amount)
}
