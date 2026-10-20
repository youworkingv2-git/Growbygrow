import { LEVELS, TOPICS } from './lessons.js';

export const CUSTOM_LESSONS_KEY = 'reading-aloud-custom-lessons';
export const LESSON_PLACEMENTS_KEY = 'reading-aloud-lesson-placements';

/** @type {Record<string, { topic: string, level: string }>} */
let memoryPlacements = {};

const LEVEL_IDS = new Set(LEVELS.map((l) => l.id));
const TOPIC_IDS = new Set(TOPICS.map((t) => t.id));

/**
 * @returns {import('./lessons.js').Lesson[]}
 */
export function loadCustomLessons() {
  try {
    const raw = localStorage.getItem(CUSTOM_LESSONS_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed
      .map((item) => normalizeLesson(item))
      .filter((item) => item !== null);
  } catch {
    return [];
  }
}

/**
 * @param {import('./lessons.js').Lesson[]} lessons
 */
export function saveCustomLessons(lessons) {
  const payload = lessons.map((lesson) => ({
    id: lesson.id,
    title: lesson.title,
    level: lesson.level,
    topic: lesson.topic,
    sentences: lesson.sentences,
    ...(lesson.translations?.length ? { translations: lesson.translations } : {}),
    custom: true,
    createdAt: lesson.createdAt ?? Date.now(),
  }));
  try {
    localStorage.setItem(CUSTOM_LESSONS_KEY, JSON.stringify(payload));
    return true;
  } catch {
    return false;
  }
}

/**
 * @returns {Record<string, { topic: string, level: string }>}
 */
export function loadLessonPlacements() {
  try {
    if (typeof localStorage === 'undefined') return { ...memoryPlacements };
    const raw = localStorage.getItem(LESSON_PLACEMENTS_KEY);
    if (!raw) return { ...memoryPlacements };
    const parsed = JSON.parse(raw);
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      return { ...memoryPlacements };
    }
    /** @type {Record<string, { topic: string, level: string }>} */
    const next = {};
    for (const [id, value] of Object.entries(parsed)) {
      if (!id || !value || typeof value !== 'object') continue;
      const topic = String(value.topic || '').trim();
      const level = String(value.level || '').trim();
      if (!topic || !level) continue;
      next[id] = { topic, level };
    }
    memoryPlacements = next;
    return { ...next };
  } catch {
    return { ...memoryPlacements };
  }
}

/**
 * @param {Record<string, { topic: string, level: string }>} placements
 * @returns {boolean}
 */
export function saveLessonPlacements(placements) {
  memoryPlacements = { ...placements };
  try {
    if (typeof localStorage === 'undefined') return true;
    localStorage.setItem(LESSON_PLACEMENTS_KEY, JSON.stringify(placements));
    return true;
  } catch {
    return false;
  }
}

/**
 * @template {{ id: string, topic: string, level: string }} T
 * @param {T | null | undefined} lesson
 * @param {Record<string, { topic: string, level: string }>} placements
 * @returns {T | null | undefined}
 */
export function applyLessonPlacement(lesson, placements) {
  if (!lesson) return lesson;
  const placement = placements?.[lesson.id];
  if (!placement) return lesson;
  const topic = placement.topic || lesson.topic;
  const level = placement.level || lesson.level;
  if (topic === lesson.topic && level === lesson.level) return lesson;
  return { ...lesson, topic, level };
}

const STRONG_VIETNAMESE_RE =
  /[ăắằẳẵặâấầẩẫậêếềểễệôốồổỗộơớờởỡợưứừửữựđ]/i;

/**
 * @param {string} text
 * @returns {number}
 */
