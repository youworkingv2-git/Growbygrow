/**
 * core/repositories/QuestionRepository.js
 */
import { dbGet, dbGetAll, dbGetByIndex } from '../database/db.js';
import { STORES } from '../database/schema.js';

export const QuestionRepository = {
  getById:   (id)     => dbGet(STORES.QUESTIONS, id),
  getAll:    ()       => dbGetAll(STORES.QUESTIONS),
  getByNode: (nodeId) => dbGetByIndex(STORES.QUESTIONS, 'by_node', nodeId)
};
