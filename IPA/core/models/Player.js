/**
 * core/models/Player.js
 * Player profile — NO authentication fields here.
 */
export function createPlayer(overrides = {}) {
  const now = Date.now();
  return {
    id: '',
    displayName: 'Learner',
    avatarId: 'default',
    currentStageId: 'stage_0',
    currentNodeId: 'pre_phonics_intro',
    totalXP: 0,
    level: 1,
    streakDays: 0,
    lastActiveAt: now,
    createdAt: now,
    updatedAt: now,
    ...overrides
  };
}
