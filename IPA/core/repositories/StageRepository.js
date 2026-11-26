/**
 * core/repositories/StageRepository.js
 */
import { dbGet, dbGetAll, dbPut } from '../database/db.js';
import { STORES } from '../database/schema.js';

export const StageRepository = {
  getById:  (id) => dbGet(STORES.STAGES, id),
  getAll:   ()   => dbGetAll(STORES.STAGES),
  getOrdered: async () => {
    const stages = await dbGetAll(STORES.STAGES);
    return stages.sort((a, b) => a.order - b.order);
  },
  save: async (stage) => {
    stage.updatedAt = Date.now();
    await dbPut(STORES.STAGES, stage);
    return stage;
  }
};
