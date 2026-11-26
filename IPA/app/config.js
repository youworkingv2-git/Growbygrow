/**
 * app/config.js
 * Centralised configuration — never duplicate these values in UI code.
 */
export const CONFIG = {
  // Mastery thresholds
  MASTERED_THRESHOLD: 95,
  COMPLETED_THRESHOLD: 80,
  DEFAULT_UNLOCK_THRESHOLD: 80,

  // SRS
  SRS_INITIAL_INTERVAL_MS: 24 * 60 * 60 * 1000,   // 24 hours
  SRS_MULTIPLIER: 2.0,

  // Game
  MAX_XP_PER_SESSION: 200,
  XP_PER_CORRECT: 10,
  XP_PER_MASTERY: 50,

  // Database
  DB_NAME: 'phonics_mindmap_world',
  DB_VERSION: 1,

  // Dev mode — true when serving locally
  IS_DEV: location.hostname === '127.0.0.1' || location.hostname === 'localhost',

  // Feature flags
  FEATURES: {
    MULTIPLAYER: false,
    SOCIAL: false,
    PAYMENT: false,
    ADS: false,
    BOSS_MODE: true,
    SRS_REVIEW: true
  }
};
