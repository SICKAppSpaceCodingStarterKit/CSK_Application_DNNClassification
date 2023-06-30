export function convertToList(value) {
  return JSON.parse(value)
}

export function invertStatusString(value) {
  return value == 'true' ? false: true
}