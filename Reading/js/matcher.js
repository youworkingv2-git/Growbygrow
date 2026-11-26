import {
  canonicalizeSpelling,
  compoundKeyFromPair,
  getCompoundExpansion,
  getContractionExpansion,
  isOnTheHourTime,
  stripIgnoredPunctuation,
  wordsMatch,
} from './numberWords.js';

/**
 * @param {string} normalized
 * @returns {boolean}
 */
function isOclockWord(normalized) {
  const w = String(normalized || '').toLowerCase().replace(/'/g, '');
  return w === 'oclock' || w === 'clock';
}

/**
 * Words and clock times. Punctuation (?, !, ., ,, …) is a separator, not part of the word.
 * Apostrophes in contractions and colons in times are kept.
 */
function wordPieceRegex() {
  return /\d{1,2}:\d{2}(?::\d{2})?(?:[ap]\.?m\.?)?|[\p{L}\p{N}]+(?:['’`´\u2018\u2019\u201a\u2032\u02bc][\p{L}\p{N}]+)*/giu;
}

/**
 * @param {string} text
 * @returns {string[]}
 */
function extractWordPieces(text) {
  return [...String(text || '').matchAll(wordPieceRegex())].map((m) => m[0]);
}

/**
 * Tokenize a sentence into display tokens (word + trailing punctuation).
 * "goodbye,please", "goodbye, please!" and "goodbye,please" all become goodbye + please.
 * @param {string} sentence
 * @returns {{ display: string, normalized: string, hasSpaceAfter?: boolean }[]}
 */
export function tokenizeSentence(sentence) {
  const text = String(sentence || '');
  const matches = [...text.matchAll(wordPieceRegex())];
  const tokens = [];

  for (let i = 0; i < matches.length; i++) {
    const match = matches[i];
    const end = match.index + match[0].length;
    const nextStart = i + 1 < matches.length ? matches[i + 1].index : text.length;
    const after = text.slice(end, nextStart);
    const glued = after.match(/^\S*/)?.[0] ?? '';
    const normalized = normalizeWord(match[0]);
    if (!normalized) continue;

    tokens.push({
      display: match[0] + glued,
      normalized,
      hasSpaceAfter: i === matches.length - 1 || /\s/.test(after),
    });
  }

  return tokens;
}

/**
 * @param {string} raw
 * @returns {string}
 */
export function normalizeWord(raw) {
  return stripIgnoredPunctuation(raw)
    .replace(/^[^a-z0-9']+/i, '')
    .replace(/[^a-z0-9']+$/i, '');
}

/**
 * Normalize common ASR mishearings and multi-word transcript artifacts
 * (e.g. "ISS A/C." -> "Issac").
 * @param {string} text
 * @returns {string}
 */
export function normalizeTranscript(text) {
  if (!text) return '';
  return String(text)
    .replace(/\bISS[\s\.\/]*A[\s\.\/]*C\b\.?/gi, 'Issac');
}

/**
 * Split transcript into normalized words, skipping empties.
 * Punctuation is treated as a space: "goodbye,please!" → goodbye, please.
 * @param {string} transcript
 * @returns {string[]}
 */
export function wordsFromTranscript(transcript) {
  const text = normalizeTranscript(transcript);
  return extractWordPieces(text).map(normalizeWord).filter(Boolean);
}

/**
 * Try to match spoken words against unmatched tokens in the current sentence.
 * Returns indices newly matched this call.
 *
 * @param {string[]} spokenWords - words from ASR chunk
 * @param {{ normalized: string }[]} sentenceTokens
 * @param {Set<number>} matchedIndices - already matched token indices
 * @returns {number[]} newly matched indices
 */
export function matchAccumulating(spokenWords, sentenceTokens, matchedIndices) {
  const newlyMatched = [];

  for (let s = 0; s < spokenWords.length; s++) {
    const spoken = spokenWords[s];
    if (!spoken) continue;

    const nextSpoken = s + 1 < spokenWords.length ? spokenWords[s + 1] : null;
    let handled = false;

    // 1. Check if 2 spoken words [spoken, nextSpoken] match a single contraction token in sentence
    // e.g. spoken "that is" matches sentence token "that's"
    if (nextSpoken) {
      for (let i = 0; i < sentenceTokens.length; i++) {
        if (matchedIndices.has(i)) continue;
        const exp = getContractionExpansion(sentenceTokens[i].normalized);
        if (exp && wordsMatch(spoken, exp[0]) && wordsMatch(nextSpoken, exp[1])) {
          matchedIndices.add(i);
          newlyMatched.push(i);
          handled = true;
          s++; // consume nextSpoken
          break;
        }
      }
      if (handled) continue;

      const compound = compoundKeyFromPair(spoken, nextSpoken);
      if (compound) {
        for (let i = 0; i < sentenceTokens.length; i++) {
          if (matchedIndices.has(i)) continue;
          if (wordsMatch(compound, sentenceTokens[i].normalized)) {
            matchedIndices.add(i);
            newlyMatched.push(i);
            handled = true;
            s++;
            break;
          }
        }
      }
      if (handled) continue;

      const mergedSpoken = canonicalizeSpelling(spoken + nextSpoken);
      for (let i = 0; i < sentenceTokens.length; i++) {
        if (matchedIndices.has(i)) continue;
        if (wordsMatch(mergedSpoken, sentenceTokens[i].normalized)) {
          matchedIndices.add(i);
          newlyMatched.push(i);
          handled = true;
          s++;
          break;
        }
      }
      if (handled) continue;
    }

    // 2. Check if spoken is a contraction expanding to [w1, w2] matching 2 consecutive sentence tokens
    // e.g. spoken "that's" matches sentence tokens ["that", "is"]
    const compoundParts = getCompoundExpansion(spoken);
    if (compoundParts) {
      for (let i = 0; i < sentenceTokens.length - 1; i++) {
        if (matchedIndices.has(i) || matchedIndices.has(i + 1)) continue;
        if (
          wordsMatch(compoundParts[0], sentenceTokens[i].normalized) &&
          wordsMatch(compoundParts[1], sentenceTokens[i + 1].normalized)
        ) {
          matchedIndices.add(i);
          newlyMatched.push(i);
          matchedIndices.add(i + 1);
          newlyMatched.push(i + 1);
          handled = true;
          break;
        }
      }
      if (handled) continue;
    }

    for (let i = 0; i < sentenceTokens.length - 1; i++) {
      if (matchedIndices.has(i) || matchedIndices.has(i + 1)) continue;
      const mergedLesson = canonicalizeSpelling(
        sentenceTokens[i].normalized + sentenceTokens[i + 1].normalized,
      );
      if (wordsMatch(spoken, mergedLesson)) {
        matchedIndices.add(i);
        newlyMatched.push(i);
        matchedIndices.add(i + 1);
        newlyMatched.push(i + 1);
        handled = true;
        break;
      }
    }
    if (handled) continue;

    const spokenExp = getContractionExpansion(spoken);
    if (spokenExp) {
      for (let i = 0; i < sentenceTokens.length - 1; i++) {
        if (matchedIndices.has(i) || matchedIndices.has(i + 1)) continue;
        if (
          wordsMatch(spokenExp[0], sentenceTokens[i].normalized) &&
          wordsMatch(spokenExp[1], sentenceTokens[i + 1].normalized)
        ) {
          matchedIndices.add(i);
          newlyMatched.push(i);
          matchedIndices.add(i + 1);
          newlyMatched.push(i + 1);
          handled = true;
          break;
        }
      }
      if (handled) continue;
    }

    // 3. Normal single-token matching
    for (let i = 0; i < sentenceTokens.length; i++) {
      if (matchedIndices.has(i)) continue;
      if (wordsMatch(spoken, sentenceTokens[i].normalized)) {
        matchedIndices.add(i);
        newlyMatched.push(i);
        if (isOnTheHourTime(spoken)) {
          const next = i + 1;
          if (
            next < sentenceTokens.length &&
            !matchedIndices.has(next) &&
            isOclockWord(sentenceTokens[next].normalized)
          ) {
            matchedIndices.add(next);
            newlyMatched.push(next);
          }
        }
        break;
      }
    }
  }

  return newlyMatched;
}

/**
 * @param {Set<number>} matchedIndices
 * @param {number} tokenCount
 * @returns {boolean}
 */
export function isSentenceComplete(matchedIndices, tokenCount) {
  return tokenCount > 0 && matchedIndices.size >= tokenCount;
}

/**
 * @param {{ normalized: string }[]} sentenceTokens
 * @param {Set<number>} matchedIndices
 * @returns {number}
 */
export function firstUnmatchedTokenIndex(sentenceTokens, matchedIndices) {
  for (let i = 0; i < sentenceTokens.length; i++) {
    if (!matchedIndices.has(i)) return i;
  }
  return -1;
}

/**
 * Apply transcript to current sentence and report whether the utterance failed to
 * match any new token (counts as one misread on the focus word).
 *
 * @param {string[]} spokenWords
 * @param {{ normalized: string }[]} sentenceTokens
 * @param {Set<number>} matchedIndices
 * @returns {{ newlyMatched: number[], misreadFocus: boolean }}
 */
export function applyTranscript(spokenWords, sentenceTokens, matchedIndices) {
  const newlyMatched = matchAccumulating(spokenWords, sentenceTokens, matchedIndices);
  const misreadFocus = newlyMatched.length === 0 && spokenWords.length > 0;
  return { newlyMatched, misreadFocus };
}

/**
 * @param {string} transcript
 * @param {string} normalizedTarget
 * @returns {boolean}
 */
export function transcriptMatchesWord(transcript, normalizedTarget) {
  const spokenWords = wordsFromTranscript(transcript);
  return spokenWords.some((spoken) => wordsMatch(spoken, normalizedTarget));
}
