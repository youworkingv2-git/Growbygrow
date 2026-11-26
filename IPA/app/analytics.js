/**
 * app/analytics.js
 * Dev-mode event logger stub.
 * Replace this module body to plug in a real analytics provider later.
 */
import { CONFIG } from './config.js';

const EVENTS = [
  'node_opened', 'lesson_started', 'lesson_completed',
  'question_answered', 'question_wrong', 'retry_started',
  'review_started', 'node_mastered', 'node_unlocked'
];

export const Analytics = {
  /**
   * Record an analytics event.
   * @param {string} event - One of the defined event names.
   * @param {object} [data={}] - Additional metadata.
   */
  track(event, data = {}) {
    if (!EVENTS.includes(event)) {
      console.warn('[Analytics] Unknown event:', event);
    }
    if (CONFIG.IS_DEV) {
      console.log(`[Analytics] ${event}`, data);
    }
    // TODO: replace with real provider (e.g. Firebase, Mixpanel)
  }
};
