/**
 * core/models/Node.js
 * Node represents LEARNING CONTENT. Never store player progress here.
 */

/** @typedef {'stage'|'concept'|'sound'|'grapheme'|'rule'|'word_pattern'|'syllable'|'pronunciation'|'vocabulary'|'grammar'|'reading'|'listening'|'mission'} NodeType */

/**
 * Create a default Node object.
 * @param {Partial<NodeModel>} overrides
 * @returns {NodeModel}
 */
export function createNode(overrides = {}) {
  const now = Date.now();
  return {
    id: '',
    type: 'concept',
    stageId: '',
    title: '',
    shortTitle: '',
    description: '',
    objective: '',
    category: '',
    order: 0,
    icon: '📖',
    parentId: null,
    prerequisiteNodeIds: [],
    nextNodeIds: [],
    rule: null,
    notes: null,
    examples: [],
    exceptionNotes: null,
    audioIds: [],
    imageIds: [],
    questionSetIds: [],
    errorTagIds: [],
    difficulty: 1,
    masteryThreshold: 80,
    isPublished: true,
    createdAt: now,
    updatedAt: now,
    ...overrides
  };
}

/**
 * Validate minimal required fields on a node.
 * @param {any} node
 * @returns {boolean}
 */
export function isValidNode(node) {
  return (
    typeof node === 'object' && node !== null &&
    typeof node.id === 'string' && node.id.length > 0 &&
    typeof node.title === 'string' && node.title.length > 0 &&
    typeof node.stageId === 'string' && node.stageId.length > 0
  );
}
