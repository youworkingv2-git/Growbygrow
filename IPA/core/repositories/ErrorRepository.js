/**
 * core/repositories/ErrorRepository.js
 */
import { dbGet, dbGetAll, dbGetByIndex, dbPut } from '../database/db.js';
import { STORES } from '../database/schema.js';

export const ErrorRepository = {
  getById:       (id)       => dbGet(STORES.ERRORS, id),
  getAll:        ()         => dbGetAll(STORES.ERRORS),
  getByPlayer:   (playerId) => dbGetByIndex(STORES.ERRORS, 'by_player', playerId),
  getByNode:     (nodeId)   => dbGetByIndex(STORES.ERRORS, 'by_node', nodeId),

  getPlayerErrors: (playerId) => ErrorRepository.getByPlayer(playerId),

  getUnresolvedByPlayer: async (playerId) => {
    const all = await ErrorRepository.getByPlayer(playerId);
    return all.filter(e => !e.isResolved);
  },

  save: async (record) => {
    await dbPut(STORES.ERRORS, record);
    return record;
  },

  resolve: async (id) => {
    const rec = await dbGet(STORES.ERRORS, id);
    if (!rec) return;
    rec.isResolved = true;
    rec.resolvedAt = Date.now();
    await dbPut(STORES.ERRORS, rec);
  }
};
