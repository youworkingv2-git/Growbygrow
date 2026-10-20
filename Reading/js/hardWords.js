import { normalizeWord } from './matcher.js';
import { MISREAD_PRACTICE_THRESHOLD } from './ipa.js';

export const HARD_WORDS_KEY = 'reading-aloud-hard-words';

/**
 * @typedef {Object} HardWordEntry
 * @property {string} id
 * @property {string} display
 * @property {string} normalized
 * @property {string|null} ipa
 * @property {boolean} [ipaManual]
 * @property {number} misreadCount
 * @property {boolean} selected
 * @property {string} lessonId
 * @property {string} lessonTitle
 * @property {string} sentenceText
 * @property {number} addedAt
 * @property {number} updatedAt
 * @property {boolean} [manual]
 */

/**
 * @param {unknown} value
 * @returns {HardWordEntry[]}
 */
export function normalizeHardWordList(value) {
  if (!Array.isArray(value)) return [];
  /** @type {HardWordEntry[]} */
  const items = [];
  for (const raw of value) {
    if (!raw || typeof raw !== 'object') continue;
    const normalized = normalizeWord(String(raw.normalized ?? raw.display ?? ''));
    if (!normalized) continue;
    const display = String(raw.display ?? normalized).trim() || normalized;
    const misreadCount = Number(raw.misreadCount);
    const manual = Boolean(raw.manual);
    items.push({
      id: String(raw.id ?? normalized),
      display,
      normalized,
      ipa: typeof raw.ipa === 'string' && raw.ipa ? raw.ipa : null,
      ipaManual: Boolean(raw.ipaManual),
      misreadCount: manual
        ? (Number.isFinite(misreadCount) ? Math.max(0, misreadCount) : 0)
        : (Number.isFinite(misreadCount) ? Math.max(misreadCount, MISREAD_PRACTICE_THRESHOLD) : MISREAD_PRACTICE_THRESHOLD),
      selected: raw.selected !== false,
      lessonId: String(raw.lessonId ?? ''),
      lessonTitle: String(raw.lessonTitle ?? ''),
      sentenceText: String(raw.sentenceText ?? ''),
      addedAt: Number(raw.addedAt) || Date.now(),
      updatedAt: Number(raw.updatedAt) || Date.now(),
      manual,
    });
  }
  return items;
}

/**
 * @returns {HardWordEntry[]}
 */
export function loadHardWords() {
  try {
    const raw = localStorage.getItem(HARD_WORDS_KEY);
    return normalizeHardWordList(raw ? JSON.parse(raw) : []);
  } catch {
    return [];
  }
}

/**
 * @param {HardWordEntry[]} words
 */
export function saveHardWords(words) {
  try {
    localStorage.setItem(HARD_WORDS_KEY, JSON.stringify(words));
  } catch {
    /* ignore quota */
  }
}

/**
 * @param {HardWordEntry[]} words
 * @param {Partial<HardWordEntry> & { display: string, normalized: string }} input
 * @returns {HardWordEntry[]}
 */
export function upsertHardWord(words, input) {
  const normalized = normalizeWord(input.normalized || input.display);
  if (!normalized) return words;
  const display = String(input.display ?? normalized).trim() || normalized;
  const now = Date.now();
  const nextCount = Math.max(
    MISREAD_PRACTICE_THRESHOLD,
    Number(input.misreadCount) || MISREAD_PRACTICE_THRESHOLD,
  );
  const existing = words.find((item) => item.id === normalized);
  if (existing) {
    existing.display = display.length >= existing.display.length ? display : existing.display;
    existing.misreadCount = Math.max(existing.misreadCount, nextCount);
    existing.lessonId = input.lessonId ?? existing.lessonId;
    existing.lessonTitle = input.lessonTitle ?? existing.lessonTitle;
    existing.sentenceText = input.sentenceText ?? existing.sentenceText;
    if (input.ipa && !existing.ipaManual) existing.ipa = input.ipa;
    existing.updatedAt = now;
    return words;
  }
  words.push({
    id: normalized,
    display,
    normalized,
    ipa: input.ipa ?? null,
    ipaManual: false,
    misreadCount: nextCount,
    selected: true,
    lessonId: input.lessonId ?? '',
    lessonTitle: input.lessonTitle ?? '',
    sentenceText: input.sentenceText ?? '',
    addedAt: now,
    updatedAt: now,
    manual: false,
  });
  return words;
}

/**
 * @param {HardWordEntry[]} words
 * @param {{ id?: string, display: string, ipa?: string, sentenceText?: string }} input
 * @returns {{ words: HardWordEntry[], id: string | null, error?: string }}
 */
export function saveManualHardWord(words, input) {
  const display = String(input.display ?? '').trim();
  const normalized = normalizeWord(display);
  if (!normalized) return { words, id: null, error: 'empty' };

  const now = Date.now();
  const ipa = String(input.ipa ?? '').trim() || null;
  const sentenceText = String(input.sentenceText ?? '').trim();
  const editId = input.id ? String(input.id) : normalized;
  const existing =
    words.find((item) => item.id === editId) ||
    words.find((item) => item.id === normalized || item.normalized === normalized);

  if (existing) {
    const nextNormalized = normalized;
    if (nextNormalized !== existing.id && nextNormalized !== existing.normalized) {
      const duplicate = words.find(
        (item) =>
          item !== existing && (item.id === nextNormalized || item.normalized === nextNormalized),
      );
      if (duplicate) {
        duplicate.display = display;
        duplicate.ipa = ipa;
        duplicate.ipaManual = ipa != null;
        if (sentenceText) duplicate.sentenceText = sentenceText;
        duplicate.manual = true;
        duplicate.updatedAt = now;
        return { words, id: duplicate.id };
      }
      existing.id = nextNormalized;
      existing.normalized = nextNormalized;
    }
    existing.display = display;
    existing.ipa = ipa;
    existing.ipaManual = ipa != null;
    if (sentenceText) existing.sentenceText = sentenceText;
    existing.manual = true;
    existing.updatedAt = now;
    return { words, id: existing.id };
  }

  words.push({
    id: normalized,
    display,
    normalized,
    ipa,
    ipaManual: ipa != null,
    misreadCount: 0,
    selected: true,
    lessonId: '',
    lessonTitle: '',
    sentenceText,
    addedAt: now,
    updatedAt: now,
    manual: true,
  });
  return { words, id: normalized };
}

/**
 * @param {HardWordEntry[]} words
 * @param {string} id
 * @returns {HardWordEntry | undefined}
 */
export function getHardWordById(words, id) {
  return words.find((item) => item.id === id);
}

/**
 * @param {HardWordEntry[]} words
 * @param {string} id
 * @returns {HardWordEntry[]}
 */
export function removeHardWord(words, id) {
  return words.filter((item) => item.id !== id);
}

/**
 * @param {HardWordEntry[]} words
 * @param {string} id
 * @param {boolean} selected
 * @returns {HardWordEntry[]}
 */
export function setHardWordSelected(words, id, selected) {
  const item = words.find((entry) => entry.id === id);
  if (item) item.selected = selected;
  return words;
}

/**
 * @param {HardWordEntry[]} words
 * @param {boolean} selected
 * @returns {HardWordEntry[]}
 */
export function setAllHardWordsSelected(words, selected) {
  words.forEach((item) => {
    item.selected = selected;
  });
  return words;
}

/**
 * @param {HardWordEntry[]} words
 * @returns {HardWordEntry[]}
 */
export function getSelectedHardWords(words) {
  return words.filter((item) => item.selected);
}
