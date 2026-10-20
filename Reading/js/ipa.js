import { normalizeWord } from './matcher.js';

/** Show IPA and require practice after this many misreads (>= 5). */
export const MISREAD_PRACTICE_THRESHOLD = 5;

const IPA_CACHE_KEY = 'reading-aloud-ipa-cache';
const memoryCache = new Map();
/** Words whose IPA was typed by the user — auto-lookup must not overwrite. */
const manualIpaKeys = new Set();

/**
 * @param {string} word
 * @returns {string}
 */
function cacheKey(word) {
  return normalizeWord(word);
}

function loadPersistentCache() {
  try {
    const raw = localStorage.getItem(IPA_CACHE_KEY);
    if (!raw) return;
    const parsed = JSON.parse(raw);
    if (!parsed || typeof parsed !== 'object') return;
    for (const [key, value] of Object.entries(parsed)) {
      if (typeof value === 'string' && value) memoryCache.set(key, value);
    }
  } catch {
    /* ignore */
  }
}

function savePersistentCache() {
  try {
    const payload = Object.fromEntries(memoryCache.entries());
    localStorage.setItem(IPA_CACHE_KEY, JSON.stringify(payload));
  } catch {
    /* ignore quota */
  }
}

loadPersistentCache();

/**
 * @param {unknown} phonetics
 * @returns {string | null}
 */
function pickPhonetic(phonetics) {
  if (!Array.isArray(phonetics)) return null;
  for (const item of phonetics) {
    const text = item?.text;
    if (typeof text === 'string' && text.trim()) return text.trim();
  }
  return null;
}

/**
 * @param {string} word
 * @returns {Promise<string | null>}
 */
export async function lookupIpa(word) {
  const key = cacheKey(word);
  if (!key) return null;
  if (manualIpaKeys.has(key)) return memoryCache.get(key) || null;
  if (memoryCache.has(key)) return memoryCache.get(key) || null;

  try {
    const response = await fetch(
      `https://api.dictionaryapi.dev/api/v2/entries/en/${encodeURIComponent(key)}`,
    );
    if (manualIpaKeys.has(key)) return memoryCache.get(key) || null;
    if (!response.ok) {
      memoryCache.set(key, '');
      savePersistentCache();
      return null;
    }
    const data = await response.json();
    const entry = Array.isArray(data) ? data[0] : null;
    const ipa = pickPhonetic(entry?.phonetics) ?? pickPhonetic(entry?.phonetic);
    const value = ipa || '';
    if (manualIpaKeys.has(key)) return memoryCache.get(key) || null;
    memoryCache.set(key, value);
    savePersistentCache();
    return value || null;
  } catch {
    return manualIpaKeys.has(key) ? memoryCache.get(key) || null : null;
  }
}

/**
 * @param {string[]} words
 * @returns {Promise<void>}
 */
export async function prefetchIpa(words) {
  const unique = [...new Set(words.map(cacheKey).filter(Boolean))];
  await Promise.all(unique.map((word) => lookupIpa(word)));
}

/**
 * @param {string} word
 * @returns {string | null}
 */
export function getCachedIpa(word) {
  const key = cacheKey(word);
  if (!key || !memoryCache.has(key)) return null;
  const value = memoryCache.get(key);
  return value ? value : null;
}

/**
 * @param {string} word
 * @param {string} ipa
 * @param {{ manual?: boolean }} [options]
 */
export function setCachedIpa(word, ipa, options = {}) {
  const key = cacheKey(word);
  if (!key) return;
  const value = String(ipa || '').trim();
  memoryCache.set(key, value);
  if (options.manual) manualIpaKeys.add(key);
  savePersistentCache();
}

/**
 * @param {string} word
 * @returns {boolean}
 */
export function hasCachedIpaAttempt(word) {
  const key = cacheKey(word);
  return Boolean(key && memoryCache.has(key));
}

/**
 * @param {number} misreadCount
 * @returns {boolean}
 */
export function needsPronunciationHelp(misreadCount) {
  return misreadCount >= MISREAD_PRACTICE_THRESHOLD;
}
