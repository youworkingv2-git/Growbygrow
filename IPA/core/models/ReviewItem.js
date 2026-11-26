/**
 * core/models/ReviewItem.js
 * Tracks a word/node scheduled for spaced-repetition review.
 */

/** @typedef {'pending'|'reviewing'|'resolved'} ReviewStatus */

export function createReviewItem(overrides = {}) {
  const now = Date.now();
  return {
    id: '',
    playerId: '',
    nodeId: '',
    errorRecordId: null,
    priority: 1,
    dueAt: now,
    reviewCount: 0,
    lastReviewedAt: null,
    status: 'pending',
    createdAt: now,
    updatedAt: now,
    ...overrides
  };
}
