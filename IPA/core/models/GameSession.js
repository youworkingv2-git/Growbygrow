/**
 * core/models/GameSession.js
 * Records a single game session's metadata.
 */

/** @typedef {'started'|'completed'|'abandoned'} SessionStatus */

export function createGameSession(overrides = {}) {
  const now = Date.now();
  return {
    id: '',
    playerId: '',
    nodeId: '',
    gameType: 'sort',
    startedAt: now,
    completedAt: null,
    totalQuestions: 0,
    correctAnswers: 0,
    incorrectAnswers: 0,
    score: 0,
    xpEarned: 0,
    status: 'started',
    ...overrides
  };
}
