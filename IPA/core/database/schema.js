/**
 * core/database/schema.js
 * IndexedDB object store definitions and migration runner.
 * All stores are defined here — never scattered across repositories.
 */

export const STORES = {
  STAGES:   'stages',
  NODES:    'nodes',
  PLAYERS:  'players',
  PROGRESS: 'player_node_progress',
  QUESTIONS:'questions',
  ERRORS:   'error_records',
  REVIEWS:  'review_items',
  SESSIONS: 'game_sessions'
};

/**
 * Called inside IDBOpenDBRequest.onupgradeneeded.
 * Handles all migrations from oldVersion → newVersion.
 * @param {IDBDatabase} db
 * @param {number} oldVersion
 */
export function runMigrations(db, oldVersion) {
  // --- Version 1: initial schema ---
  if (oldVersion < 1) {
    _createStore(db, STORES.STAGES,   { keyPath: 'id' });
    _createStore(db, STORES.NODES,    { keyPath: 'id' }, [
      { name: 'by_stage', keyPath: 'stageId' },
      { name: 'by_parent', keyPath: 'parentId' }
    ]);
    _createStore(db, STORES.PLAYERS,  { keyPath: 'id' });
    _createStore(db, STORES.PROGRESS, { keyPath: 'id' }, [
      { name: 'by_player',      keyPath: 'playerId' },
      { name: 'by_player_node', keyPath: ['playerId', 'nodeId'], unique: true }
    ]);
    _createStore(db, STORES.QUESTIONS, { keyPath: 'id' }, [
      { name: 'by_node', keyPath: 'nodeId' }
    ]);
    _createStore(db, STORES.ERRORS, { keyPath: 'id' }, [
      { name: 'by_player', keyPath: 'playerId' },
      { name: 'by_node',   keyPath: 'nodeId' }
    ]);
    _createStore(db, STORES.REVIEWS, { keyPath: 'id' }, [
      { name: 'by_player', keyPath: 'playerId' },
      { name: 'by_status', keyPath: 'status' }
    ]);
    _createStore(db, STORES.SESSIONS, { keyPath: 'id' }, [
      { name: 'by_player', keyPath: 'playerId' }
    ]);
  }
  // Add future version migrations below:
  // if (oldVersion < 2) { ... }
}

function _createStore(db, name, options, indexes = []) {
  if (db.objectStoreNames.contains(name)) return;
  const store = db.createObjectStore(name, options);
  indexes.forEach(({ name: idxName, keyPath, unique = false }) => {
    store.createIndex(idxName, keyPath, { unique });
  });
}
