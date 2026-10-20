/** Curated study chunks (look → understand → say → swap). */

/**
 * @typedef {{ en: string, vi: string, example?: string, swaps?: string[] }} LessonChunk
 */

/**
 * @param {string} text
 */
export function normalizeChunkKey(text) {
  return String(text || '')
    .toLowerCase()
    .replace(/['’]/g, "'")
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

/** @type {LessonChunk[]} */
const DAY_OF_THE_DEAD_CHUNKS = [
  {
    en: "I'm curious about...",
    vi: 'Tôi tò mò về...',
    example: "I'm curious about this holiday.",
    swaps: ['this holiday', 'this festival', 'your story'],
  },
  {
    en: 'go to the cemetery',
    vi: 'đi đến nghĩa trang',
    example: 'I go to the cemetery to see what’s happening.',
  },
  {
    en: "see what's happening",
    vi: 'xem chuyện gì đang xảy ra',
    example: "I go to the cemetery to see what’s happening.",
  },
  {
    en: 'What I find is...',
    vi: 'Điều tôi nhận thấy là...',
    example: 'What I find is quite interesting.',
    swaps: ['quite interesting', 'a little surprising', 'really beautiful'],
  },
  {
    en: 'There are ... everywhere',
    vi: 'Có ... ở khắp nơi',
    example: 'There are people everywhere.',
    swaps: ['people', 'flowers', 'kids'],
  },
  {
    en: 'sit around...',
    vi: 'ngồi xung quanh...',
    example: 'Families are sitting around the graves of their dead ancestors.',
    swaps: ['the graves', 'the table', 'the fire'],
  },
  {
    en: 'walk through...',
    vi: 'đi bộ qua...',
    example: 'I walk through the cemetery and admire the beauty of all the colorful flowers.',
    swaps: ['the cemetery', 'the park', 'the market'],
  },
  {
    en: 'admire the beauty of...',
    vi: 'ngắm vẻ đẹp của...',
    example: 'I walk through the cemetery and admire the beauty of all the colorful flowers.',
    swaps: ['the colorful flowers', 'the sunset', 'the old town'],
  },
  {
    en: 'have a picnic',
    vi: 'đi dã ngoại',
    example: 'Some families are having a picnic next to the graves.',
  },
  {
    en: 'next to...',
    vi: 'bên cạnh...',
    example: 'Some families are having a picnic next to the graves.',
    swaps: ['the graves', 'the river', 'my house'],
  },
  {
    en: 'I find that...',
    vi: 'Tôi nhận thấy rằng...',
    example: 'I find that I prefer the Guatemalan approach.',
    swaps: ['I prefer this approach', 'people are very kind', 'the city is peaceful'],
  },
  {
    en: 'I prefer...',
    vi: 'Tôi thích ... hơn',
    example: 'I find that I prefer the Guatemalan approach.',
    swaps: ['the Guatemalan approach', 'tea to coffee', 'walking to driving'],
  },
  {
    en: 'I like the way + S + V',
    vi: 'Tôi thích cách mà...',
    example: 'I like the way they remember and celebrate those who have passed away.',
    swaps: ['they remember their ancestors', 'you tell the story', 'she explains things'],
  },
  {
    en: 'have passed away',
    vi: 'đã qua đời',
    example: 'I like the way they remember and celebrate those who have passed away.',
  },
  {
    en: 'instead of + V-ing',
    vi: 'thay vì...',
    example: 'I like that they acknowledge death, instead of denying it the way Americans do.',
    swaps: ['denying it', 'waiting at home', 'worrying too much'],
  },
];

/** @type {Record<string, LessonChunk[]>} */
const CHUNKS_BY_TITLE = {
  'the day of the dead': DAY_OF_THE_DEAD_CHUNKS,
};

/**
 * @param {{ id?: string, title?: string, sentences?: string[] } | null | undefined} lesson
 * @returns {LessonChunk[]}
 */
export function getLessonChunks(lesson) {
  if (!lesson) return [];
  if (/the-day-of-the-dead/i.test(lesson.id || '')) return DAY_OF_THE_DEAD_CHUNKS;
  const titleKey = normalizeChunkKey(lesson.title);
  if (titleKey && CHUNKS_BY_TITLE[titleKey]) return CHUNKS_BY_TITLE[titleKey];

  const text = Array.isArray(lesson.sentences) ? lesson.sentences.join(' ') : '';
  if (/day of the dead/i.test(text) && /guatemala/i.test(text)) {
    return DAY_OF_THE_DEAD_CHUNKS;
  }
  return [];
}

/**
 * @param {LessonChunk} chunk
 * @param {string} [swap]
 */
export function chunkSpeakText(chunk, swap) {
  if (swap) {
    const base = chunk.en.replace(/\.\.\.|…/g, '').replace(/\s*\+\s*S\s*\+\s*V/i, '').trim();
    if (/there are/i.test(base)) return `There are ${swap} everywhere.`;
    if (/instead of/i.test(base)) return `instead of ${swap}`;
    if (/i like the way/i.test(base)) return `I like the way ${swap}`;
    if (/i prefer/i.test(base)) return `I prefer ${swap}`;
    if (/i find that/i.test(base)) return `I find that ${swap}`;
    if (/i'm curious about|i am curious about/i.test(base)) return `I'm curious about ${swap}`;
    if (/what i find is/i.test(base)) return `What I find is ${swap}`;
    if (/sit around/i.test(base)) return `sit around ${swap}`;
    if (/walk through/i.test(base)) return `walk through ${swap}`;
    if (/admire the beauty of/i.test(base)) return `admire the beauty of ${swap}`;
    if (/next to/i.test(base)) return `next to ${swap}`;
    return `${base} ${swap}`.replace(/\s+/g, ' ').trim();
  }
  return chunk.example || chunk.en.replace(/\.\.\.|…/g, '').trim();
}
