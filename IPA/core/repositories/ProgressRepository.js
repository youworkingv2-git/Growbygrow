/**
 * core/repositories/ProgressRepository.js
 */
import { dbGet, dbGetAll, dbGetByIndex, dbPut } from '../database/db.js';
import { STORES } from '../database/schema.js';
import { createProgress } from '../models/Progress.js';

export const ProgressRepository = {
  getById: (id) => dbGet(STORES.PROGRESS, id),
  getAll:  ()   => dbGetAll(STORES.PROGRESS),

  getByPlayer: (playerId) => dbGetByIndex(STORES.PROGRESS, 'by_player', playerId),

  /**
   * Get progress for a specific player+node combination.
   * @returns {Promise<ProgressModel|null>}
   */
  async getPlayerNodeProgress(playerId, nodeId) {
    const all = await ProgressRepository.getByPlayer(playerId);
    return all.find(p => p.nodeId === nodeId) || null;
  },

  /**
   * Get or create progress for a player+node.
   * @returns {Promise<ProgressModel>}
   */
  async getOrCreate(playerId, nodeId) {
    let prog = await ProgressRepository.getPlayerNodeProgress(playerId, nodeId);
    if (!prog) {
      const now = Date.now();
      prog = createProgress({
        id: `${playerId}_${nodeId}`,
        playerId,
        nodeId,
        createdAt: now,
        updatedAt: now
      });
      await dbPut(STORES.PROGRESS, prog);
    }
    return prog;
  },

  save: async (progress) => {
    progress.updatedAt = Date.now();
    await dbPut(STORES.PROGRESS, progress);
    return progress;
  }
};