export function vietnameseDiacriticScore(text) {
  const matches = String(text).match(
    /[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/gi,
  );
  return matches ? matches.length : 0;
}

/**
 * @param {string} text
 * @returns {boolean}
 */
export function looksVietnamese(text) {
  const value = String(text);
  if (STRONG_VIETNAMESE_RE.test(value)) return true;
  return vietnameseDiacriticScore(value) >= 2;
}

/**
 * True when `vi` is a Vietnamese line under an English sentence.
 * @param {string} en
 * @param {string} vi
 */
function isEnglishThenVietnamese(en, vi) {
  const viScore = vietnameseDiacriticScore(vi);
  if (viScore === 0) return false;
  const enScore = vietnameseDiacriticScore(en);
  if (looksVietnamese(en) && !looksVietnamese(vi)) return false;
  if (looksVietnamese(en) && viScore <= enScore) return false;
  return viScore > enScore || (looksVietnamese(vi) && !looksVietnamese(en));
}

/**
 * Whole lesson is EN, VI, EN, VI, ...
 * @param {string[]} lines
 */
function isAlternatingEnVi(lines) {
  if (lines.length < 2 || lines.length % 2 !== 0) return false;
  let viScore = 0;
  let enScore = 0;
  for (let i = 0; i < lines.length; i += 2) {
    if (!isEnglishThenVietnamese(lines[i], lines[i + 1])) return false;
    enScore += vietnameseDiacriticScore(lines[i]);
    viScore += vietnameseDiacriticScore(lines[i + 1]);
  }
  return viScore > enScore;
}

/**
 * Split pasted/imported lines into English reading sentences + Vietnamese glosses.
 * Supports:
 *   English
 *   Tiếng Việt
 * and Q/A blocks:
 *   English question
 *   English answer
 *   Câu hỏi tiếng Việt
 *   Câu trả lời tiếng Việt
 *
 * @param {string[]} lines
 * @returns {{ sentences: string[], translations: string[] }}
 */
export function extractPairedSentences(lines) {
  const raw = lines.map((s) => String(s).trim()).filter(Boolean);
  if (raw.length < 2) {
    return { sentences: raw, translations: [] };
  }

  if (isAlternatingEnVi(raw)) {
    const sentences = [];
    const translations = [];
    for (let i = 0; i < raw.length; i += 2) {
      sentences.push(raw[i]);
      translations.push(raw[i + 1]);
    }
    return { sentences, translations };
  }

  const sentences = [];
  const translations = [];
  let paired = 0;

  for (let i = 0; i < raw.length; ) {
    const cur = raw[i];
    const next = raw[i + 1];
    const third = raw[i + 2];
    const fourth = raw[i + 3];

    if (
      next &&
      third &&
      fourth &&
      isEnglishThenVietnamese(cur, third) &&
      isEnglishThenVietnamese(next, fourth) &&
      !isEnglishThenVietnamese(cur, next)
    ) {
      sentences.push(cur, next);
      translations.push(third, fourth);
      paired += 2;
      i += 4;
      continue;
    }

    if (next && isEnglishThenVietnamese(cur, next)) {
      sentences.push(cur);
      translations.push(next);
      paired += 1;
      i += 2;
      continue;
    }

    if (looksVietnamese(cur)) {
      i += 1;
      continue;
    }

    sentences.push(cur);
    translations.push('');
    i += 1;
  }

  if (!paired) {
    return { sentences: raw, translations: [] };
  }

  return {
    sentences,
    translations: translations.some(Boolean) ? translations : [],
  };
}

/**
 * @param {string[]} sentences
 * @param {string[]} translations
 */
function resolveSentencesAndTranslations(sentences, translations) {
  if (translations.length === sentences.length && translations.length > 0) {
    return { sentences, translations };
  }

  const paired = extractPairedSentences(sentences);
  if (!paired.translations.length) {
    return { sentences, translations: [] };
  }

  return {
    sentences: paired.sentences,
    translations:
      translations.length === paired.sentences.length ? translations : paired.translations,
  };
}

/**
 * @param {unknown} raw
 * @returns {import('./lessons.js').Lesson | null}
 */
export function normalizeLesson(raw) {
  if (!raw || typeof raw !== 'object') return null;

  const data = /** @type {Record<string, unknown>} */ (raw);
  const title = String(data.title ?? '').trim();
  const rawSentences = normalizeSentences(data.sentences ?? data.text ?? data.content);
  const rawTranslations = normalizeSentences(data.translations);
  const { sentences, translations } = resolveSentencesAndTranslations(
    rawSentences,
    rawTranslations,
  );

  if (!title || !sentences.length) return null;

  const rawLevel = String(data.level ?? '');
  const level = LEVELS.some((l) => l.id === rawLevel) ? rawLevel : 'b1';
  const rawTopic = String(data.topic ?? '');
  const topic = TOPICS.some((t) => t.id === rawTopic) ? rawTopic : 'custom';

  const id =
    typeof data.id === 'string' && data.id
      ? data.id
      : generateLessonId(title);

  return {
    id,
    title,
    level,
    topic,
    sentences,
    ...(translations.length ? { translations } : {}),
    custom: true,
    createdAt: typeof data.createdAt === 'number' ? data.createdAt : Date.now(),
  };
}

/**
 * @param {unknown} value
 * @returns {string[]}
 */
export function normalizeSentences(value) {
  if (Array.isArray(value)) {
    return value.map((s) => String(s).trim()).filter(Boolean);
  }
  if (typeof value === 'string') {
    return sentencesFromText(value);
  }
  return [];
}

/**
 * @param {string} text
 * @returns {string[]}
 */
export function sentencesFromText(text) {
  return text
    .split(/\n+/)
    .map((line) => line.trim())
    .filter(Boolean);
}

/**
 * @param {string} title
 * @returns {string}
 */
export function generateLessonId(title) {
  const slug = title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 40);
  return `custom-${slug || 'lesson'}-${Date.now().toString(36)}`;
}

