import { meetsPronunciationAccuracy } from './pronunciationAccuracy.js';

/** @type {Record<string, number>} */
const WORD_TO_NUM = {
  zero: 0,
  one: 1,
  two: 2,
  three: 3,
  four: 4,
  five: 5,
  six: 6,
  seven: 7,
  eight: 8,
  nine: 9,
  ten: 10,
  eleven: 11,
  twelve: 12,
  thirteen: 13,
  fourteen: 14,
  fifteen: 15,
  sixteen: 16,
  seventeen: 17,
  eighteen: 18,
  nineteen: 19,
  twenty: 20,
  thirty: 30,
  forty: 40,
  fifty: 50,
  sixty: 60,
  seventy: 70,
  eighty: 80,
  ninety: 90,
};

/**
 * Ignore punctuation when matching spoken words (?, !, ., ,, ;, …, quotes, …).
 * Keep letters, digits, apostrophes (I'm) and colons (6:00).
 * Fold curly apostrophes to ASCII so I'm / I’m compare equal.
 * @param {string} word
 * @returns {string}
 */
export function stripIgnoredPunctuation(word) {
  return String(word || '')
    .toLowerCase()
    .replace(/[\u2018\u2019\u201a\u2032\u02bc`´]/g, "'")
    .replace(/[^\p{L}\p{N}':]/gu, '')
    .replace(/^:+|:+$/g, '');
}

const SPELLING_ALIASES = {
  issac: 'isaac',
  ok: 'okay',
  grey: 'gray',
  whose: 'whos',
  lin: 'linh',
  lynn: 'linh',
  min: 'minh',
  minn: 'minh',
  ming: 'minh',
  hua: 'hoa',
  nwen: 'nguyen',
};

/**
 * One spoken word ↔ two lesson tokens (e.g. Vietnam / Viet Nam).
 * @type {Record<string, [string, string]>}
 */
export const COMPOUND_EXPANSIONS = {
  vietnam: ['viet', 'nam'],
};

/**
 * Common English contractions mapped to their 2-word expanded forms.
 * @type {Record<string, [string, string]>}
 */
export const CONTRACTION_EXPANSIONS = {
  "that's": ['that', 'is'],
  thats: ['that', 'is'],
  "it's": ['it', 'is'],
  its: ['it', 'is'],
  "what's": ['what', 'is'],
  whats: ['what', 'is'],
  "there's": ['there', 'is'],
  theres: ['there', 'is'],
  "here's": ['here', 'is'],
  heres: ['here', 'is'],
  "who's": ['who', 'is'],
  whos: ['who', 'is'],
  whose: ['who', 'is'],
  "how's": ['how', 'is'],
  hows: ['how', 'is'],
  "where's": ['where', 'is'],
  wheres: ['where', 'is'],
  "when's": ['when', 'is'],
  whens: ['when', 'is'],
  "he's": ['he', 'is'],
  hes: ['he', 'is'],
  "she's": ['she', 'is'],
  shes: ['she', 'is'],
  "i'm": ['i', 'am'],
  im: ['i', 'am'],
  "you're": ['you', 'are'],
  youre: ['you', 'are'],
  "they're": ['they', 'are'],
  theyre: ['they', 'are'],
  "we're": ['we', 'are'],
  "i've": ['i', 'have'],
  ive: ['i', 'have'],
  "you've": ['you', 'have'],
  youve: ['you', 'have'],
  "we've": ['we', 'have'],
  weve: ['we', 'have'],
  "they've": ['they', 'have'],
  theyve: ['they', 'have'],
  "i'll": ['i', 'will'],
  ill: ['i', 'will'],
  "you'll": ['you', 'will'],
  youll: ['you', 'will'],
  "he'll": ['he', 'will'],
  hell: ['he', 'will'],
  "she'll": ['she', 'will'],
  shell: ['she', 'will'],
  "we'll": ['we', 'will'],
  "they'll": ['they', 'will'],
  theyll: ['they', 'will'],
  "it'll": ['it', 'will'],
  itll: ['it', 'will'],
  "that'll": ['that', 'will'],
  thatll: ['that', 'will'],
  "i'd": ['i', 'would'],
  "you'd": ['you', 'would'],
  youd: ['you', 'would'],
  "he'd": ['he', 'would'],
  hed: ['he', 'would'],
  "she'd": ['she', 'would'],
  shed: ['she', 'would'],
  "we'd": ['we', 'would'],
  wed: ['we', 'would'],
  "they'd": ['they', 'would'],
  theyd: ['they', 'would'],
  "don't": ['do', 'not'],
  dont: ['do', 'not'],
  "doesn't": ['does', 'not'],
  doesnt: ['does', 'not'],
  "didn't": ['did', 'not'],
  didnt: ['did', 'not'],
  "won't": ['will', 'not'],
  wont: ['will', 'not'],
  "can't": ['can', 'not'],
  cant: ['can', 'not'],
  cannot: ['can', 'not'],
  "couldn't": ['could', 'not'],
  couldnt: ['could', 'not'],
  "shouldn't": ['should', 'not'],
  shouldnt: ['should', 'not'],
  "wouldn't": ['would', 'not'],
  wouldnt: ['would', 'not'],
  "isn't": ['is', 'not'],
  isnt: ['is', 'not'],
  "aren't": ['are', 'not'],
  arent: ['are', 'not'],
  "wasn't": ['was', 'not'],
  wasnt: ['was', 'not'],
  "weren't": ['were', 'not'],
  werent: ['were', 'not'],
  "haven't": ['have', 'not'],
  havent: ['have', 'not'],
  "hasn't": ['has', 'not'],
  hasnt: ['has', 'not'],
  "hadn't": ['had', 'not'],
  hadnt: ['had', 'not'],
  "let's": ['let', 'us'],
  lets: ['let', 'us'],
};

/**
 * @param {string} word
 * @returns {[string, string] | null}
 */
export function getContractionExpansion(word) {
  const w = String(word || '').toLowerCase();
  const cleaned = w.replace(/'/g, '');
  return CONTRACTION_EXPANSIONS[w] || CONTRACTION_EXPANSIONS[cleaned] || null;
}

/**
 * @param {string} word - normalized spoken or lesson word
 * @returns {[string, string] | null}
 */
export function getCompoundExpansion(word) {
  const key = canonicalizeSpelling(stripIgnoredPunctuation(word));
  return COMPOUND_EXPANSIONS[key] || null;
}

/**
 * @param {string} w1
 * @param {string} w2
 * @returns {string | null} canonical compound key when the pair forms one (e.g. vietnam)
 */
export function compoundKeyFromPair(w1, w2) {
  for (const [compound, parts] of Object.entries(COMPOUND_EXPANSIONS)) {
    if (wordsMatch(w1, parts[0]) && wordsMatch(w2, parts[1])) return compound;
  }
  return null;
}

/**
 * Normalize US vs UK spelling differences, apostrophe forms (Museums vs Museum's, its vs it's),
 * and common name/word spelling variations to a single canonical spelling.
 * @param {string} word
 * @returns {string}
 */
export function canonicalizeSpelling(word) {
  const cleaned = String(word || '')
    .toLowerCase()
    .replace(/'/g, '');
  const aliased = SPELLING_ALIASES[cleaned] || cleaned;
  return aliased
    .replace(/([a-z]{2,})our/g, (m, p1) => p1 + 'or')
    .replace(/ll/g, 'l')
    .replace(/([ctfmg])re$/g, (m, p1) => p1 + 'er')
    .replace(/is(e|ing|ed|a|o)/g, (m, p1) => 'iz' + p1)
    .replace(/ys(e|ing|ed)/g, (m, p1) => 'yz' + p1)
    .replace(/ogue$/g, 'og')
    .replace(/ence$/g, 'ense');
}

/**
 * Parse a spoken/lesson token as a number when it is digits, a trailing-dot
 * numeral ("6."), or an on-the-hour clock time ("6:00", "06:00", "6:00am").
 * @param {string} word
 * @returns {number | null}
 */
export function parseNumberToken(word) {
  const raw = stripIgnoredPunctuation(String(word || '').replace(/\s+/g, ''));
  const clock = raw.match(/^0*(\d{1,2}):00(?::00)?(?:a\.?m\.?|p\.?m\.?)?$/);
  if (clock) {
    return parseInt(clock[1], 10);
  }
  if (/^\d+$/.test(raw)) {
    return parseInt(raw, 10);
  }
  const n = WORD_TO_NUM[canonicalizeSpelling(raw)];
  return n === undefined ? null : n;
}

/**
 * True when the token is a clock time on the hour (ASR often returns "6:00" for "six o'clock").
 * @param {string} word
 * @returns {boolean}
 */
export function isOnTheHourTime(word) {
  const raw = stripIgnoredPunctuation(String(word || '').replace(/\s+/g, ''));
  return /^0*\d{1,2}:00(?::00)?(?:am|pm)?$/i.test(raw);
}

/**
 * Canonical key for matching: "twenty", "20", "6.", and "6:00" all share a number key.
 * @param {string} word - normalized word
 * @returns {string}
 */
export function matchKey(word) {
  const cleaned = stripIgnoredPunctuation(word);
  const n = parseNumberToken(cleaned);
  if (n !== null) {
    return `n:${n}`;
  }
  return canonicalizeSpelling(cleaned);
}

/**
 * @param {string} a - normalized spoken word
 * @param {string} b - normalized token word
 * @returns {boolean}
 */
export function wordsMatch(a, b) {
  const keyA = matchKey(a);
  const keyB = matchKey(b);
  if (keyA === keyB) return true;
  return meetsPronunciationAccuracy(keyA, keyB);
}
