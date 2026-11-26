/**
 * core/models/ErrorRecord.js
 * Records a single wrong answer — foundation for retry & SRS.
 */
export function createErrorRecord(overrides = {}) {
  const now = Date.now();
  return {
    id: '',
    playerId: '',
    nodeId: '',
    questionId: '',
    errorTag: null,
    selectedAnswer: '',
    correctAnswer: '',
    attemptNumber: 1,
    createdAt: now,
    resolvedAt: null,
    isResolved: false,
    ...overrides
  };
}
