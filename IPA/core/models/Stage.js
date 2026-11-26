/**
 * core/models/Stage.js
 * Stage groups Nodes into a progression chapter.
 */
export function createStage(overrides = {}) {
  const now = Date.now();
  return {
    id: '',
    number: 0,
    title: '',
    description: '',
    icon: '📌',
    colorToken: '#6ee7b7',
    order: 0,
    prerequisiteStageIds: [],
    isPublished: true,
    createdAt: now,
    updatedAt: now,
    ...overrides
  };
}
