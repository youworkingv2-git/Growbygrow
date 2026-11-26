/**
 * core/database/db.js
 * Single shared IndexedDB connection.
 * All repositories import { getDB } from here.
 */
import { CONFIG } from '../../app/config.js';
import { runMigrations } from './schema.js';

let _db = null;

/**
 * Open (or return cached) IndexedDB connection.
 * @returns {Promise<IDBDatabase>}
 */
export function getDB() {
  if (_db) return Promise.resolve(_db);
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(CONFIG.DB_NAME, CONFIG.DB_VERSION);

    req.onupgradeneeded = (event) => {
      runMigrations(req.result, event.oldVersion);
    };

    req.onsuccess = () => {
      _db = req.result;
      _db.onerror = (e) => console.error('[DB] Unhandled error:', e.target.error);
      resolve(_db);
    };

    req.onerror = () => {
      console.error('[DB] Failed to open:', req.error);
      reject(req.error);
    };
  });
}

/**
 * Close the database connection (call when resetting).
 */
export function closeDB() {
  if (_db) { _db.close(); _db = null; }
}

/**
 * Delete the entire database (DEV ONLY).
 * @returns {Promise<void>}
 */
export async function deleteDB() {
  closeDB();
  return new Promise((resolve, reject) => {
    const req = indexedDB.deleteDatabase(CONFIG.DB_NAME);
    req.onsuccess = () => resolve();
    req.onerror  = () => reject(req.error);
  });
}

// ---- Low-level helpers used by repositories ----

export function tx(storeName, mode = 'readonly') {
  return getDB().then(db => db.transaction(storeName, mode).objectStore(storeName));
}

export function promisify(req) {
  return new Promise((res, rej) => {
    req.onsuccess = () => res(req.result);
    req.onerror   = () => rej(req.error);
  });
}

export async function dbGet(store, key) {
  const s = await tx(store);
  return promisify(s.get(key));
}

export async function dbGetAll(store) {
  const s = await tx(store);
  return promisify(s.getAll());
}

export async function dbGetByIndex(store, indexName, value) {
  const s = await tx(store);
  return promisify(s.index(indexName).getAll(value));
}

export async function dbPut(store, item) {
  const s = await tx(store, 'readwrite');
  return promisify(s.put(item));
}

export async function dbDelete(store, key) {
  const s = await tx(store, 'readwrite');
  return promisify(s.delete(key));
}

export async function dbClear(store) {
  const s = await tx(store, 'readwrite');
  return promisify(s.clear());
}
