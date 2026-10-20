import { writeFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { BUNDLED_LESSONS } from '../js/lessonsBundled.js';
import { BUNDLED_TRANSLATIONS } from '../js/lessonTranslationsBundled.js';
import { SUPPLEMENT_TRANSLATIONS } from '../js/supplementTranslations.js';
import { EXTRA_TOPIC_TRANSLATIONS } from '../js/extraTopicTranslations.js';
import { TOEIC_TRANSLATIONS } from '../js/toeicTranslations.js';
import { STREAMLINE_TRANSLATIONS } from '../js/streamlineTranslations.js';
import { GRADE4_TRANSLATIONS } from '../js/grade4Translations.js';
import { TOPICS } from '../js/lessonMeta.js';

/** Later sources win so newly generated banks stay in sync. */
const ALL_TRANSLATIONS = {
  ...BUNDLED_TRANSLATIONS,
  ...SUPPLEMENT_TRANSLATIONS,
  ...EXTRA_TOPIC_TRANSLATIONS,
  ...TOEIC_TRANSLATIONS,
  ...STREAMLINE_TRANSLATIONS,
  ...GRADE4_TRANSLATIONS,
};

const root = dirname(fileURLToPath(import.meta.url));
const chunksDir = join(root, '../js/chunks');
const transDir = join(chunksDir, 'translations');

mkdirSync(transDir, { recursive: true });

const topicIds = TOPICS.filter((t) => t.id !== 'custom').map((t) => t.id);

const missing = [];
const mismatched = [];
for (const lesson of BUNDLED_LESSONS) {
  const vi = ALL_TRANSLATIONS[lesson.id];
  if (!vi?.length) {
    missing.push(`${lesson.id} (${lesson.level}/${lesson.topic})`);
    continue;
  }
  if (vi.length !== lesson.sentences.length) {
    mismatched.push(`${lesson.id}: en=${lesson.sentences.length} vi=${vi.length}`);
  }
}
if (missing.length || mismatched.length) {
  const parts = [];
  if (missing.length) {
    parts.push(`Missing Vietnamese translations:\n  ${missing.join('\n  ')}`);
  }
  if (mismatched.length) {
    parts.push(`Sentence count mismatch:\n  ${mismatched.join('\n  ')}`);
  }
  throw new Error(parts.join('\n\n'));
}

/** @type {Record<string, typeof BUNDLED_LESSONS>} */
const byTopic = {};
for (const topicId of topicIds) {
  byTopic[topicId] = BUNDLED_LESSONS.filter((l) => l.topic === topicId);
}

const index = BUNDLED_LESSONS.map(({ id, level, topic, title, custom }) => ({
  id,
  level,
  topic,
  title,
  ...(custom ? { custom: true } : {}),
}));

writeFileSync(
  join(root, '../js/lessonIndex.js'),
  `/** Auto-generated lesson index (metadata only) */\nexport const LESSON_INDEX = ${JSON.stringify(index, null, 2)};\n`,
);

for (const topicId of topicIds) {
  const lessons = byTopic[topicId].map((lesson) => ({
    ...lesson,
    translations: ALL_TRANSLATIONS[lesson.id],
  }));
  writeFileSync(
    join(chunksDir, `${topicId}.js`),
    `/** Auto-generated — ${topicId} lessons */\nexport const TOPIC_LESSONS = ${JSON.stringify(lessons, null, 2)};\n`,
  );

  /** @type {Record<string, string[]>} */
  const topicTranslations = {};
  for (const lesson of lessons) {
    const vi = ALL_TRANSLATIONS[lesson.id];
    if (vi?.length) topicTranslations[lesson.id] = vi;
  }

  writeFileSync(
    join(transDir, `${topicId}.js`),
    `/** Auto-generated — ${topicId} translations */\nexport const TOPIC_TRANSLATIONS = ${JSON.stringify(topicTranslations, null, 2)};\n`,
  );
}

console.log(`Index: ${index.length} lessons`);
for (const topicId of topicIds) {
  console.log(`  ${topicId}: ${byTopic[topicId].length} lessons`);
}
