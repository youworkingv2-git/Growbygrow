/** @type {readonly number[]} */
export const PRONUNCIATION_ACCURACY_OPTIONS = [100, 95, 90, 85, 80];

const DEFAULT_ACCURACY = 100;

/** @type {number} */
let accuracyPercent = DEFAULT_ACCURACY;

/**
 * @param {unknown} value
 * @returns {number}
 */
export function normalizePronunciationAccuracy(value) {
  const n = Number(value);
  return PRONUNCIATION_ACCURACY_OPTIONS.includes(n) ? n : DEFAULT_ACCURACY;
}

/**
 * @returns {number}
 */
export function getPronunciationAccuracy() {
  return accuracyPercent;
}

/**
 * @param {unknown} percent
 */
export function setPronunciationAccuracy(percent) {
  accuracyPercent = normalizePronunciationAccuracy(percent);
}

/**
 * @param {string} a
 * @param {string} b
 * @returns {number}
 */
function levenshteinDistance(a, b) {
  if (a === b) return 0;
  if (!a.length) return b.length;
  if (!b.length) return a.length;

  /** @type {number[]} */
  let prev = Array.from({ length: b.length + 1 }, (_, i) => i);
  /** @type {number[]} */
  let curr = new Array(b.length + 1);

  for (let i = 0; i < a.length; i++) {
    curr[0] = i + 1;
    for (let j = 0; j < b.length; j++) {
      const cost = a[i] === b[j] ? 0 : 1;
      curr[j + 1] = Math.min(
        curr[j] + 1,
        prev[j + 1] + 1,
        prev[j] + cost,
      );
    }
    const next = prev;
    prev = curr;
    curr = next;
  }

  return prev[b.length];
}

/**
 * @param {string} a
 * @param {string} b
 * @returns {number}
 */
export function similarityPercent(a, b) {
  const maxLen = Math.max(a.length, b.length);
  if (maxLen === 0) return 100;
  const distance = levenshteinDistance(a, b);
  return ((maxLen - distance) / maxLen) * 100;
}

/**
 * Fuzzy match on canonical keys when exact match failed.
 *
 * @param {string} spokenKey
 * @param {string} targetKey
 * @returns {boolean}
 */
export function meetsPronunciationAccuracy(spokenKey, targetKey) {
  if (accuracyPercent >= 100) return false;
  if (!spokenKey || !targetKey) return false;
  if (spokenKey.startsWith('n:') || targetKey.startsWith('n:')) return false;
  const maxLen = Math.max(spokenKey.length, targetKey.length);
  if (maxLen < 3) return false;
  return similarityPercent(spokenKey, targetKey) >= accuracyPercent;
}
