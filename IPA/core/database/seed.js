/**
 * core/database/seed.js
 * Loads content JSON files into IndexedDB.
 * Only runs when DB is empty or on dev reset.
 * DEV ONLY: expose window.__resetDB() for testing.
 */
import { CONFIG } from '../../app/config.js';
import { getDB, deleteDB, dbPut, dbGetAll } from './db.js';
import { STORES } from './schema.js';
import { createNode } from '../models/Node.js';
import { createStage } from '../models/Stage.js';
import { createPlayer } from '../models/Player.js';
import { createQuestion } from '../models/Question.js';
import { createProgress } from '../models/Progress.js';
import { createErrorRecord } from '../models/ErrorRecord.js';
import { createReviewItem } from '../models/ReviewItem.js';

const CONTENT_BASE = './content/';

async function fetchJSON(file) {
  const r = await fetch(CONTENT_BASE + file + '?v=' + CONFIG.DB_VERSION);
  if (!r.ok) throw new Error('Cannot load ' + file);
  return r.json();
}

export async function seedIfEmpty() {
  await getDB();
  const existingStages = await dbGetAll(STORES.STAGES);
  if (existingStages.length > 0) return; // already seeded

  console.log('[Seed] Seeding database…');
  await seedAll();
  console.log('[Seed] Done.');
}

export async function seedAll() {
  const [stagesData, nodesData, wordsData, questionsData] =
    await Promise.all([
      fetchJSON('stages'),
      fetchJSON('nodes'),
      fetchJSON('words'),
      fetchJSON('questions')
    ]);

  const now = Date.now();

  // Stages
  for (const s of stagesData.stages) {
    await dbPut(STORES.STAGES, createStage({ ...s, createdAt: now, updatedAt: now }));
  }

  // Nodes
  for (const n of nodesData.nodes) {
    await dbPut(STORES.NODES, createNode({ ...n, createdAt: now, updatedAt: now }));
  }

  // Questions
  for (const q of questionsData.questions) {
    await dbPut(STORES.QUESTIONS, createQuestion({ ...q, createdAt: now, updatedAt: now }));
  }

  // Dev test player
  const testPlayer = createPlayer({
    id: 'player_dev',
    displayName: 'Test Learner',
    currentStageId: 'stage_0',
    currentNodeId: 'pre_phonics_intro',
    createdAt: now,
    updatedAt: now
  });
  await dbPut(STORES.PLAYERS, testPlayer);

  // Seed some progress to demonstrate all node states
  const progressSeeds = [
    { id: 'prog_pre', playerId: 'player_dev', nodeId: 'pre_phonics_intro', status: 'MASTERED',   mastery: 96, attemptCount: 5, correctCount: 5, incorrectCount: 0 },
    { id: 'prog_la',  playerId: 'player_dev', nodeId: 'letter_a',          status: 'COMPLETED',  mastery: 85, attemptCount: 4, correctCount: 4, incorrectCount: 0 },
    { id: 'prog_sa',  playerId: 'player_dev', nodeId: 'short_a',           status: 'LEARNING',   mastery: 60, attemptCount: 3, correctCount: 2, incorrectCount: 1 },
    { id: 'prog_le',  playerId: 'player_dev', nodeId: 'letter_e',          status: 'AVAILABLE',  mastery: 0,  attemptCount: 0, correctCount: 0, incorrectCount: 0 },
    { id: 'prog_li',  playerId: 'player_dev', nodeId: 'letter_i',          status: 'AVAILABLE',  mastery: 0,  attemptCount: 0, correctCount: 0, incorrectCount: 0 },
  ];
  for (const p of progressSeeds) {
    await dbPut(STORES.PROGRESS, createProgress({ ...p, createdAt: now, updatedAt: now }));
  }

  // Seed an error record and review item for demonstration
  const errId = 'err_dev_001';
  await dbPut(STORES.ERRORS, createErrorRecord({
    id: errId,
    playerId: 'player_dev',
    nodeId: 'short_a',
    questionId: 'q_sa_01',
    errorTag: 'err_vowel_confusion',
    selectedAnswer: 'cake',
    correctAnswer: 'cat',
    attemptNumber: 2,
    createdAt: now
  }));

  await dbPut(STORES.REVIEWS, createReviewItem({
    id: 'rev_dev_001',
    playerId: 'player_dev',
    nodeId: 'short_a',
    errorRecordId: errId,
    priority: 2,
    dueAt: now + 60000, // due in 1 minute for demo
    status: 'pending',
    createdAt: now,
    updatedAt: now
  }));
}

// DEV: expose reset function on window
export function exposeDevReset() {
  if (!CONFIG.IS_DEV) return;
  window.__resetDB = async () => {
    console.warn('[DEV] Resetting database…');
    await deleteDB();
    location.reload();
  };
  console.log('[DEV] window.__resetDB() available. Or append ?reset=1 to URL.');
}
