/**
 * ProgressTracker.js - Manages LocalStorage, Node Unlock/Mastery states,
 * SRS (Spaced Repetition System) Queue, and Retry Mistakes Queue.
 */
class ProgressTracker {
  constructor() {
    this.STORAGE_KEY = 'phonics_mindmap_user_progress_v4';
    this.data = this.load();
  }

  defaultProgress() {
    return {
      xp: 0,
      stars: {}, // { nodeId: 3 }
      unlockedNodes: ['node_starters_root'],
      masteredNodes: [],
      weaknessQueue: [], // [ { wordId, nodeId, failedAt, nextReviewAt, reviewCount } ]
      levelMistakes: [], // [ { wordId, nodeId } ]
      lastWateredAt: null
    };
  }

  load() {
    try {
      const raw = localStorage.getItem(this.STORAGE_KEY);
      if (!raw) return this.defaultProgress();
      return { ...this.defaultProgress(), ...JSON.parse(raw) };
    } catch (e) {
      console.warn('Cannot load progress, resetting', e);
      return this.defaultProgress();
    }
  }

  save() {
    try {
      localStorage.setItem(this.STORAGE_KEY, JSON.stringify(this.data));
    } catch (e) {
      console.error('Cannot save progress', e);
    }
  }

  getNodeState(node, allNodes) {
    // 1. WEAK state if SRS queue contains pending failed items for this node
    const isWeak = this.data.weaknessQueue.some(item => item.nodeId === node.id && Date.now() >= item.nextReviewAt);
    if (isWeak) return 'WEAK';

    // 2. MASTERED state if 3 stars or in masteredNodes list
    if (this.data.masteredNodes.includes(node.id) || (this.data.stars[node.id] || 0) >= 3) {
      return 'MASTERED';
    }

    // 3. UNLOCKED if root node or parent is mastered/unlocked
    if (!node.parent_id || this.data.unlockedNodes.includes(node.id)) {
      return 'UNLOCKED';
    }
    const parentNode = allNodes.find(n => n.id === node.parent_id);
    if (parentNode && (this.data.unlockedNodes.includes(parentNode.id) || this.data.masteredNodes.includes(parentNode.id))) {
      return 'UNLOCKED';
    }

    // 4. Otherwise LOCKED
    return 'LOCKED';
  }

  completeLevel(nodeId, score, stars, mistakes = [], nextNodeId = null) {
    this.data.xp += score;
    this.data.stars[nodeId] = Math.max(this.data.stars[nodeId] || 0, stars);

    if (stars >= 3 && !this.data.masteredNodes.includes(nodeId)) {
      this.data.masteredNodes.push(nodeId);
    }
    if (!this.data.unlockedNodes.includes(nodeId)) {
      this.data.unlockedNodes.push(nodeId);
    }

    if (nextNodeId && !this.data.unlockedNodes.includes(nextNodeId)) {
      this.data.unlockedNodes.push(nextNodeId);
    }

    // Save level mistakes for Retry Mistakes
    this.data.levelMistakes = mistakes;

    this.save();
  }

  logWeakness(wordId, nodeId) {
    const existingIndex = this.data.weaknessQueue.findIndex(w => w.wordId === wordId);
    const now = Date.now();
    const SRS_INTERVAL = 24 * 60 * 60 * 1000; // 24 hours

    if (existingIndex >= 0) {
      const item = this.data.weaknessQueue[existingIndex];
      item.reviewCount = (item.reviewCount || 1) + 1;
      item.failedAt = now;
      item.nextReviewAt = now + SRS_INTERVAL;
    } else {
      this.data.weaknessQueue.push({
        wordId,
        nodeId,
        failedAt: now,
        reviewCount: 1,
        nextReviewAt: now + SRS_INTERVAL
      });
    }
    this.save();
  }

  resolveWeakness(wordId) {
    this.data.weaknessQueue = this.data.weaknessQueue.filter(w => w.wordId !== wordId);
    this.save();
  }

  getDueSRSCount() {
    const now = Date.now();
    return this.data.weaknessQueue.filter(w => now >= w.nextReviewAt).length;
  }

  waterTree() {
    this.data.lastWateredAt = Date.now();
    this.data.xp += 50;
    this.save();
  }
}

window.progressTracker = new ProgressTracker();
