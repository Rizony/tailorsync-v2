/**
 * Utility to merge tailwind classes safely.
 * Returns a space-separated string of truthy class names.
 */
export function cn(...classes: (string | undefined | null | false)[]) {
  return classes.filter(Boolean).join(' ').trim();
}

/**
 * Convenience to format dates globally
 */
export function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });
}