/**
 * @param {{ title: string, sentences: string[], level?: string, topic?: string }} input
 * @returns {{ lesson: import('./lessons.js').Lesson | null, errors: string[] }}
 */
export function buildCustomLesson(input) {
  const errors = [];
  const title = input.title.trim();
  const sentences = normalizeSentences(input.sentences);

  if (!title) errors.push('Cần nhập tiêu đề bài.');
  if (!sentences.length) errors.push('Cần ít nhất một câu (mỗi dòng một câu).');

  if (errors.length) return { lesson: null, errors };

  const lesson = normalizeLesson({
    title,
    sentences,
    level: input.level,
    topic: input.topic ?? 'custom',
  });

  if (!lesson) {
    return { lesson: null, errors: ['Không thể tạo bài từ dữ liệu đã nhập.'] };
  }

  return { lesson, errors: [] };
}

/**
 * @param {string} text
 * @returns {{ lessons: import('./lessons.js').Lesson[], errors: string[] }}
 */
export function parseImportJson(text) {
  const errors = [];
  let data;

  try {
    data = JSON.parse(text);
  } catch {
    return { lessons: [], errors: ['JSON không hợp lệ.'] };
  }

  /** @type {unknown[]} */
  let items = [];
  if (Array.isArray(data)) {
    items = data;
  } else if (data && typeof data === 'object' && Array.isArray(data.lessons)) {
    items = data.lessons;
  } else if (data && typeof data === 'object') {
    items = [data];
  } else {
    return { lessons: [], errors: ['Định dạng JSON không được hỗ trợ.'] };
  }

  const lessons = [];
  items.forEach((item, index) => {
    const lesson = normalizeLesson(item);
    if (lesson) {
      lessons.push(lesson);
    } else {
      errors.push(`Bài #${index + 1}: thiếu tiêu đề hoặc câu hợp lệ.`);
    }
  });

  if (!lessons.length && !errors.length) {
    errors.push('Không tìm thấy bài hợp lệ trong file.');
  }

  return { lessons, errors };
}

/**
 * @param {import('./lessons.js').Lesson[]} lessons
 * @param {import('./lessons.js').Lesson} lesson
 * @returns {import('./lessons.js').Lesson[]}
 */
export function addCustomLesson(lessons, lesson) {
  return [...lessons, { ...lesson, custom: true }];
}

/**
 * @param {import('./lessons.js').Lesson[]} lessons
 * @param {string} id
 * @returns {import('./lessons.js').Lesson[]}
 */
export function removeCustomLesson(lessons, id) {
  return lessons.filter((l) => l.id !== id);
}
