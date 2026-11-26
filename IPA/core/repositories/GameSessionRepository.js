/**
 * core/repositories/GameSessionRepository.js
 */
import { dbGet, dbGetAll, dbGetByIndex, dbPut } from '../database/db.js';
import { STORES } from '../database/schema.js';

export const GameSessionRepository = {
  getById:     (id)       => dbGet(STORES.SESSIONS, id),
  getAll:      ()         => dbGetAll(STORES.SESSIONS),
  getByPlayer: (playerId) => dbGetByIndex(STORES.SESSIONS, 'by_player', playerId),

  save: async (session) => {
    await dbPut(STORES.SESSIONS, session);
    return session;
  }
};
