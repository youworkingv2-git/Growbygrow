import {
  sentencesFromText,
  buildCustomLesson,
  parseImportJson,
  normalizeLesson,
  extractPairedSentences,
} from '../js/customLessons.js';

function assert(cond, msg) {
  if (!cond) throw new Error(msg);
}

const text = `Hello world.
This is line two.
`;
assert(sentencesFromText(text).length === 2, 'split lines');

const built = buildCustomLesson({ title: 'My lesson', sentences: text });
assert(built.lesson?.title === 'My lesson', 'build title');
assert(built.lesson?.id.startsWith('custom-'), 'custom id');
assert(built.lesson?.topic === 'custom', 'default topic');

const json = parseImportJson(
  JSON.stringify({
    title: 'JSON lesson',
    level: 'a2',
    topic: 'travel',
    sentences: ['One.', 'Two.'],
  }),
);
assert(json.lessons.length === 1, 'parse single json');
assert(json.lessons[0].level === 'a2', 'json level');

const multi = parseImportJson(
  JSON.stringify({
    lessons: [
      { title: 'A', sentences: ['Hi.'] },
      { title: 'B', sentences: ['Bye.'] },
    ],
  }),
);
assert(multi.lessons.length === 2, 'parse lessons array');

const bad = buildCustomLesson({ title: '', sentences: '' });
assert(bad.errors.length > 0, 'validation errors');

const pairedText = `I do my homework after I get home from school.
Tôi làm bài tập về nhà sau khi tan học.
I start with the subjects I find most difficult.
Tôi bắt đầu với môn tôi thấy khó nhất.`;
const paired = extractPairedSentences(sentencesFromText(pairedText));
assert(paired.sentences.length === 2, 'paired english count');
assert(paired.sentences[0].startsWith('I do my homework'), 'first english');
assert(paired.translations[0].startsWith('Tôi làm bài tập'), 'first vietnamese');
assert(paired.sentences[1].startsWith('I start with'), 'second english');

const pairedLesson = buildCustomLesson({
  title: 'Homework habits',
  sentences: pairedText,
});
assert(pairedLesson.lesson?.sentences.length === 2, 'build paired sentences');
assert(pairedLesson.lesson?.translations?.length === 2, 'build paired translations');
assert(
  pairedLesson.lesson?.translations[0] === 'Tôi làm bài tập về nhà sau khi tan học.',
  'build first translation',
);

const withArray = normalizeLesson({
  title: 'JSON with translations',
  sentences: ['I wake up at six o\'clock.', 'I wash my face.'],
  translations: ['Tôi thức dậy lúc sáu giờ.', 'Tôi rửa mặt.'],
});
assert(withArray?.sentences.length === 2, 'explicit en kept');
assert(withArray?.translations?.[1] === 'Tôi rửa mặt.', 'explicit vi kept');

const qa = extractPairedSentences([
  'Hello, is this your first time in Can Tho?',
  "Yes, it's my first time here.",
  'Xin chào, đây có phải lần đầu bạn đến Cần Thơ không?',
  'Vâng, đây là lần đầu tôi đến.',
]);
assert(qa.sentences.length === 2, 'qa english count');
assert(qa.translations[0].startsWith('Xin chào'), 'qa question vi');
assert(qa.translations[1].startsWith('Vâng'), 'qa answer vi');

const englishOnly = extractPairedSentences(['Hello world.', 'This is line two.']);
assert(englishOnly.sentences.length === 2, 'english-only unchanged');
assert(englishOnly.translations.length === 0, 'english-only has no vi');

const interleavedJson = parseImportJson(
  JSON.stringify({
    title: 'DRAG',
    sentences: [
      'We don\'t want to do that.',
      'Chúng tôi không muốn làm điều đó.',
      'Business expenses are going through the roof.',
      'Chi phí kinh doanh đang tăng rất cao.',
    ],
  }),
);
assert(interleavedJson.lessons[0].sentences.length === 2, 'json interleaved en');
assert(interleavedJson.lessons[0].translations.length === 2, 'json interleaved vi');
assert(interleavedJson.lessons[0].sentences[0].startsWith('We don'), 'json first en');
assert(interleavedJson.lessons[0].translations[1].startsWith('Chi phí'), 'json second vi');

import {
  addCustomTopic,
  removeCustomTopic,
  addCustomLevel,
  removeCustomLevel,
  TOPICS,
  LEVELS,
} from '../js/lessonMeta.js';

// Custom Topics & Levels
const newTopic = addCustomTopic('Phỏng vấn');
assert(newTopic !== null, 'add custom topic');
assert(TOPICS.some((t) => t.label === 'Phỏng vấn'), 'custom topic in TOPICS');
removeCustomTopic(newTopic.id);
assert(!TOPICS.some((t) => t.id === newTopic.id), 'custom topic removed');

const newLevel = addCustomLevel('C2 — Thành thạo');
assert(newLevel !== null, 'add custom level');
assert(LEVELS.some((l) => l.label === 'C2 — Thành thạo'), 'custom level in LEVELS');
removeCustomLevel(newLevel.id);
assert(!LEVELS.some((l) => l.id === newLevel.id), 'custom level removed');

// Streamline Lessons
import { getLessonById, LESSON_INDEX } from '../js/lessons.js';
const streamlineCount = LESSON_INDEX.filter((l) => l.topic === 'streamline').length;
assert(streamlineCount === 30, '30 streamline units indexed');
const slUnit1 = await getLessonById('streamline-unit-1');
assert(slUnit1?.title === 'Unit 1 – Hello', 'streamline unit 1 loaded');
assert(slUnit1?.level === 'a1', 'streamline unit 1 level a1');
assert(slUnit1?.sentences.length > 0, 'streamline unit 1 sentences exist');

// Move lesson test
const movedLesson = {
  ...slUnit1,
  topic: 'travel',
  level: 'b1',
  custom: true,
};
assert(movedLesson.topic === 'travel', 'moved topic updated');
assert(movedLesson.level === 'b1', 'moved level updated');

console.log('customLessons tests: ok');
