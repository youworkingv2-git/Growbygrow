/**
 * core/models/Question.js
 * Question content entity — never contains player answers.
 */

/** @typedef {'listen_choose'|'letter_to_sound'|'sound_to_letter'|'word_sort'|'build_word'|'odd_one_out'|'match'|'boss'} QuestionType */

export function createQuestion(overrides = {}) {
  const now = Date.now();
  return {
    id: '',
    nodeId: '',
    type: 'listen_choose',
    difficulty: 1,
    prompt: '',
    audioId: null,
    imageId: null,
    options: [],
    correctAnswer: '',
    explanation: '',
    errorTag: null,
    points: 10,
    isPublished: true,
    createdAt: now,
    updatedAt: now,
    ...overrides
  };
}
