/**
 * core/models/Progress.js
 * Per-player, per-node progress record — separate from content.
 */

/** @typedef {'LOCKED'|'AVAILABLE'|'LEARNING'|'COMPLETED'|'MASTERED'|'NEEDS_REVIEW'} NodeStatus */

export function createProgress(overrides = {}) {
  const now = Date.now();
  return {
    id: '',
    playerId: '',
    nodeId: '',
    status: 'LOCKED',
    mastery: 0,
    attemptCount: 0,
    correctCount: 0,
    incorrectCount: 0,
    lastScore: 0,
    bestScore: 0,
    lastPlayedAt: null,
    lastMasteredAt: null,
    needsReview: false,
    createdAt: now,
    updatedAt: now,
    ...overrides
  };
}
