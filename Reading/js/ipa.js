import { normalizeWord } from './matcher.js';

/** Build id — change when IPA logic changes (helps verify cache refresh). */
export const IPA_MODULE_BUILD = '20261020-no-network';

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
      if (typeof value === 'string') memoryCache.set(key, value);
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
 * @param {string} key
 * @returns {string | null}
 */
function cachedIpaForKey(key) {
  if (!key || !memoryCache.has(key)) return null;
  const value = memoryCache.get(key);
  return value ? value : null;
}

/**
 * IPA: cache + nhập tay trong bảng từ khó. Không gọi API ngoài (tránh CORS trên Live Server).
 * @param {string} word
 * @returns {Promise<string | null>}
 */
export async function lookupIpa(word) {
  const key = cacheKey(word);
  if (!key) return null;
  if (manualIpaKeys.has(key)) return memoryCache.get(key) || null;
  if (memoryCache.has(key)) return cachedIpaForKey(key);
  memoryCache.set(key, '');
  savePersistentCache();
  return null;
}

/**
 * @param {string[]} words
 * @returns {Promise<void>}
 */
export async function prefetchIpa(words) {
  const unique = [...new Set(words.map(cacheKey).filter(Boolean))];
  for (const key of unique) {
    await lookupIpa(key);
  }
}

/**
 * @param {string} word
 * @returns {string | null}
 */
export function getCachedIpa(word) {
  const key = cacheKey(word);
  return cachedIpaForKey(key);
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

/** @deprecated Online lookup removed — always false. */
export function isRemoteIpaLookupEnabled() {
  return false;
}

/** @deprecated Online lookup removed. */
export function getRemoteIpaDisabledReason() {
  return 'no-network-ipa';
}
