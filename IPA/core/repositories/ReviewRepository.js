/**
 * core/repositories/ReviewRepository.js
 */
import { dbGet, dbGetAll, dbGetByIndex, dbPut } from '../database/db.js';
import { STORES } from '../database/schema.js';

export const ReviewRepository = {
  getById:     (id)       => dbGet(STORES.REVIEWS, id),
  getAll:      ()         => dbGetAll(STORES.REVIEWS),
  getByPlayer: (playerId) => dbGetByIndex(STORES.REVIEWS, 'by_player', playerId),

  getDueReviews: async (playerId) => {
    const all  = await ReviewRepository.getByPlayer(playerId);
    const now  = Date.now();
    return all.filter(r => r.status === 'pending' && r.dueAt <= now);
  },

  getPendingCount: async (playerId) => {
    const due = await ReviewRepository.getDueReviews(playerId);
    return due.length;
  },

  save: async (item) => {
    item.updatedAt = Date.now();
    await dbPut(STORES.REVIEWS, item);
    return item;
  }
};
