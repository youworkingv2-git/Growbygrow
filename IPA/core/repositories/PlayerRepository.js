/**
 * core/repositories/PlayerRepository.js
 */
import { dbGet, dbGetAll, dbPut } from '../database/db.js';
import { STORES } from '../database/schema.js';

export const PlayerRepository = {
  getById:  (id) => dbGet(STORES.PLAYERS, id),
  getAll:   ()   => dbGetAll(STORES.PLAYERS),
  getDevPlayer: () => dbGet(STORES.PLAYERS, 'player_dev'),
  save: async (player) => {
    player.updatedAt = Date.now();
    await dbPut(STORES.PLAYERS, player);
    return player;
  }
};
