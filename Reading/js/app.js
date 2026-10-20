import {
  LESSON_INDEX,
  LEVELS,
  TOPICS,
  BUILTIN_TOPICS,
  BUILTIN_LEVELS,
  addCustomTopic,
  removeCustomTopic,
  addCustomLevel,
  removeCustomLevel,
  filterLessons,
  getTopicLabel,
  getLevelLabel,
  getLessonById,
  preloadForFilters,
  preloadDefaultTopic,
  loadTopicLessons,
  topicsToPreload,
} from './lessons.js';
import {
  loadCustomLessons,
  saveCustomLessons,
  loadLessonPlacements,
  saveLessonPlacements,
  applyLessonPlacement,
  buildCustomLesson,
  parseImportJson,
  addCustomLesson,
  removeCustomLesson,
} from './customLessons.js';
import {
  tokenizeSentence,
  normalizeTranscript,
  wordsFromTranscript,
  applyTranscript,
  firstUnmatchedTokenIndex,
  transcriptMatchesWord,
  isSentenceComplete,
} from './matcher.js';
import {
  lookupIpa,
  prefetchIpa,
  getCachedIpa,
  setCachedIpa,
  hasCachedIpaAttempt,
  needsPronunciationHelp,
} from './ipa.js';
import {
  loadHardWords,
  saveHardWords,
  upsertHardWord,
  removeHardWord,
  setHardWordSelected,
  setAllHardWordsSelected,
  getSelectedHardWords,
  saveManualHardWord,
  getHardWordById,
} from './hardWords.js';
import {
  setPronunciationAccuracy,
  normalizePronunciationAccuracy,
  PRONUNCIATION_ACCURACY_OPTIONS,
} from './pronunciationAccuracy.js';
import {
  speakText,
  stopSpeaking,
  isSpeaking,
  getEnglishVoices,
  onVoicesReady,
  setSelectedVoiceUri,
  getSelectedVoiceUri,
  setSelectedSpeechRate,
  normalizeSpeechRate,
  TTS_SPEECH_RATES,
  formatVoiceLabel,
  isTtsSupported,
} from './tts.js';
import { ICONS, iconFragment } from './icons.js';
import { createImportDictation } from './importDictation.js';
import { getLessonTranslations, preloadTranslationTopics, loadTranslationChunk } from './lessonTranslations.js';
import { getLessonChunks, chunkSpeakText } from './lessonChunks.js';

const STORAGE_KEY = 'reading-aloud-progress';
const SETTINGS_KEY = 'reading-aloud-settings';
const AUTO_READ_DEFAULT_VERSION = 1;
const SHOW_VIETNAMESE_DEFAULT_VERSION = 2;
const HISTORY_KEY = 'reading-aloud-history';
const HISTORY_LIMIT = 100;
const IMPORT_DIR_DB = 'reading-aloud-fs';
const IMPORT_DIR_STORE = 'handles';
const IMPORT_DIR_KEY = 'import-folder';

/** Old lesson ids before level-based naming */
const LEGACY_LESSON_IDS = {
  'self-intro': 'a2-self-intro',
  weekend: 'a2-weekend',
  'b2-ielts-technology': 'b2-ielts-describe-gift',
  'b2-ielts-environment': 'b2-ielts-describe-skill',
  'b2-ielts-media': 'b2-ielts-describe-journey',
  'b2-ielts-advertising': 'b2-ielts-describe-teacher',
  'b2-ielts-transport-challenges': 'b2-ielts-describe-hobby',
  'b2-ielts-environmental-issues': 'b2-ielts-describe-city',
};

/**
 * @param {string} id
 * @returns {string}
 */
function resolveLessonId(id) {
  return LEGACY_LESSON_IDS[id] ?? id;
}

/** @typedef {{ tokens: { display: string, normalized: string }[], matched: Set<number> }[]} LessonState */

const els = {
  topicSelect: document.getElementById('topic-select'),
  levelFilter: document.getElementById('level-filter'),
  lessonSelect: document.getElementById('lesson-select'),
  voiceSelect: document.getElementById('voice-select'),
  speechRateSelect: document.getElementById('speech-rate-select'),
  pronunciationAccuracySelect: document.getElementById('pronunciation-accuracy-select'),
  autoReadSample: document.getElementById('auto-read-sample'),
  btnMicToggle: document.getElementById('btn-mic-toggle'),
  btnAutoRead: document.getElementById('btn-auto-read'),
  btnShowVietnamese: document.getElementById('btn-show-vietnamese'),
  btnReadSample: document.getElementById('btn-read-sample'),
  btnReadRemaining: document.getElementById('btn-read-remaining'),
  btnPrevSentence: document.getElementById('btn-prev-sentence'),
  btnNextSentence: document.getElementById('btn-next-sentence'),
  btnResetSentence: document.getElementById('btn-reset-sentence'),
  btnResetLesson: document.getElementById('btn-reset-lesson'),
  btnRestart: document.getElementById('btn-restart'),
  btnNextLesson: document.getElementById('btn-next-lesson'),
  micStatus: document.getElementById('mic-status'),
  progressText: document.getElementById('progress-text'),
  liveTranscript: document.getElementById('live-transcript'),
  lessonTitle: document.getElementById('lesson-title'),
  sentencesRoot: document.getElementById('sentences-root'),
  completionBanner: document.getElementById('completion-banner'),
  remediationPanel: document.getElementById('remediation-panel'),
  remediationTitle: document.getElementById('remediation-title'),
  remediationIntro: document.getElementById('remediation-intro'),
  remediationWord: document.getElementById('remediation-word'),
  remediationIpa: document.getElementById('remediation-ipa'),
  remediationContext: document.getElementById('remediation-context'),
  remediationProgress: document.getElementById('remediation-progress'),
  remediationSuccess: document.getElementById('remediation-success'),
  remediationActions: document.getElementById('remediation-actions'),
  btnPracticeLearned: document.getElementById('btn-practice-learned'),
  btnPracticeSkip: document.getElementById('btn-practice-skip'),
  btnPracticeExit: document.getElementById('btn-practice-exit'),
  btnHardWordsToggle: document.getElementById('btn-hard-words-toggle'),
  btnHardWordsAdd: document.getElementById('btn-hard-words-add'),
  btnHardWordsClose: document.getElementById('btn-hard-words-close'),
  btnHardWordsSelectAll: document.getElementById('btn-hard-words-select-all'),
  btnHardWordsSelectNone: document.getElementById('btn-hard-words-select-none'),
  btnHardWordsPractice: document.getElementById('btn-hard-words-practice'),
  hardWordsPanel: document.getElementById('hard-words-panel'),
  hardWordsEditPanel: document.getElementById('hard-words-edit-panel'),
  hardWordsEditTitle: document.getElementById('hard-words-edit-title'),
  hardWordInput: document.getElementById('hard-word-input'),
  hardWordIpa: document.getElementById('hard-word-ipa'),
  hardWordContext: document.getElementById('hard-word-context'),
  btnHardWordFetchIpa: document.getElementById('btn-hard-word-fetch-ipa'),
  btnHardWordSave: document.getElementById('btn-hard-word-save'),
  btnHardWordCancel: document.getElementById('btn-hard-word-cancel'),
  hardWordsEditFeedback: document.getElementById('hard-words-edit-feedback'),
  hardWordsSummary: document.getElementById('hard-words-summary'),
  hardWordsTbody: document.getElementById('hard-words-tbody'),
  hardWordsEmpty: document.getElementById('hard-words-empty'),
  errorBanner: document.getElementById('error-banner'),
  importLevel: document.getElementById('import-level'),
  importTopic: document.getElementById('import-topic'),
  importTitle: document.getElementById('import-title'),
  importFormat: document.getElementById('import-format'),
  importContent: document.getElementById('import-content'),
  importContentLabel: document.getElementById('import-content-label'),
  importFile: document.getElementById('import-file'),
  btnImportSave: document.getElementById('btn-import-save'),
  btnCustomExport: document.getElementById('btn-custom-export'),
  backupImportFile: document.getElementById('backup-import-file'),
  importFeedback: document.getElementById('import-feedback'),
  importDictationWrap: document.getElementById('import-dictation'),
  importDictationStatus: document.getElementById('import-dictation-status'),
  importDictationLive: document.getElementById('import-dictation-live'),
  btnImportDictationToggle: document.getElementById('btn-import-dictation-toggle'),
  btnImportDictationNext: document.getElementById('btn-import-dictation-next'),
  customLessonsList: document.getElementById('custom-lessons-list'),
  customLessonsUl: document.getElementById('custom-lessons-ul'),
  btnEditLesson: document.getElementById('btn-edit-lesson'),
  btnDeleteCustom: document.getElementById('btn-delete-custom'),
  confirmDeleteOverlay: document.getElementById('confirm-delete-overlay'),
  confirmDeleteMessage: document.getElementById('confirm-delete-message'),
  btnConfirmDeleteCancel: document.getElementById('btn-confirm-delete-cancel'),
  btnConfirmDeleteOk: document.getElementById('btn-confirm-delete-ok'),
  btnImportToggle: document.getElementById('btn-import-toggle'),
  btnImportClose: document.getElementById('btn-import-close'),
  importPanel: document.getElementById('import-panel'),
  editPanel: document.getElementById('edit-panel'),
  btnEditClose: document.getElementById('btn-edit-close'),
  editTitle: document.getElementById('edit-title'),
  editLevel: document.getElementById('edit-level'),
  btnAddLevel: document.getElementById('btn-add-level'),
  editTopic: document.getElementById('edit-topic'),
  btnAddTopic: document.getElementById('btn-add-topic'),
  btnDeleteTopic: document.getElementById('btn-delete-topic'),
  editContent: document.getElementById('edit-content'),
  btnEditSave: document.getElementById('btn-edit-save'),
  btnEditCancel: document.getElementById('btn-edit-cancel'),
  editFeedback: document.getElementById('edit-feedback'),
  btnMoveLesson: document.getElementById('btn-move-lesson'),
  movePanel: document.getElementById('move-panel'),
  btnMoveClose: document.getElementById('btn-move-close'),
  moveLessonList: document.getElementById('move-lesson-list'),
  moveSelectedCount: document.getElementById('move-selected-count'),
  btnMoveSelectTopic: document.getElementById('btn-move-select-topic'),
  btnMoveSelectLevel: document.getElementById('btn-move-select-level'),
  btnMoveSelectNone: document.getElementById('btn-move-select-none'),
  moveTopic: document.getElementById('move-topic'),
  moveLevel: document.getElementById('move-level'),
  btnMoveSave: document.getElementById('btn-move-save'),
  btnMoveCancel: document.getElementById('btn-move-cancel'),
  moveFeedback: document.getElementById('move-feedback'),
  btnHistoryToggle: document.getElementById('btn-history-toggle'),
  btnHistoryClose: document.getElementById('btn-history-close'),
  btnHistoryClear: document.getElementById('btn-history-clear'),
  historyPanel: document.getElementById('history-panel'),
  historySummary: document.getElementById('history-summary'),
  historyList: document.getElementById('history-list'),
  historyDetail: document.getElementById('history-detail'),
  btnTopicTreeToggle: document.getElementById('btn-topic-tree-toggle'),
  btnTopicTreeClose: document.getElementById('btn-topic-tree-close'),
  topicTreePanel: document.getElementById('topic-tree-panel'),
  topicTreeRoot: document.getElementById('topic-tree-root'),
  btnLessonChunks: document.getElementById('btn-lesson-chunks'),
  btnLessonChunksClose: document.getElementById('btn-lesson-chunks-close'),
  lessonChunksPanel: document.getElementById('lesson-chunks-panel'),
  lessonChunksList: document.getElementById('lesson-chunks-list'),
  lessonChunksEmpty: document.getElementById('lesson-chunks-empty'),
};

/** @type {SpeechRecognition | null} */
let recognition = null;
let listening = false;
let micUserEnabled = false;
let micStarting = false;
let samplePlaying = false;
let samplePlayGeneration = 0;
let micSessionGeneration = 0;
let micRestartTimer = 0;

/** @type {typeof LESSON_INDEX[0] | null} */
let lesson = null;
let lastChunksLessonId = '';

/** @type {LessonState} */
let sentenceStates = [];

let currentSentenceIndex = 0;
let lessonComplete = false;
let autoReadSample = true;
let topicFilter = 'all';
let levelFilter = 'all';
/** @type {Set<string>} */
let topicTreeExpanded = new Set();
let ttsVoiceUri = '';
let ttsSpeechRate = 1;
let pronunciationAccuracy = 100;
let pendingAutoStartMic = false;
let micAwaitingGesture = false;
let gestureMicListenerAttached = false;
let showVietnamese = true;

/** @type {'reading' | 'remediation' | 'wordbank' | 'done'} */
let lessonPhase = 'reading';

/** @type {'reading' | 'remediation' | 'wordbank' | 'done'} */
let lessonPhaseBeforeWordBank = 'reading';

/** @type {Map<string, number>} */
let misreadCounts = new Map();

/** @type {Map<string, string>} */
let ipaHints = new Map();

/** Token keys that failed the latest final utterance (IPA shown only while still wrong). */
let strugglingTokenKeys = new Set();

/**
 * @typedef {{ key: string, sentenceIndex: number, tokenIndex: number, display: string, normalized: string, sentenceText: string }} RemediationItem
 */

/** @type {RemediationItem[]} */
let remediationQueue = [];

let remediationIndex = 0;

/** @type {import('./hardWords.js').HardWordEntry[]} */
let hardWords = [];

/**
 * @typedef {{ key: string, display: string, normalized: string, sentenceText: string, lessonTitle?: string }} WordBankItem
 */

/** @type {WordBankItem[]} */
let wordBankQueue = [];

let wordBankIndex = 0;

/** @type {string | null} */
let editingHardWordId = null;

/** Track processed final result index to avoid double-processing */
let lastFinalResultIndex = -1;

/** Last interim text for display only */
let lastInterimText = '';

/** Skip auto-read when restoring saved lesson on first paint */
let suppressAutoReadOnce = false;

/** @type {import('./lessons.js').Lesson[]} */
let customLessons = [];

/** @type {ReturnType<typeof createImportDictation> | null} */
let importDictation = null;
/** @type {Record<string, { topic: string, level: string }>} */
let lessonPlacements = {};
/** @type {Set<string>} */
let moveSelectedIds = new Set();
/** @type {Set<string>} */
let movePickerExpanded = new Set();
/** @type {string} */
let pendingDeleteLessonId = '';
let studyHistory = [];
let currentHistorySessionId = '';
let selectedHistorySessionId = '';

function isBuiltinLessonId(id) {
  return LESSON_INDEX.some((item) => item.id === id);
}

/**
 * Keep Unit 1 next to Unit 2 after an edit overlay is saved.
 * @param {{ title?: string }} a
 * @param {{ title?: string }} b
 */
function compareLessonsInBranch(a, b) {
  const unitA = Number((String(a.title || '').match(/unit\s*(\d+)/i) || [])[1] || 0);
  const unitB = Number((String(b.title || '').match(/unit\s*(\d+)/i) || [])[1] || 0);
  if (unitA && unitB && unitA !== unitB) return unitA - unitB;
  if (unitA && !unitB) return -1;
  if (!unitA && unitB) return 1;
  return String(a.title || '').localeCompare(String(b.title || ''), 'vi', {
    numeric: true,
    sensitivity: 'base',
  });
}

function getAllLessons() {
  const customById = new Map(customLessons.map((item) => [item.id, item]));
  const used = new Set();
  const merged = LESSON_INDEX.map((meta) => {
    const overlay = customById.get(meta.id);
    if (overlay) {
      used.add(meta.id);
      return overlay;
    }
    return meta;
  });
  for (const custom of customLessons) {
    if (!used.has(custom.id)) merged.push(custom);
  }
  return merged.map((item) => applyLessonPlacement(item, lessonPlacements) ?? item);
}

function persistLessonPlacement(lessonId, topic, level) {
  return persistLessonPlacements({ [lessonId]: { topic, level } });
}

/**
 * @param {Record<string, { topic: string, level: string }>} entries
 */
function persistLessonPlacements(entries) {
  lessonPlacements = {
    ...lessonPlacements,
    ...entries,
  };
  return saveLessonPlacements(lessonPlacements);
}

function migratePlacementsFromCustomLessons() {
  let changed = false;
  for (const custom of customLessons) {
    const builtin = LESSON_INDEX.find((item) => item.id === custom.id);
    if (!builtin) continue;
    if (custom.topic === builtin.topic && custom.level === builtin.level) continue;
    if (lessonPlacements[custom.id]) continue;
    lessonPlacements[custom.id] = { topic: custom.topic, level: custom.level };
    changed = true;
  }
  if (changed) saveLessonPlacements(lessonPlacements);
}

/**
 * @param {number} sentenceIndex
 * @param {number} tokenIndex
 * @returns {string}
 */
function tokenKey(sentenceIndex, tokenIndex) {
  return `${sentenceIndex}:${tokenIndex}`;
}

function resetLessonPracticeState() {
  lessonPhase = 'reading';
  misreadCounts = new Map();
  ipaHints = new Map();
  strugglingTokenKeys = new Set();
  remediationQueue = [];
  remediationIndex = 0;
}

/**
 * IPA appears only on the current focus word while it is still unmatched
 * and the learner has misread it enough times.
 *
 * @param {number} sentenceIndex
 * @param {number} tokenIndex
 * @param {LessonState[number]} st
 * @returns {boolean}
 */
function shouldShowInlineIpa(sentenceIndex, tokenIndex, st) {
  if (sentenceIndex !== currentSentenceIndex) return false;
  if (st.matched.has(tokenIndex)) return false;
  const focusIdx = firstUnmatchedTokenIndex(st.tokens, st.matched);
  if (focusIdx !== tokenIndex) return false;
  const key = tokenKey(sentenceIndex, tokenIndex);
  if (!needsPronunciationHelp(misreadCounts.get(key) ?? 0)) return false;
  return strugglingTokenKeys.has(key);
}

/**
 * @param {number} sentenceIndex
 * @param {number[]} tokenIndices
 */
function clearStrugglingIpa(sentenceIndex, tokenIndices) {
  for (const tokenIndex of tokenIndices) {
    strugglingTokenKeys.delete(tokenKey(sentenceIndex, tokenIndex));
  }
}

/**
 * @param {number} sentenceIndex
 * @param {number} tokenIndex
 */
function recordMisread(sentenceIndex, tokenIndex) {
  const key = tokenKey(sentenceIndex, tokenIndex);
  const next = (misreadCounts.get(key) ?? 0) + 1;
  misreadCounts.set(key, next);
  strugglingTokenKeys.add(key);
  if (needsPronunciationHelp(next)) {
    void ensureIpaHint(sentenceIndex, tokenIndex);
    syncHardWordToBank(sentenceIndex, tokenIndex, next);
  }
}

/**
 * @param {number} sentenceIndex
 * @param {number} tokenIndex
 * @param {number} misreadCount
 */
function syncHardWordToBank(sentenceIndex, tokenIndex, misreadCount) {
  if (!lesson || !needsPronunciationHelp(misreadCount)) return;
  const st = sentenceStates[sentenceIndex];
  const tok = st?.tokens[tokenIndex];
  if (!tok) return;
  const key = tokenKey(sentenceIndex, tokenIndex);
  const ipa = ipaHints.get(key) ?? getCachedIpa(tok.normalized);
  hardWords = upsertHardWord(hardWords, {
    display: tok.display,
    normalized: tok.normalized,
    misreadCount,
    lessonId: lesson.id,
    lessonTitle: lesson.title,
    sentenceText: lesson.sentences[sentenceIndex] ?? '',
    ipa,
  });
  saveHardWords(hardWords);
  updateHardWordsToggleUi();
  void lookupIpa(tok.normalized).then((value) => {
    if (!value) return;
    const item = hardWords.find((entry) => entry.id === tok.normalized);
    if (item && !item.ipaManual) {
      item.ipa = value;
      saveHardWords(hardWords);
      if (els.hardWordsPanel && !els.hardWordsPanel.classList.contains('hidden')) {
        renderHardWordsPanel();
      }
    }
  });
  if (els.hardWordsPanel && !els.hardWordsPanel.classList.contains('hidden')) {
    renderHardWordsPanel();
  }
}

/**
 * @param {number} sentenceIndex
 * @param {number} tokenIndex
 */
async function ensureIpaHint(sentenceIndex, tokenIndex) {
  const st = sentenceStates[sentenceIndex];
  const tok = st?.tokens[tokenIndex];
  if (!tok) return;
  const key = tokenKey(sentenceIndex, tokenIndex);
  if (ipaHints.has(key)) return;
  const ipa = await lookupIpa(tok.normalized);
  if (ipa) ipaHints.set(key, ipa);
  render();
}

/**
 * @returns {RemediationItem[]}
 */
function collectRemediationItems() {
  /** @type {RemediationItem[]} */
  const items = [];
  const seen = new Set();

  sentenceStates.forEach((st, sentenceIndex) => {
    st.tokens.forEach((tok, tokenIndex) => {
      const key = tokenKey(sentenceIndex, tokenIndex);
      if (!needsPronunciationHelp(misreadCounts.get(key) ?? 0) || seen.has(key)) return;
      seen.add(key);
      items.push({
        key,
        sentenceIndex,
        tokenIndex,
        display: tok.display,
        normalized: tok.normalized,
        sentenceText: lesson?.sentences?.[sentenceIndex] ?? tok.display,
      });
    });
  });

  return items;
}

function startRemediationPhase() {
  remediationQueue = collectRemediationItems();
  remediationQueue.forEach((item) => {
    hardWords = upsertHardWord(hardWords, {
      display: item.display,
      normalized: item.normalized,
      misreadCount: misreadCounts.get(item.key) ?? 5,
      lessonId: lesson?.id ?? '',
      lessonTitle: lesson?.title ?? '',
      sentenceText: item.sentenceText,
      ipa: ipaHints.get(item.key) ?? getCachedIpa(item.normalized),
    });
  });
  saveHardWords(hardWords);
  updateHardWordsToggleUi();

  if (!remediationQueue.length) {
    finishLessonFully();
    return;
  }

  lessonPhase = 'remediation';
  remediationIndex = 0;
  lessonComplete = false;
  void prefetchIpa(remediationQueue.map((item) => item.normalized)).then(() => {
    remediationQueue.forEach((item) => {
      const ipa = getCachedIpa(item.normalized);
      if (ipa) ipaHints.set(item.key, ipa);
    });
    render();
    maybeAutoReadRemediationSample();
  });
  render();
  maybeAutoReadRemediationSample();
}

function finishLessonFully() {
  lessonPhase = 'done';
  lessonComplete = true;
  stopMic({ keepEnabled: true });
  stopSpeaking();
  render();
  saveProgress();
}

function maybeAutoReadRemediationSample() {
  if (lessonPhase !== 'remediation' || !autoReadSample || samplePlaying || isSpeaking()) return;
  const item = remediationQueue[remediationIndex];
  if (!item) return;
  void speakText(item.display);
}

function advanceRemediation() {
  if (remediationIndex >= remediationQueue.length - 1) {
    finishLessonFully();
    return;
  }
  remediationIndex += 1;
  lastFinalResultIndex = -1;
  lastInterimText = '';
  render();
  saveProgress();
  maybeAutoReadRemediationSample();
}

/**
 * @param {string} id
 * @returns {import('./lessons.js').Lesson | undefined}
 */
function findLessonMetaById(id) {
  const resolved = resolveLessonId(id);
  return getAllLessons().find((l) => l.id === resolved);
}

/**
 * @param {string} topicFilter
 * @param {string} levelFilter
 */
async function preloadLessonData(topicFilter, levelFilter) {
  const topics = topicsToPreload(topicFilter, levelFilter);
  if (topics) {
    await preloadForFilters(topicFilter, levelFilter);
    await preloadTranslationTopics(topics);
  }
}

/**
 * @param {string} lessonId
 * @returns {Promise<import('./lessons.js').Lesson | undefined>}
 */
async function findLessonById(lessonId) {
  const resolved = resolveLessonId(lessonId);
  const custom = customLessons.find((l) => l.id === resolved);
  if (custom) return applyLessonPlacement(custom, lessonPlacements) ?? custom;
  const builtin = await getLessonById(resolved);
  return applyLessonPlacement(builtin, lessonPlacements) ?? builtin;
}

function setLessonLoading(loading) {
  els.sentencesRoot?.classList.toggle('is-loading', loading);
  if (loading && !lesson) {
    els.lessonTitle.textContent = 'Đang tải bài…';
  }
}

export const appReady = init();

async function init() {
  customLessons = loadCustomLessons();
  lessonPlacements = loadLessonPlacements();
  migratePlacementsFromCustomLessons();
  if (customLessons.some((lesson) => lesson.translations?.length)) {
    saveCustomLessons(customLessons);
  }
  studyHistory = loadStudyHistory();
  hardWords = loadHardWords();
  hardWords.forEach((word) => {
    if (word.ipaManual && word.ipa) setCachedIpa(word.normalized, word.ipa, { manual: true });
  });
  loadSettings();
  populateFilters();
  populateImportForm();
  setLessonLoading(true);
  try {
    await preloadDefaultTopic();
    await loadTranslationChunk('daily');
    populateLessonSelect();
    renderCustomLessonsList();
    renderStudyHistory();
    renderHardWordsPanel();
    updateHardWordsToggleUi();
    bindEvents();
    onVoicesReady(populateVoiceSelect);
    await loadSavedLesson();
  } finally {
    setLessonLoading(false);
  }
  updateMicToggleUi();
}

function loadStudyHistory() {
  try {
    const raw = localStorage.getItem(HISTORY_KEY);
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function saveStudyHistory() {
  try {
    localStorage.setItem(HISTORY_KEY, JSON.stringify(studyHistory.slice(0, HISTORY_LIMIT)));
  } catch {
    /* ignore quota */
  }
}

function createHistorySessionId() {
  return `session-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function countLessonWords() {
  return sentenceStates.reduce((sum, st) => sum + st.tokens.length, 0);
}

function countMatchedWords() {
  return sentenceStates.reduce((sum, st) => {
    if (isSentenceComplete(st.matched, st.tokens.length)) return sum + st.tokens.length;
    return sum + st.matched.size;
  }, 0);
}

function getHistoryPercent() {
  const total = countLessonWords();
  if (!total) return 0;
  return Math.round((countMatchedWords() / total) * 100);
}

function buildHistorySentencesSnapshot() {
  return sentenceStates.map((st, index) => {
    const complete = isSentenceComplete(st.matched, st.tokens.length);
    const matchedWords = st.tokens
      .filter((_, tokenIndex) => complete || st.matched.has(tokenIndex))
      .map((tok) => tok.display);
    const missingWords = st.tokens
      .filter((_, tokenIndex) => !complete && !st.matched.has(tokenIndex))
      .map((tok) => tok.display);

    return {
      index,
      text: lesson?.sentences[index] ?? '',
      completed: complete,
      matchedWordCount: complete ? st.tokens.length : st.matched.size,
      totalWordCount: st.tokens.length,
      matchedWords,
      missingWords,
    };
  });
}

function findCurrentHistorySession() {
  if (!currentHistorySessionId) return null;
  return studyHistory.find((item) => item.sessionId === currentHistorySessionId) ?? null;
}

function startHistorySession() {
  if (!lesson) return;

  const now = Date.now();
  const session = {
    sessionId: createHistorySessionId(),
    lessonId: lesson.id,
    lessonTitle: lesson.title,
    level: lesson.level,
    topic: lesson.topic,
    startedAt: now,
    updatedAt: now,
    completedAt: null,
    percentComplete: 0,
    completedSentenceCount: 0,
    totalSentenceCount: sentenceStates.length,
    matchedWordCount: 0,
    totalWordCount: countLessonWords(),
    manualSkipCount: 0,
    manualSkippedSentences: [],
    resetCount: 0,
    sentences: [],
  };

  studyHistory = [session, ...studyHistory.filter((item) => item.sessionId !== session.sessionId)].slice(0, HISTORY_LIMIT);
  currentHistorySessionId = session.sessionId;
  selectedHistorySessionId = selectedHistorySessionId || session.sessionId;
  updateCurrentHistorySession();
}

function updateCurrentHistorySession() {
  const session = findCurrentHistorySession();
  if (!session || !lesson) return;

  const now = Date.now();
  const completedSentenceCount = sentenceStates.filter((st) =>
    isSentenceComplete(st.matched, st.tokens.length),
  ).length;

  session.updatedAt = now;
  session.percentComplete = getHistoryPercent();
  session.completedSentenceCount = completedSentenceCount;
  session.totalSentenceCount = sentenceStates.length;
  session.matchedWordCount = countMatchedWords();
  session.totalWordCount = countLessonWords();
  session.sentences = buildHistorySentencesSnapshot();

  if (lessonComplete && lessonPhase === 'done') {
    session.completedAt = session.completedAt || now;
    session.percentComplete = 100;
  } else {
    session.completedAt = null;
  }

  studyHistory = [
    session,
    ...studyHistory.filter((item) => item.sessionId !== session.sessionId),
  ].slice(0, HISTORY_LIMIT);
  saveStudyHistory();
  renderStudyHistory();
}

function recordManualSkip(sentenceIndex) {
  const session = findCurrentHistorySession();
  const st = sentenceStates[sentenceIndex];
  if (!session || !lesson || !st || isSentenceComplete(st.matched, st.tokens.length)) return;

  const existing = session.manualSkippedSentences.find((item) => item.index === sentenceIndex);
  if (existing) {
    existing.count += 1;
    existing.at = Date.now();
    existing.matchedWordCount = st.matched.size;
  } else {
    session.manualSkippedSentences.push({
      index: sentenceIndex,
      text: lesson.sentences[sentenceIndex] ?? '',
      at: Date.now(),
      count: 1,
      matchedWordCount: st.matched.size,
      totalWordCount: st.tokens.length,
    });
  }

  session.manualSkipCount += 1;
  session.updatedAt = Date.now();
  saveStudyHistory();
  renderStudyHistory();
}

function recordLessonReset() {
  const session = findCurrentHistorySession();
  if (!session) return;
  session.resetCount = (session.resetCount ?? 0) + 1;
  session.updatedAt = Date.now();
  saveStudyHistory();
  renderStudyHistory();
}

function populateVoiceSelect() {
  const voices = getEnglishVoices();
  const previous = els.voiceSelect.value || ttsVoiceUri || getSelectedVoiceUri() || '';

  els.voiceSelect.innerHTML = '';

  if (!voices.length) {
    const opt = document.createElement('option');
    opt.value = '';
    opt.textContent = isTtsSupported() ? 'Không có giọng tiếng Anh' : 'TTS không hỗ trợ';
    els.voiceSelect.appendChild(opt);
    els.voiceSelect.disabled = true;
    return;
  }

  els.voiceSelect.disabled = false;

  const groups = [
    { id: 'us', label: 'US English', match: (/** @type {SpeechSynthesisVoice} */ v) => v.lang.toLowerCase().startsWith('en-us') },
    { id: 'gb', label: 'UK English', match: (/** @type {SpeechSynthesisVoice} */ v) => v.lang.toLowerCase().startsWith('en-gb') },
    { id: 'other', label: 'Khác', match: () => true },
  ];

  const used = new Set();

  for (const group of groups) {
    const inGroup = voices.filter((v) => {
      if (used.has(v.voiceURI)) return false;
      if (group.id === 'other') {
        return !v.lang.toLowerCase().startsWith('en-us') && !v.lang.toLowerCase().startsWith('en-gb');
      }
      return group.match(v);
    });
    inGroup.forEach((v) => used.add(v.voiceURI));
    if (!inGroup.length) continue;

    const optgroup = document.createElement('optgroup');
    optgroup.label = group.label;
    for (const voice of inGroup) {
      const opt = document.createElement('option');
      opt.value = voice.voiceURI;
      opt.textContent = formatVoiceLabel(voice);
      optgroup.appendChild(opt);
    }
    els.voiceSelect.appendChild(optgroup);
  }

  const hasPrevious = voices.some((v) => v.voiceURI === previous);
  const fallback = resolveDefaultVoiceUri(voices);
  const chosen = hasPrevious ? previous : fallback;

  els.voiceSelect.value = chosen;
  ttsVoiceUri = chosen;
  setSelectedVoiceUri(chosen);
  saveSettings();
}

/**
 * @param {SpeechSynthesisVoice[]} voices
 * @returns {string}
 */
function resolveDefaultVoiceUri(voices) {
  const pick =
    voices.find((v) => v.lang.toLowerCase().startsWith('en-us') && v.localService) ||
    voices.find((v) => v.lang.toLowerCase().startsWith('en-us')) ||
    voices.find((v) => v.lang.toLowerCase().startsWith('en-gb')) ||
    voices[0];
  return pick?.voiceURI ?? '';
}

function tryAutoStartMic() {
  if (lessonComplete || !pendingAutoStartMic) return;
  pendingAutoStartMic = false;
  armMicByDefault();
}

function armMicByDefault() {
  if (lessonComplete) return;
  micUserEnabled = true;
  micAwaitingGesture = false;
  startMic();
  attachMicGestureListener();
}

function attachMicGestureListener() {
  if (gestureMicListenerAttached) return;
  gestureMicListenerAttached = true;

  const tryStartFromGesture = () => {
    if (!micUserEnabled || listening || lessonComplete || isSpeaking() || samplePlaying) return;
    micAwaitingGesture = false;
    startMic();
  };

  document.addEventListener('pointerdown', tryStartFromGesture, { passive: true });
  document.addEventListener('keydown', tryStartFromGesture);
}

function populateImportForm() {
  els.importLevel.innerHTML = LEVELS.map(
    (l) => `<option value="${l.id}">${l.label}</option>`,
  ).join('');
  els.importTopic.innerHTML = TOPICS.map(
    (t) => `<option value="${t.id}">${t.label}</option>`,
  ).join('');
  els.importLevel.value = 'b1';
  els.importTopic.value = 'custom';
}

/**
 * Levels that have at least one lesson for the current topic, low → high.
 * @param {string} [topicId]
 */
function getAvailableLevels(topicId = topicFilter) {
  const lessons = getAllLessons();
  const levelIds = new Set(
    lessons
      .filter((lesson) => topicId === 'all' || lesson.topic === topicId)
      .map((lesson) => lesson.level),
  );
  return LEVELS.filter((level) => levelIds.has(level.id));
}

function populateLevelFilter() {
  const topicId = els.topicSelect.value || topicFilter;
  const available = getAvailableLevels(topicId);
  const availableIds = new Set(available.map((level) => level.id));
  if (levelFilter !== 'all' && !availableIds.has(levelFilter)) {
    levelFilter = 'all';
  }

  els.levelFilter.innerHTML =
    '<option value="all">Tất cả cấp độ</option>' +
    available.map((level) => `<option value="${level.id}">${level.label}</option>`).join('');
  els.levelFilter.value = levelFilter;
}

function populateFilters() {
  els.topicSelect.innerHTML =
    '<option value="all">Tất cả chủ đề</option>' +
    TOPICS.map((t) => `<option value="${t.id}">${t.label}</option>`).join('');

  els.topicSelect.value = topicFilter;
  populateLevelFilter();
  refreshTopicTreeIfOpen();
}

function topicTreeKey(kind, topicId, levelId = '') {
  return levelId ? `${kind}:${topicId}:${levelId}` : `${kind}:${topicId}`;
}

function ensureCurrentTreeBranchExpanded() {
  if (topicFilter === 'all') return;
  topicTreeExpanded.add(topicTreeKey('topic', topicFilter));
  if (levelFilter !== 'all') {
    topicTreeExpanded.add(topicTreeKey('level', topicFilter, levelFilter));
  }
}

function getTopicTreeData() {
  const lessons = getAllLessons();
  return TOPICS.map((topic) => {
    const topicLessons = lessons.filter((lesson) => lesson.topic === topic.id);
    const levels = LEVELS.map((level) => ({
      ...level,
      lessons: topicLessons
        .filter((lesson) => lesson.level === level.id)
        .slice()
        .sort(compareLessonsInBranch),
    })).filter((level) => level.lessons.length);
    return { ...topic, lessons: topicLessons, levels };
  });
}

function treeIcon(kind) {
  if (kind === 'folder') {
    return '<svg class="tree-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>';
  }
  if (kind === 'level') {
    return '<svg class="tree-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7l-2-2H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2z"/></svg>';
  }
  return '<svg class="tree-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>';
}

function createTreeRow({ kind, label, count, active, empty, onSelect }) {
  const btn = document.createElement('button');
  btn.type = 'button';
  btn.className = `topic-tree-row is-${kind}`;
  if (active) btn.classList.add('is-active');
  if (empty) btn.classList.add('is-empty');
  btn.innerHTML = `${treeIcon(kind)}<span class="topic-tree-name"></span>`;
  btn.querySelector('.topic-tree-name').textContent = label;
  if (typeof count === 'number') {
    const badge = document.createElement('span');
    badge.className = 'topic-tree-count';
    badge.textContent = empty ? 'Chưa có bài' : `${count} bài`;
    btn.appendChild(badge);
  }
  if (onSelect && !empty) {
    btn.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      onSelect();
    });
  }
  return btn;
}

function createTreeDetails(key, summaryEl, childrenEl) {
  const details = document.createElement('details');
  details.open = topicTreeExpanded.has(key);
  const summary = document.createElement('summary');
  const twist = document.createElement('span');
  twist.className = 'topic-tree-twist';
  twist.setAttribute('aria-hidden', 'true');
  twist.innerHTML =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>';
  summary.append(twist, summaryEl);
  details.append(summary, childrenEl);
  details.addEventListener('toggle', () => {
    if (details.open) topicTreeExpanded.add(key);
    else topicTreeExpanded.delete(key);
  });
  return details;
}

function renderTopicTree() {
  if (!els.topicTreeRoot) return;
  els.topicTreeRoot.innerHTML = '';

  const tree = document.createElement('ul');
  tree.className = 'topic-tree';

  const allItem = document.createElement('li');
  allItem.className = 'topic-tree-item';
  allItem.appendChild(
    createTreeRow({
      kind: 'folder',
      label: 'Tất cả chủ đề',
      count: getAllLessons().length,
      active: topicFilter === 'all',
      onSelect: () => {
        void applyFiltersFromTree('all', 'all');
      },
    }),
  );
  tree.appendChild(allItem);

  for (const topic of getTopicTreeData()) {
    const li = document.createElement('li');
    li.className = 'topic-tree-item';
    const topicActive = topicFilter === topic.id && levelFilter === 'all';
    const topicRow = createTreeRow({
      kind: 'folder',
      label: topic.label,
      count: topic.lessons.length,
      active: topicActive,
      empty: !topic.levels.length,
      onSelect: () => {
        topicTreeExpanded.add(topicTreeKey('topic', topic.id));
        void applyFiltersFromTree(topic.id, 'all');
      },
    });

    if (!topic.levels.length) {
      li.appendChild(topicRow);
      tree.appendChild(li);
      continue;
    }

    const children = document.createElement('ul');
    children.className = 'topic-tree-children';

    for (const level of topic.levels) {
      const levelLi = document.createElement('li');
      levelLi.className = 'topic-tree-item';
      const levelActive = topicFilter === topic.id && levelFilter === level.id;
      const levelRow = createTreeRow({
        kind: 'level',
        label: level.label,
        count: level.lessons.length,
        active: levelActive,
        onSelect: () => {
          topicTreeExpanded.add(topicTreeKey('topic', topic.id));
          topicTreeExpanded.add(topicTreeKey('level', topic.id, level.id));
          void applyFiltersFromTree(topic.id, level.id);
        },
      });

      const lessonList = document.createElement('ul');
      lessonList.className = 'topic-tree-children';
      for (const lessonItem of level.lessons) {
        const lessonLi = document.createElement('li');
        lessonLi.className = 'topic-tree-item';
        lessonLi.appendChild(
          createTreeRow({
            kind: 'lesson',
            label: lessonItem.title,
            active: lesson?.id === lessonItem.id,
            onSelect: () => {
              topicTreeExpanded.add(topicTreeKey('topic', topic.id));
              topicTreeExpanded.add(topicTreeKey('level', topic.id, level.id));
              void applyFiltersFromTree(topic.id, level.id, lessonItem.id);
            },
          }),
        );
        lessonList.appendChild(lessonLi);
      }

      levelLi.appendChild(
        createTreeDetails(topicTreeKey('level', topic.id, level.id), levelRow, lessonList),
      );
      children.appendChild(levelLi);
    }

    li.appendChild(createTreeDetails(topicTreeKey('topic', topic.id), topicRow, children));
    tree.appendChild(li);
  }

  els.topicTreeRoot.appendChild(tree);
}

function refreshTopicTreeIfOpen() {
  if (els.topicTreePanel && !els.topicTreePanel.classList.contains('hidden')) {
    renderTopicTree();
  }
}

function toggleTopicTreePanel(forceOpen) {
  if (!els.topicTreePanel || !els.btnTopicTreeToggle) return;
  const open =
    typeof forceOpen === 'boolean'
      ? forceOpen
      : els.topicTreePanel.classList.contains('hidden');
  if (open) {
    toggleMovePanel(false);
    toggleImportPanel(false);
    toggleHistoryPanel(false);
    toggleHardWordsPanel(false);
    toggleEditPanel(false);
    toggleLessonChunksPanel(false);
    ensureCurrentTreeBranchExpanded();
    renderTopicTree();
  }
  els.topicTreePanel.classList.toggle('hidden', !open);
  els.btnTopicTreeToggle.classList.toggle('is-on', open);
  els.btnTopicTreeToggle.setAttribute('aria-expanded', String(open));
}

/**
 * @param {string} nextTopic
 * @param {string} nextLevel
 * @param {string} [lessonId]
 */
async function applyFiltersFromTree(nextTopic, nextLevel, lessonId) {
  els.topicSelect.value = nextTopic;
  topicFilter = nextTopic;
  levelFilter = nextLevel;
  populateLevelFilter();
  els.levelFilter.value = levelFilter;
  await onFiltersChanged({ autoEnableMic: true });
  if (lessonId) {
    const visible = [...els.lessonSelect.options].some((option) => option.value === lessonId);
    if (visible) {
      els.lessonSelect.value = lessonId;
      await switchLesson(lessonId, { autoEnableMic: true });
    }
  }
  refreshTopicTreeIfOpen();
}

function loadSettings() {
  let shouldSaveUpdatedDefaults = false;
  try {
    const raw = localStorage.getItem(SETTINGS_KEY);
    if (raw) {
      const settings = JSON.parse(raw);
      if (settings.autoReadDefaultVersion === AUTO_READ_DEFAULT_VERSION) {
        autoReadSample = Boolean(settings.autoReadSample);
      } else {
        autoReadSample = true;
        shouldSaveUpdatedDefaults = true;
      }
      if (settings.topicFilter) topicFilter = settings.topicFilter;
      if (settings.levelFilter) levelFilter = settings.levelFilter;
      if (settings.ttsVoiceUri) ttsVoiceUri = settings.ttsVoiceUri;
      if (ttsVoiceUri) setSelectedVoiceUri(ttsVoiceUri);
      if (settings.ttsSpeechRate !== undefined) {
        ttsSpeechRate = normalizeSpeechRate(settings.ttsSpeechRate);
      }
      setSelectedSpeechRate(ttsSpeechRate);
      if (settings.pronunciationAccuracy !== undefined) {
        pronunciationAccuracy = normalizePronunciationAccuracy(settings.pronunciationAccuracy);
      }
      setPronunciationAccuracy(pronunciationAccuracy);
      if (settings.showVietnameseDefaultVersion === SHOW_VIETNAMESE_DEFAULT_VERSION) {
        showVietnamese = Boolean(settings.showVietnamese);
      } else {
        showVietnamese = true;
        shouldSaveUpdatedDefaults = true;
      }
    }
  } catch {
    autoReadSample = true;
    showVietnamese = true;
  }
  els.autoReadSample.checked = autoReadSample;
  updateAutoReadUi();
  updateVietnameseUi();
  populateSpeechRateSelect();
  populatePronunciationAccuracySelect();
  if (shouldSaveUpdatedDefaults) saveSettings();
}

function populatePronunciationAccuracySelect() {
  if (!els.pronunciationAccuracySelect) return;
  els.pronunciationAccuracySelect.innerHTML = PRONUNCIATION_ACCURACY_OPTIONS.map((value) => {
    const label =
      value === 100
        ? '100% — Chuẩn'
        : value === 80
          ? '80% — Dễ hơn'
          : `${value}%`;
    return `<option value="${value}">${label}</option>`;
  }).join('');
  els.pronunciationAccuracySelect.value = String(pronunciationAccuracy);
}

function populateSpeechRateSelect() {
  if (!els.speechRateSelect) return;
  els.speechRateSelect.innerHTML = TTS_SPEECH_RATES.map((rate) => {
    const label =
      rate === 0.5
        ? '0.5× — Chậm'
        : rate === 1
          ? '1× — Bình thường'
          : rate === 1.5
            ? '1.5× — Nhanh'
            : `${rate}×`;
    return `<option value="${rate}">${label}</option>`;
  }).join('');
  els.speechRateSelect.value = String(ttsSpeechRate);
}

function updateVietnameseUi() {
  if (!els.btnShowVietnamese) return;
  els.btnShowVietnamese.classList.toggle('is-on', showVietnamese);
  els.btnShowVietnamese.setAttribute('aria-pressed', String(showVietnamese));
  document.body.classList.toggle('show-vietnamese', showVietnamese);
}

function updateAutoReadUi() {
  els.btnAutoRead.classList.toggle('is-on', autoReadSample);
  els.btnAutoRead.setAttribute('aria-pressed', String(autoReadSample));
  if (els.autoReadSample) els.autoReadSample.checked = autoReadSample;
}

function updateMicToggleUi() {
  const on = micUserEnabled;
  const live = listening;
  const sample = samplePlaying || isSpeaking();
  const starting = micStarting || micRestartTimer > 0;

  els.btnMicToggle.classList.toggle('is-on', on);
  els.btnMicToggle.setAttribute('aria-pressed', String(on));
  els.btnMicToggle.disabled = lessonComplete;
  els.btnMicToggle.title = on ? 'Tắt mic' : 'Bật mic';
  els.btnMicToggle.setAttribute('aria-label', on ? 'Tắt mic' : 'Bật mic');
  els.btnMicToggle.querySelector('.mic-icon-on')?.classList.toggle('hidden', on);
  els.btnMicToggle.querySelector('.mic-icon-off')?.classList.toggle('hidden', !on);

  if (sample) {
    els.micStatus.textContent = 'Đang phát mẫu…';
    els.micStatus.classList.remove('is-live');
  } else if (starting) {
    els.micStatus.textContent = 'Đang bật mic…';
    els.micStatus.classList.remove('is-live');
  } else if (live) {
    els.micStatus.textContent = 'Mic đang nghe…';
    els.micStatus.classList.add('is-live');
  } else {
    els.micStatus.textContent = on ? 'Mic bật' : 'Mic tắt';
    els.micStatus.classList.remove('is-live');
  }
}

function setSampleControlsBusy(busy) {
  samplePlaying = busy;
  const disabled = lessonComplete || busy;
  els.btnReadSample.disabled = disabled;
  els.btnReadSample.classList.toggle('is-busy', busy);
  if (els.btnReadRemaining) {
    els.btnReadRemaining.disabled = disabled;
    els.btnReadRemaining.classList.toggle('is-busy', busy);
  }
  els.btnAutoRead.disabled = busy;
}

function pauseMicForSample() {
  if (!listening) return;
  stopMic({ keepEnabled: true });
}

function clearMicRestartTimer() {
  if (!micRestartTimer) return;
  window.clearTimeout(micRestartTimer);
  micRestartTimer = 0;
}

function invalidateMicSession() {
  micSessionGeneration += 1;
  lastFinalResultIndex = -1;
  lastInterimText = '';
}

function scheduleMicRestart(delay = 120) {
  clearMicRestartTimer();
  if (!micUserEnabled || micAwaitingGesture || lessonComplete || isSpeaking() || samplePlaying) {
    updateMicToggleUi();
    return;
  }

  micRestartTimer = window.setTimeout(() => {
    micRestartTimer = 0;
    if (micUserEnabled && !micAwaitingGesture && !lessonComplete && !isSpeaking() && !samplePlaying) {
      startMic();
    } else {
      updateMicToggleUi();
    }
  }, delay);
  updateMicToggleUi();
}

/** Dừng recognition hiện tại và bật lại nếu mic vẫn đang bật (không tắt hẳn). */
function restartMic() {
  if (!micUserEnabled || lessonComplete || isSpeaking() || samplePlaying) return;

  if (listening || recognition) {
    stopMic({ keepEnabled: true });
    scheduleMicRestart();
    return;
  }

  if (!micAwaitingGesture) {
    scheduleMicRestart(40);
  }
}

/**
 * @param {{ autoEnableMic?: boolean }=} options
 */
function pauseMicForContextChange(options = {}) {
  if (options.autoEnableMic) {
    micUserEnabled = true;
    micAwaitingGesture = false;
  }

  if (!micUserEnabled || micAwaitingGesture) {
    invalidateMicSession();
    return false;
  }

  invalidateMicSession();

  if (listening || recognition || micStarting || micRestartTimer) {
    stopMic({ keepEnabled: true });
  }

  return true;
}

function resumeMicAfterContextChange(shouldResume) {
  if (!shouldResume) {
    updateMicToggleUi();
    return;
  }
  restartMic();
}

/**
 * @param {string} lessonId
 * @param {{ autoEnableMic?: boolean }=} options
 */
async function switchLesson(lessonId, options = {}) {
  if (lessonPhase === 'wordbank') exitWordBankPractice();
  const shouldResumeMic = pauseMicForContextChange(options);
  await loadLesson(lessonId);
  resumeMicAfterContextChange(shouldResumeMic);
}

async function readCurrentSample() {
  if (samplePlaying) return;
  if (lessonPhase === 'wordbank') {
    const item = wordBankQueue[wordBankIndex];
    if (!item) return;
    const playGen = ++samplePlayGeneration;
    const micShouldResume = micUserEnabled && !micAwaitingGesture;
    setSampleControlsBusy(true);
    pauseMicForSample();
    updateMicToggleUi();
    let ok = false;
    try {
      ok = await speakText(item.display);
    } catch {
      ok = false;
    }
    if (playGen !== samplePlayGeneration) return;
    setSampleControlsBusy(false);
    if (!ok) showError('Trình duyệt không hỗ trợ đọc mẫu (Text-to-Speech).');
    if (micShouldResume && micUserEnabled && !lessonComplete && !listening) startMic();
    updateMicToggleUi();
    return;
  }
  if (!lesson || lessonComplete) return;
  if (lessonPhase === 'remediation') {
    const item = remediationQueue[remediationIndex];
    if (!item) return;
    const playGen = ++samplePlayGeneration;
    const micShouldResume = micUserEnabled && !micAwaitingGesture;
    setSampleControlsBusy(true);
    pauseMicForSample();
    updateMicToggleUi();
    let ok = false;
    try {
      ok = await speakText(item.display);
    } catch {
      ok = false;
    }
    if (playGen !== samplePlayGeneration) return;
    setSampleControlsBusy(false);
    if (!ok) showError('Trình duyệt không hỗ trợ đọc mẫu (Text-to-Speech).');
    if (micShouldResume && micUserEnabled && !lessonComplete && !listening) startMic();
    updateMicToggleUi();
    return;
  }
  const text = lesson.sentences[currentSentenceIndex];
  if (!text) return;

  const playGen = ++samplePlayGeneration;
  const micShouldResume = micUserEnabled && !micAwaitingGesture;

  setSampleControlsBusy(true);
  pauseMicForSample();
  updateMicToggleUi();

  let ok = false;
  try {
    ok = await speakText(text);
  } catch {
    ok = false;
  }

  if (playGen !== samplePlayGeneration) return;

  setSampleControlsBusy(false);

  if (!ok) {
    showError('Trình duyệt không hỗ trợ đọc mẫu (Text-to-Speech).');
  }

  if (micShouldResume && micUserEnabled && !lessonComplete && !listening) {
    startMic();
  }
  updateMicToggleUi();
}

async function readRemainingWords() {
  if (!lesson || lessonComplete || samplePlaying) return;
  const st = sentenceStates[currentSentenceIndex];
  if (!st) return;

  const unmatchedTokens = st.tokens.filter((_, idx) => !st.matched.has(idx));
  if (!unmatchedTokens.length) return;

  const text = unmatchedTokens.map((tok) => tok.display).join(' ');

  const playGen = ++samplePlayGeneration;
  const micShouldResume = micUserEnabled && !micAwaitingGesture;

  setSampleControlsBusy(true);
  pauseMicForSample();
  updateMicToggleUi();

  let ok = false;
  try {
    ok = await speakText(text);
  } catch {
    ok = false;
  }

  if (playGen !== samplePlayGeneration) return;

  setSampleControlsBusy(false);

  if (!ok) {
    showError('Trình duyệt không hỗ trợ đọc (Text-to-Speech).');
  }

  if (micShouldResume && micUserEnabled && !lessonComplete && !listening) {
    startMic();
  }
  updateMicToggleUi();
}

function maybeAutoReadSample({ force = false } = {}) {
  if ((!force && !autoReadSample) || lessonComplete || !lesson || samplePlaying || isSpeaking()) return;
  void readCurrentSample();
}

function toggleMic() {
  if (lessonComplete || micStarting || samplePlaying) return;

  if (micUserEnabled && !micAwaitingGesture && (listening || recognition || micRestartTimer)) {
    stopMic();
    return;
  }

  micUserEnabled = true;
  micAwaitingGesture = false;
  if (!isSpeaking() && !samplePlaying) startMic();
  else updateMicToggleUi();
}

function invalidateSamplePlayback() {
  samplePlayGeneration += 1;
  if (samplePlaying) {
    stopSpeaking();
    setSampleControlsBusy(false);
  }
}

function toggleImportPanel(forceOpen) {
  const open =
    typeof forceOpen === 'boolean'
      ? forceOpen
      : els.importPanel.classList.contains('hidden');
  if (open) {
    toggleMovePanel(false);
    toggleHistoryPanel(false);
    toggleHardWordsPanel(false);
    toggleTopicTreePanel(false);
    toggleLessonChunksPanel(false);
  } else {
    importDictation?.shutdown();
  }
  els.importPanel.classList.toggle('hidden', !open);
  els.btnImportToggle.classList.toggle('is-on', open);
  els.btnImportToggle.setAttribute('aria-expanded', String(open));
}

function toggleHistoryPanel(forceOpen) {
  const open =
    typeof forceOpen === 'boolean'
      ? forceOpen
      : els.historyPanel.classList.contains('hidden');
  if (open) {
    toggleMovePanel(false);
    toggleImportPanel(false);
    toggleHardWordsPanel(false);
    toggleTopicTreePanel(false);
    toggleLessonChunksPanel(false);
  }
  els.historyPanel.classList.toggle('hidden', !open);
  els.btnHistoryToggle.classList.toggle('is-on', open);
  els.btnHistoryToggle.setAttribute('aria-expanded', String(open));
  if (open) renderStudyHistory();
}

function toggleHardWordsPanel(forceOpen) {
  const open =
    typeof forceOpen === 'boolean'
      ? forceOpen
      : els.hardWordsPanel?.classList.contains('hidden');
  if (open) {
    toggleMovePanel(false);
    toggleImportPanel(false);
    toggleHistoryPanel(false);
    toggleTopicTreePanel(false);
    toggleLessonChunksPanel(false);
  }
  els.hardWordsPanel?.classList.toggle('hidden', !open);
  els.btnHardWordsToggle?.classList.toggle('is-on', open);
  els.btnHardWordsToggle?.setAttribute('aria-expanded', String(open));
  if (open) {
    void prefetchIpa(hardWords.map((item) => item.normalized)).then(() => {
      hardWords.forEach((item) => {
        if (item.ipaManual) return;
        const ipa = getCachedIpa(item.normalized);
        if (ipa) item.ipa = ipa;
      });
      saveHardWords(hardWords);
      renderHardWordsPanel();
    });
    renderHardWordsPanel();
  }
}

function updateHardWordsToggleUi() {
  if (!els.btnHardWordsToggle) return;
  const count = hardWords.length;
  els.btnHardWordsToggle.title = count
    ? `Từ khó cần ôn (${count})`
    : 'Từ khó cần ôn';
  els.btnHardWordsToggle.setAttribute(
    'aria-label',
    count ? `Từ khó cần ôn, ${count} từ` : 'Từ khó cần ôn',
  );
}

function currentLessonChunks() {
  return getLessonChunks(lesson);
}

function updateLessonChunksButtonUi() {
  if (!els.btnLessonChunks) return;
  const count = currentLessonChunks().length;
  const label = count ? `Từ/Cụm cần học (${count})` : 'Từ/Cụm cần học';
  const textEl = els.btnLessonChunks.querySelector('.lesson-chunks-btn-label');
  if (textEl) textEl.textContent = label;
  els.btnLessonChunks.title = label;
  els.btnLessonChunks.setAttribute(
    'aria-label',
    count ? `Từ/Cụm cần học, ${count} cụm` : 'Từ/Cụm cần học',
  );
}

function toggleLessonChunksPanel(forceOpen) {
  if (!els.lessonChunksPanel || !els.btnLessonChunks) return;
  const open =
    typeof forceOpen === 'boolean'
      ? forceOpen
      : els.lessonChunksPanel.classList.contains('hidden');
  if (open) {
    toggleMovePanel(false);
    toggleImportPanel(false);
    toggleHistoryPanel(false);
    toggleHardWordsPanel(false);
    toggleTopicTreePanel(false);
    toggleEditPanel(false);
    renderLessonChunksPanel(true);
  }
  els.lessonChunksPanel.classList.toggle('hidden', !open);
  els.btnLessonChunks.classList.toggle('is-on', open);
  els.btnLessonChunks.setAttribute('aria-expanded', String(open));
}

/**
 * @param {boolean} [force]
 */
function renderLessonChunksPanel(force = false) {
  updateLessonChunksButtonUi();
  if (!els.lessonChunksList || !els.lessonChunksEmpty) return;
  const lessonId = lesson?.id || '';
  if (!force && lessonId === lastChunksLessonId) return;
  lastChunksLessonId = lessonId;

  const chunks = currentLessonChunks();
  els.lessonChunksList.replaceChildren();
  if (!chunks.length) {
    els.lessonChunksEmpty.classList.remove('hidden');
    els.lessonChunksList.classList.add('hidden');
    return;
  }
  els.lessonChunksEmpty.classList.add('hidden');
  els.lessonChunksList.classList.remove('hidden');

  chunks.forEach((chunk, index) => {
    const card = document.createElement('article');
    card.className = 'chunk-card';
    card.dataset.index = String(index);

    const top = document.createElement('div');
    top.className = 'chunk-card-top';

    const en = document.createElement('p');
    en.className = 'chunk-en';
    en.textContent = chunk.en;

    const speakBtn = document.createElement('button');
    speakBtn.type = 'button';
    speakBtn.className = 'icon-btn chunk-speak-btn';
    speakBtn.title = 'Nói lại cụm này';
    speakBtn.setAttribute('aria-label', `Nói lại: ${chunk.en}`);
    speakBtn.dataset.chunkSpeak = '1';
    speakBtn.appendChild(iconFragment(ICONS.volume));

    top.append(en, speakBtn);

    const vi = document.createElement('p');
    vi.className = 'chunk-vi';
    vi.textContent = chunk.vi;

    const example = document.createElement('p');
    example.className = 'chunk-example';
    example.textContent = chunk.example ? `VD: ${chunk.example}` : '';

    card.append(top, vi);
    if (chunk.example) card.appendChild(example);

    if (chunk.swaps?.length) {
      const swaps = document.createElement('div');
      swaps.className = 'chunk-swaps';
      const swapLabel = document.createElement('span');
      swapLabel.className = 'chunk-swaps-label';
      swapLabel.textContent = 'Thay từ:';
      swaps.appendChild(swapLabel);
      chunk.swaps.forEach((swap) => {
        const chip = document.createElement('button');
        chip.type = 'button';
        chip.className = 'chunk-swap';
        chip.dataset.chunkSwap = swap;
        chip.textContent = swap;
        chip.title = `Thay từ: ${swap}`;
        swaps.appendChild(chip);
      });
      card.appendChild(swaps);
    }

    els.lessonChunksList.appendChild(card);
  });
}

/**
 * @param {MouseEvent} event
 */
function onLessonChunksClick(event) {
  const target = event.target instanceof Element ? event.target : null;
  if (!target) return;
  const card = target.closest('.chunk-card');
  if (!card) return;
  const chunk = currentLessonChunks()[Number(card.dataset.index)];
  if (!chunk) return;

  const swapBtn = target.closest('[data-chunk-swap]');
  if (swapBtn instanceof HTMLElement) {
    card.querySelectorAll('[data-chunk-swap]').forEach((el) => {
      el.classList.toggle('is-on', el === swapBtn);
    });
    const swap = swapBtn.dataset.chunkSwap || '';
    const spoken = chunkSpeakText(chunk, swap);
    const exampleEl = card.querySelector('.chunk-example');
    if (exampleEl) exampleEl.textContent = `Nói: ${spoken}`;
    void speakText(spoken);
    return;
  }

  if (target.closest('[data-chunk-speak]')) {
    card.querySelectorAll('[data-chunk-swap]').forEach((el) => el.classList.remove('is-on'));
    const spoken = chunkSpeakText(chunk);
    const exampleEl = card.querySelector('.chunk-example');
    if (exampleEl && chunk.example) exampleEl.textContent = `VD: ${chunk.example}`;
    void speakText(spoken);
  }
}

/**
 * @param {import('./hardWords.js').HardWordEntry} entry
 * @returns {string | null}
 */
function resolveHardWordIpa(entry) {
  return entry.ipa ?? getCachedIpa(entry.normalized);
}

/**
 * @param {HTMLElement} container
 * @param {import('./hardWords.js').HardWordEntry} entry
 */
function renderHardWordIpaLine(container, entry) {
  container.replaceChildren();
  const ipa = resolveHardWordIpa(entry);
  const ipaEl = document.createElement('span');
  ipaEl.className = 'hard-word-ipa';
  if (ipa) {
    ipaEl.textContent = ipa;
    ipaEl.setAttribute('aria-label', `Phát âm ${ipa}`);
  } else if (!hasCachedIpaAttempt(entry.normalized)) {
    ipaEl.classList.add('is-loading');
    ipaEl.textContent = 'Đang tải IPA…';
    void lookupIpa(entry.normalized).then((value) => {
      if (value && !entry.ipaManual) {
        entry.ipa = value;
        saveHardWords(hardWords);
      }
      renderHardWordsPanel();
      if (lessonPhase === 'wordbank' || lessonPhase === 'remediation') render();
    });
  } else {
    ipaEl.classList.add('is-missing');
    ipaEl.textContent = 'Chưa có IPA — bấm Sửa để nhập';
  }
  container.appendChild(ipaEl);
}

/**
 * @param {string} message
 * @param {boolean} isError
 */
function showHardWordsEditFeedback(message, isError = false) {
  if (!els.hardWordsEditFeedback) return;
  els.hardWordsEditFeedback.textContent = message;
  els.hardWordsEditFeedback.classList.remove('hidden', 'ok', 'err');
  els.hardWordsEditFeedback.classList.add(isError ? 'err' : 'ok');
}

function hideHardWordsEditFeedback() {
  els.hardWordsEditFeedback?.classList.add('hidden');
}

/**
 * @param {string | null} id
 */
function openHardWordEditor(id = null) {
  editingHardWordId = id;
  hideHardWordsEditFeedback();
  els.hardWordsEditPanel?.classList.remove('hidden');
  if (els.hardWordsEditTitle) {
    els.hardWordsEditTitle.textContent = id ? 'Sửa từ khó' : 'Thêm từ khó';
  }
  const entry = id ? getHardWordById(hardWords, id) : null;
  if (els.hardWordInput) els.hardWordInput.value = entry?.display ?? '';
  if (els.hardWordIpa) els.hardWordIpa.value = entry?.ipa ?? resolveHardWordIpa(entry ?? { normalized: '', ipa: null }) ?? '';
  if (els.hardWordContext) els.hardWordContext.value = entry?.sentenceText ?? '';
  els.hardWordInput?.focus();
}

function closeHardWordEditor() {
  editingHardWordId = null;
  hideHardWordsEditFeedback();
  els.hardWordsEditPanel?.classList.add('hidden');
  if (els.hardWordInput) els.hardWordInput.value = '';
  if (els.hardWordIpa) els.hardWordIpa.value = '';
  if (els.hardWordContext) els.hardWordContext.value = '';
}

/**
 * @param {{ force?: boolean }} [options]
 */
async function fetchHardWordIpaForForm(options = {}) {
  const word = els.hardWordInput?.value.trim();
  if (!word) {
    showHardWordsEditFeedback('Hãy nhập từ tiếng Anh trước.', true);
    return;
  }
  hideHardWordsEditFeedback();
  if (els.btnHardWordFetchIpa) els.btnHardWordFetchIpa.disabled = true;
  const typedBefore = els.hardWordIpa?.value ?? '';
  const ipa = await lookupIpa(word);
  if (els.btnHardWordFetchIpa) els.btnHardWordFetchIpa.disabled = false;
  const typedNow = els.hardWordIpa?.value ?? '';
  if (!options.force && typedNow.trim() && typedNow !== typedBefore) {
    return;
  }
  if (ipa) {
    if (els.hardWordIpa) els.hardWordIpa.value = ipa;
    showHardWordsEditFeedback('Đã lấy IPA.');
  } else {
    showHardWordsEditFeedback('Không lấy được IPA tự động — bạn có thể nhập thủ công.', true);
  }
}

function handleHardWordSave() {
  const display = els.hardWordInput?.value.trim() ?? '';
  const ipaInput = els.hardWordIpa?.value.trim() ?? '';
  const sentenceText = els.hardWordContext?.value.trim() ?? '';

  if (!display) {
    showHardWordsEditFeedback('Hãy nhập từ tiếng Anh.', true);
    return;
  }

  if (ipaInput) setCachedIpa(display, ipaInput, { manual: true });

  const result = saveManualHardWord(hardWords, {
    id: editingHardWordId ?? undefined,
    display,
    ipa: ipaInput,
    sentenceText,
  });

  if (!result.id) {
    showHardWordsEditFeedback(
      result.error === 'empty' ? 'Hãy nhập từ tiếng Anh hợp lệ.' : 'Không lưu được từ.',
      true,
    );
    return;
  }

  hardWords = result.words;
  saveHardWords(hardWords);
  updateHardWordsToggleUi();
  closeHardWordEditor();
  renderHardWordsPanel();

  if (!ipaInput) {
    void lookupIpa(display).then((value) => {
      const item = hardWords.find((entry) => entry.id === result.id);
      if (!item || item.ipaManual || !value) return;
      item.ipa = value;
      saveHardWords(hardWords);
      if (els.hardWordsPanel && !els.hardWordsPanel.classList.contains('hidden')) {
        renderHardWordsPanel();
      }
    });
  }
}

function renderHardWordsPanel() {
  if (!els.hardWordsTbody || !els.hardWordsSummary) return;

  const selectedCount = getSelectedHardWords(hardWords).length;
  els.hardWordsSummary.textContent = hardWords.length
    ? `${hardWords.length} từ · ${selectedCount} đã chọn để luyện`
    : '';

  const isEmpty = !hardWords.length;
  els.hardWordsEmpty?.classList.toggle('hidden', !isEmpty);
  els.hardWordsTbody.parentElement?.parentElement?.classList.toggle('hidden', isEmpty);

  els.hardWordsTbody.innerHTML = '';
  for (const entry of hardWords) {
    const tr = document.createElement('tr');

    const selectTd = document.createElement('td');
    selectTd.className = 'col-select';
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.checked = entry.selected;
    checkbox.setAttribute('aria-label', `Chọn từ ${entry.display}`);
    checkbox.addEventListener('change', () => {
      hardWords = setHardWordSelected(hardWords, entry.id, checkbox.checked);
      saveHardWords(hardWords);
      renderHardWordsPanel();
    });
    selectTd.appendChild(checkbox);

    const wordTd = document.createElement('td');
    wordTd.className = 'word-cell';
    const wordBlock = document.createElement('div');
    wordBlock.className = 'hard-word-block';
    const wordText = document.createElement('div');
    wordText.className = 'hard-word-text';
    wordText.textContent = entry.display;
    const ipaLine = document.createElement('div');
    renderHardWordIpaLine(ipaLine, entry);
    wordBlock.append(wordText, ipaLine);
    wordTd.appendChild(wordBlock);

    const countTd = document.createElement('td');
    countTd.textContent = entry.manual ? 'Tự thêm' : String(entry.misreadCount);

    const contextTd = document.createElement('td');
    contextTd.className = 'context-cell';
    contextTd.title = entry.sentenceText || entry.lessonTitle;
    contextTd.textContent = entry.sentenceText || entry.lessonTitle || '—';

    const actionTd = document.createElement('td');
    actionTd.className = 'col-action';
    const rowActions = document.createElement('div');
    rowActions.className = 'hard-words-row-actions';
    const editBtn = document.createElement('button');
    editBtn.type = 'button';
    editBtn.className = 'backup-btn edit-btn';
    editBtn.textContent = 'Sửa';
    editBtn.addEventListener('click', () => openHardWordEditor(entry.id));
    const learnedBtn = document.createElement('button');
    learnedBtn.type = 'button';
    learnedBtn.className = 'backup-btn learned-btn';
    learnedBtn.textContent = 'Đã học';
    learnedBtn.addEventListener('click', () => {
      markHardWordLearned(entry.id);
    });
    rowActions.append(editBtn, learnedBtn);
    actionTd.appendChild(rowActions);

    tr.append(selectTd, wordTd, countTd, contextTd, actionTd);
    els.hardWordsTbody.appendChild(tr);
  }

  if (els.btnHardWordsPractice) {
    els.btnHardWordsPractice.disabled = selectedCount === 0;
    els.btnHardWordsPractice.textContent = selectedCount
      ? `Luyện từ đã chọn (${selectedCount})`
      : 'Luyện từ đã chọn';
  }
}

/**
 * @param {string} id
 */
function markHardWordLearned(id) {
  hardWords = removeHardWord(hardWords, id);
  saveHardWords(hardWords);
  updateHardWordsToggleUi();

  if (lessonPhase === 'wordbank') {
    const current = wordBankQueue[wordBankIndex];
    if (current?.key === id) {
      wordBankQueue.splice(wordBankIndex, 1);
      els.remediationSuccess?.classList.add('hidden');
      lastFinalResultIndex = -1;
      lastInterimText = '';
      if (!wordBankQueue.length) {
        exitWordBankPractice();
      } else if (wordBankIndex >= wordBankQueue.length) {
        wordBankIndex = 0;
        render();
        maybeAutoReadWordBankSample();
      } else {
        render();
        maybeAutoReadWordBankSample();
      }
    } else {
      wordBankQueue = wordBankQueue.filter((item) => item.key !== id);
      if (!wordBankQueue.length) exitWordBankPractice();
      else if (wordBankIndex >= wordBankQueue.length) wordBankIndex = wordBankQueue.length - 1;
      render();
    }
  }

  renderHardWordsPanel();
}

function startWordBankPractice() {
  const selected = getSelectedHardWords(hardWords);
  if (!selected.length) {
    if (els.hardWordsSummary) {
      els.hardWordsSummary.textContent = 'Hãy chọn ít nhất một từ để luyện.';
    }
    return;
  }

  const shouldResumeMic = pauseMicForContextChange({ autoEnableMic: true });
  toggleHardWordsPanel(false);
  lessonPhaseBeforeWordBank = lessonPhase === 'wordbank' ? 'reading' : lessonPhase;
  wordBankQueue = selected.map((entry) => ({
    key: entry.id,
    display: entry.display,
    normalized: entry.normalized,
    sentenceText: entry.sentenceText || entry.lessonTitle,
    lessonTitle: entry.lessonTitle,
  }));
  wordBankIndex = 0;
  lessonPhase = 'wordbank';
  els.remediationSuccess?.classList.add('hidden');
  lastFinalResultIndex = -1;
  lastInterimText = '';
  void prefetchIpa(wordBankQueue.map((item) => item.normalized)).then(() => render());
  render();
  resumeMicAfterContextChange(shouldResumeMic);
  maybeAutoReadWordBankSample();
}

function exitWordBankPractice() {
  lessonPhase = lessonPhaseBeforeWordBank === 'wordbank' ? 'reading' : lessonPhaseBeforeWordBank;
  if (lessonPhase === 'done') lessonComplete = true;
  wordBankQueue = [];
  wordBankIndex = 0;
  els.remediationSuccess?.classList.add('hidden');
  lastFinalResultIndex = -1;
  lastInterimText = '';
  render();
  if (micUserEnabled && !micAwaitingGesture && !lessonComplete) restartMic();
}

function maybeAutoReadWordBankSample() {
  if (lessonPhase !== 'wordbank' || !autoReadSample || samplePlaying || isSpeaking()) return;
  const item = wordBankQueue[wordBankIndex];
  if (!item) return;
  void speakText(item.display);
}

function advanceWordBankSkip() {
  els.remediationSuccess?.classList.add('hidden');
  lastFinalResultIndex = -1;
  lastInterimText = '';
  if (wordBankIndex >= wordBankQueue.length - 1) {
    exitWordBankPractice();
    return;
  }
  wordBankIndex += 1;
  render();
  maybeAutoReadWordBankSample();
}

function markCurrentWordBankLearned() {
  const item = wordBankQueue[wordBankIndex];
  if (!item) return;
  markHardWordLearned(item.key);
}

function formatHistoryDate(timestamp) {
  if (!timestamp) return '—';
  return new Intl.DateTimeFormat('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(timestamp));
}

function formatHistoryDuration(startedAt, updatedAt) {
  if (!startedAt || !updatedAt || updatedAt <= startedAt) return 'Dưới 1 phút';
  const minutes = Math.max(1, Math.round((updatedAt - startedAt) / 60000));
  return `${minutes} phút`;
}

function createHistoryStat(label, value) {
  const card = document.createElement('div');
  card.className = 'history-stat';

  const valueEl = document.createElement('strong');
  valueEl.textContent = value;

  const labelEl = document.createElement('span');
  labelEl.textContent = label;

  card.append(valueEl, labelEl);
  return card;
}

function renderStudyHistory() {
  if (!els.historySummary || !els.historyList || !els.historyDetail) return;

  const totalSessions = studyHistory.length;
  const completedSessions = studyHistory.filter((item) => item.completedAt).length;
  const averagePercent = totalSessions
    ? Math.round(studyHistory.reduce((sum, item) => sum + (item.percentComplete || 0), 0) / totalSessions)
    : 0;
  const totalSkips = studyHistory.reduce((sum, item) => sum + (item.manualSkipCount || 0), 0);

  els.historySummary.replaceChildren(
    createHistoryStat('Lần học', String(totalSessions)),
    createHistoryStat('Hoàn thành', String(completedSessions)),
    createHistoryStat('Trung bình', `${averagePercent}%`),
    createHistoryStat('Bấm qua câu', String(totalSkips)),
  );

  els.historyList.innerHTML = '';

  if (!studyHistory.length) {
    const empty = document.createElement('li');
    empty.className = 'history-empty';
    empty.textContent = 'Chưa có lịch sử học.';
    els.historyList.appendChild(empty);
    els.historyDetail.innerHTML = '<p class="history-empty">Hoàn thành hoặc luyện một bài để xem review.</p>';
    return;
  }

  if (!selectedHistorySessionId || !studyHistory.some((item) => item.sessionId === selectedHistorySessionId)) {
    selectedHistorySessionId = studyHistory[0].sessionId;
  }

  for (const session of studyHistory.slice(0, HISTORY_LIMIT)) {
    const li = document.createElement('li');
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'history-item';
    btn.classList.toggle('is-selected', session.sessionId === selectedHistorySessionId);
    btn.addEventListener('click', () => {
      selectedHistorySessionId = session.sessionId;
      renderStudyHistory();
    });

    const title = document.createElement('span');
    title.className = 'history-item-title';
    title.textContent = session.lessonTitle;

    const meta = document.createElement('span');
    meta.className = 'history-item-meta';
    meta.textContent = `${formatHistoryDate(session.updatedAt)} · ${session.percentComplete || 0}% · ${session.completedSentenceCount || 0}/${session.totalSentenceCount || 0} câu`;

    const flags = document.createElement('span');
    flags.className = 'history-item-flags';
    flags.textContent = session.manualSkipCount
      ? `Bấm qua ${session.manualSkipCount} lần`
      : session.completedAt
        ? 'Hoàn thành'
        : 'Đang học';

    btn.append(title, meta, flags);
    li.appendChild(btn);
    els.historyList.appendChild(li);
  }

  const selected = studyHistory.find((item) => item.sessionId === selectedHistorySessionId) ?? studyHistory[0];
  renderHistoryDetail(selected);
}

function renderHistoryDetail(session) {
  els.historyDetail.replaceChildren();

  const header = document.createElement('div');
  header.className = 'history-detail-head';

  const title = document.createElement('h5');
  title.textContent = session.lessonTitle;

  const meta = document.createElement('p');
  meta.textContent = `${session.level?.toUpperCase() || ''} · ${getTopicLabel(session.topic)} · ${formatHistoryDate(session.startedAt)} · ${formatHistoryDuration(session.startedAt, session.updatedAt)}`;

  const percent = document.createElement('strong');
  percent.className = 'history-percent';
  percent.textContent = `${session.percentComplete || 0}%`;

  header.append(title, meta, percent);
  els.historyDetail.appendChild(header);

  const warning = document.createElement('p');
  warning.className = session.manualSkipCount ? 'history-warning' : 'history-ok';
  warning.textContent = session.manualSkipCount
    ? `Có ${session.manualSkipCount} lần bấm qua câu khi câu chưa hoàn thành.`
    : 'Không phát hiện bấm qua câu chưa hoàn thành.';
  els.historyDetail.appendChild(warning);

  const list = document.createElement('ol');
  list.className = 'history-sentence-list';

  for (const item of session.sentences || []) {
    const li = document.createElement('li');
    li.className = item.completed ? 'is-complete' : 'is-incomplete';

    const sentence = document.createElement('p');
    sentence.className = 'history-sentence-text';
    sentence.textContent = item.text;

    const status = document.createElement('p');
    status.className = 'history-sentence-status';
    status.textContent = item.completed
      ? 'Đã đọc được toàn bộ câu.'
      : `Đọc được ${item.matchedWordCount}/${item.totalWordCount} từ.`;

    li.append(sentence, status);

    if (!item.completed && item.missingWords?.length) {
      const missing = document.createElement('p');
      missing.className = 'history-missing-words';
      missing.textContent = `Từ chưa đọc được: ${item.missingWords.join(', ')}`;
      li.appendChild(missing);
    }

    const skipped = session.manualSkippedSentences?.find((skip) => skip.index === item.index);
    if (skipped) {
      const skipBadge = document.createElement('p');
      skipBadge.className = 'history-skip-badge';
      skipBadge.textContent = `Đã bấm qua câu này ${skipped.count} lần`;
      li.appendChild(skipBadge);
    }

    list.appendChild(li);
  }

  els.historyDetail.appendChild(list);
}

function saveSettings() {
  try {
    localStorage.setItem(
      SETTINGS_KEY,
      JSON.stringify({
        autoReadSample,
        autoReadDefaultVersion: AUTO_READ_DEFAULT_VERSION,
        showVietnameseDefaultVersion: SHOW_VIETNAMESE_DEFAULT_VERSION,
        topicFilter,
        levelFilter,
        ttsVoiceUri,
        ttsSpeechRate,
        pronunciationAccuracy,
        showVietnamese,
      }),
    );
  } catch {
    /* ignore */
  }
}

function populateLessonSelect() {
  const filtered = filterLessons({ topic: topicFilter, level: levelFilter }, getAllLessons());
  const previousId = els.lessonSelect.value;
  els.lessonSelect.innerHTML = '';

  if (!filtered.length) {
    const opt = document.createElement('option');
    opt.value = '';
    opt.textContent = 'Không có bài phù hợp';
    opt.disabled = true;
    els.lessonSelect.appendChild(opt);
    return;
  }

  const customFiltered = filtered
    .filter((l) => l.custom && !isBuiltinLessonId(l.id))
    .slice()
    .sort(compareLessonsInBranch);
  const builtInFiltered = filtered
    .filter((l) => !l.custom || isBuiltinLessonId(l.id))
    .slice()
    .sort(compareLessonsInBranch);

  if (customFiltered.length) {
    const customGroup = document.createElement('optgroup');
    customGroup.label = 'Bài của tôi';

    for (const item of customFiltered) {
      const opt = document.createElement('option');
      opt.value = item.id;
      const topicName = getTopicLabel(item.topic);
      opt.textContent = `${item.title} · ${topicName}`;
      customGroup.appendChild(opt);
    }

    els.lessonSelect.appendChild(customGroup);
  }

  const ieltsFiltered = builtInFiltered.filter((l) => l.topic === 'ielts');
  if (ieltsFiltered.length) {
    const ieltsGroup = document.createElement('optgroup');
    ieltsGroup.label = 'IELTS Speaking';

    for (const item of ieltsFiltered) {
      const opt = document.createElement('option');
      opt.value = item.id;
      opt.textContent = `${item.title} · ${item.level.toUpperCase()}`;
      ieltsGroup.appendChild(opt);
    }

    els.lessonSelect.appendChild(ieltsGroup);
  }

  const generalFiltered = builtInFiltered.filter((l) => l.topic !== 'ielts');
  for (const lvl of LEVELS) {
    const lessonsAtLevel = generalFiltered.filter((l) => l.level === lvl.id);
    if (!lessonsAtLevel.length) continue;

    const group = document.createElement('optgroup');
    group.label = lvl.label;

    for (const item of lessonsAtLevel) {
      const opt = document.createElement('option');
      opt.value = item.id;
      const topicName = getTopicLabel(item.topic);
      opt.textContent = `${item.title} · ${topicName}`;
      group.appendChild(opt);
    }

    els.lessonSelect.appendChild(group);
  }

  const stillVisible = filtered.some((l) => l.id === resolveLessonId(previousId));
  if (stillVisible && previousId) {
    els.lessonSelect.value = resolveLessonId(previousId);
  } else if (filtered.length) {
    els.lessonSelect.value = filtered[0].id;
  }
}

/**
 * @param {{ autoEnableMic?: boolean }=} options
 */
async function onFiltersChanged(options = {}) {
  topicFilter = els.topicSelect.value;
  levelFilter = els.levelFilter.value;
  saveSettings();
  setLessonLoading(true);
  try {
    await preloadLessonData(topicFilter, levelFilter);
    populateLessonSelect();
    if (els.lessonSelect.value) {
      await switchLesson(els.lessonSelect.value, options);
    }
    refreshTopicTreeIfOpen();
  } finally {
    setLessonLoading(false);
  }
}

function bindEvents() {
  els.lessonSelect.addEventListener('change', () => {
    void switchLesson(els.lessonSelect.value).then(() => refreshTopicTreeIfOpen());
  });

  els.voiceSelect.addEventListener('change', () => {
    ttsVoiceUri = els.voiceSelect.value;
    setSelectedVoiceUri(ttsVoiceUri);
    saveSettings();
  });

  els.speechRateSelect?.addEventListener('change', () => {
    ttsSpeechRate = normalizeSpeechRate(els.speechRateSelect.value);
    setSelectedSpeechRate(ttsSpeechRate);
    saveSettings();
  });

  els.pronunciationAccuracySelect?.addEventListener('change', () => {
    pronunciationAccuracy = normalizePronunciationAccuracy(els.pronunciationAccuracySelect.value);
    setPronunciationAccuracy(pronunciationAccuracy);
    saveSettings();
  });

  els.topicSelect.addEventListener('change', () => {
    levelFilter = 'all';
    populateLevelFilter();
    void onFiltersChanged({ autoEnableMic: true });
  });
  els.levelFilter.addEventListener('change', () => {
    void onFiltersChanged({ autoEnableMic: true });
  });

  els.autoReadSample.addEventListener('change', () => {
    autoReadSample = els.autoReadSample.checked;
    updateAutoReadUi();
    saveSettings();
  });

  els.btnAutoRead.addEventListener('click', () => {
    autoReadSample = !autoReadSample;
    updateAutoReadUi();
    saveSettings();
  });

  els.btnShowVietnamese?.addEventListener('click', () => {
    showVietnamese = !showVietnamese;
    updateVietnameseUi();
    saveSettings();
    render();
  });

  els.btnMicToggle.addEventListener('click', toggleMic);
  els.btnReadSample.addEventListener('click', readCurrentSample);
  els.btnReadRemaining.addEventListener('click', readRemainingWords);
  els.btnPrevSentence.addEventListener('click', goPrevSentence);
  els.btnNextSentence.addEventListener('click', goNextSentence);
  els.btnResetSentence.addEventListener('click', resetCurrentSentence);
  els.btnResetLesson.addEventListener('click', resetLesson);
  els.btnRestart.addEventListener('click', () => {
    resetLesson();
    if (!micUserEnabled) {
      micUserEnabled = true;
      micAwaitingGesture = false;
      startMic();
    }
  });
  els.btnNextLesson?.addEventListener('click', loadNextLessonOfSameLevel);

  els.btnImportSave.addEventListener('click', handleImportSave);
  els.importFile.addEventListener('change', handleImportFile);
  els.btnCustomExport.addEventListener('click', () => {
    void exportCustomLessons();
  });
  els.backupImportFile.addEventListener('change', handleBackupImportFile);
  els.importFormat.addEventListener('change', updateImportFormatUi);
  els.btnDeleteCustom.addEventListener('click', deleteCurrentCustomLesson);
  els.btnConfirmDeleteCancel?.addEventListener('click', hideDeleteConfirm);
  els.btnConfirmDeleteOk?.addEventListener('click', () => {
    confirmPendingLessonDelete();
  });
  els.confirmDeleteOverlay?.addEventListener('click', (event) => {
    if (event.target === els.confirmDeleteOverlay) hideDeleteConfirm();
  });
  document.addEventListener('keydown', (event) => {
    if (event.key !== 'Escape') return;
    if (!els.confirmDeleteOverlay || els.confirmDeleteOverlay.classList.contains('hidden')) return;
    hideDeleteConfirm();
  });
  els.btnEditLesson.addEventListener('click', () => toggleEditPanel());
  els.btnEditClose.addEventListener('click', () => toggleEditPanel(false));
  els.btnEditCancel.addEventListener('click', () => toggleEditPanel(false));
  els.btnAddLevel.addEventListener('click', handleAddLevelPrompt);
  els.btnAddTopic.addEventListener('click', handleAddTopicPrompt);
  els.btnDeleteTopic.addEventListener('click', handleDeleteTopic);
  els.editTopic.addEventListener('change', updateEditTopicDeleteBtn);
  els.btnEditSave.addEventListener('click', () => {
    void handleEditSave();
  });
  els.btnMoveLesson?.addEventListener('click', () => toggleMovePanel());
  els.btnMoveClose?.addEventListener('click', () => toggleMovePanel(false));
  els.btnMoveCancel?.addEventListener('click', () => toggleMovePanel(false));
  els.btnMoveSave?.addEventListener('click', () => {
    void handleMoveSave();
  });
  els.btnMoveSelectTopic?.addEventListener('click', () => {
    setMoveSelectedIds(lessonIdsForMoveScope('topic'), true);
    syncMovePickerCheckboxes();
    updateMoveSelectedCount();
  });
  els.btnMoveSelectLevel?.addEventListener('click', () => {
    setMoveSelectedIds(lessonIdsForMoveScope('level'), true);
    syncMovePickerCheckboxes();
    updateMoveSelectedCount();
  });
  els.btnMoveSelectNone?.addEventListener('click', () => {
    moveSelectedIds.clear();
    syncMovePickerCheckboxes();
    updateMoveSelectedCount();
  });
  els.btnTopicTreeToggle?.addEventListener('click', () => toggleTopicTreePanel());
  els.btnTopicTreeClose?.addEventListener('click', () => toggleTopicTreePanel(false));
  els.btnImportToggle.addEventListener('click', () => toggleImportPanel());
  els.btnImportClose.addEventListener('click', () => toggleImportPanel(false));
  els.btnHistoryToggle.addEventListener('click', () => toggleHistoryPanel());
  els.btnHistoryClose.addEventListener('click', () => toggleHistoryPanel(false));
  els.btnHistoryClear.addEventListener('click', () => {
    if (!confirm('Xóa toàn bộ lịch sử học?')) return;
    studyHistory = [];
    currentHistorySessionId = '';
    selectedHistorySessionId = '';
    saveStudyHistory();
    renderStudyHistory();
  });

  els.btnLessonChunks?.addEventListener('click', () => toggleLessonChunksPanel());
  els.btnLessonChunksClose?.addEventListener('click', () => toggleLessonChunksPanel(false));
  els.lessonChunksList?.addEventListener('click', onLessonChunksClick);
  els.btnHardWordsToggle?.addEventListener('click', () => toggleHardWordsPanel());
  els.btnHardWordsAdd?.addEventListener('click', () => openHardWordEditor());
  els.btnHardWordsClose?.addEventListener('click', () => {
    closeHardWordEditor();
    toggleHardWordsPanel(false);
  });
  els.btnHardWordSave?.addEventListener('click', () => {
    handleHardWordSave();
  });
  els.btnHardWordCancel?.addEventListener('click', () => closeHardWordEditor());
  els.btnHardWordFetchIpa?.addEventListener('click', () => {
    void fetchHardWordIpaForForm({ force: true });
  });
  els.hardWordInput?.addEventListener('blur', (event) => {
    const next = event.relatedTarget;
    if (next === els.hardWordIpa || next === els.btnHardWordFetchIpa || next === els.btnHardWordSave) {
      return;
    }
    if (!els.hardWordIpa?.value.trim() && els.hardWordInput?.value.trim()) {
      void fetchHardWordIpaForForm();
    }
  });
  [els.hardWordInput, els.hardWordIpa, els.hardWordContext].forEach((input) => {
    input?.addEventListener('keydown', (event) => {
      if (event.key !== 'Enter') return;
      event.preventDefault();
      handleHardWordSave();
    });
  });
  els.btnHardWordsSelectAll?.addEventListener('click', () => {
    hardWords = setAllHardWordsSelected(hardWords, true);
    saveHardWords(hardWords);
    renderHardWordsPanel();
  });
  els.btnHardWordsSelectNone?.addEventListener('click', () => {
    hardWords = setAllHardWordsSelected(hardWords, false);
    saveHardWords(hardWords);
    renderHardWordsPanel();
  });
  els.btnHardWordsPractice?.addEventListener('click', () => startWordBankPractice());
  els.btnPracticeLearned?.addEventListener('click', () => markCurrentWordBankLearned());
  els.btnPracticeSkip?.addEventListener('click', () => advanceWordBankSkip());
  els.btnPracticeExit?.addEventListener('click', () => exitWordBankPractice());

  importDictation = createImportDictation({
    getSpeechRecognitionCtor,
    requestMicrophonePermission,
    getTextarea: () => els.importContent,
    onFeedback: showImportFeedback,
    onListeningChange: (active) => {
      if (active && (listening || micStarting)) {
        stopMic({ keepEnabled: true });
      }
    },
    elements: {
      wrap: els.importDictationWrap,
      statusEl: els.importDictationStatus,
      liveEl: els.importDictationLive,
      btnToggle: els.btnImportDictationToggle,
      btnNext: els.btnImportDictationNext,
    },
  });
  updateImportFormatUi();
}

function updateImportFormatUi() {
  const isJson = els.importFormat.value === 'json';
  els.importContentLabel.textContent = isJson
    ? 'Nội dung JSON'
    : 'Nội dung các câu';
  els.importContent.placeholder = isJson
    ? '{\n  "title": "My lesson",\n  "level": "b1",\n  "sentences": ["I do my homework after I get home from school."],\n  "translations": ["Tôi làm bài tập về nhà sau khi tan học."]\n}'
    : 'I do my homework after I get home from school.\nTôi làm bài tập về nhà sau khi tan học.';
  els.importTitle.closest('.import-field')?.classList.toggle('hidden', isJson);
  els.importLevel.closest('.import-field')?.classList.toggle('hidden', isJson);
  els.importTopic.closest('.import-field')?.classList.toggle('hidden', isJson);
  importDictation?.setVisible(!isJson);
}

/**
 * @param {string} message
 * @param {boolean} isError
 */
function showImportFeedback(message, isError = false) {
  els.importFeedback.textContent = message;
  els.importFeedback.classList.remove('hidden', 'ok', 'err');
  els.importFeedback.classList.add(isError ? 'err' : 'ok');
}

function hideImportFeedback() {
  els.importFeedback.classList.add('hidden');
}

function handleImportSave() {
  hideError();
  const format = els.importFormat.value;
  const content = els.importContent.value.trim();

  if (!content) {
    showImportFeedback('Hãy nhập nội dung hoặc chọn file.', true);
    return;
  }

  if (format === 'json') {
    const { lessons, errors } = parseImportJson(content);
    if (!lessons.length) {
      showImportFeedback(errors.join(' ') || 'JSON không hợp lệ.', true);
      return;
    }
    customLessons = [...customLessons, ...lessons];
    saveCustomLessons(customLessons);
    const last = lessons[lessons.length - 1];
    afterCustomLessonsChanged(last.id, `Đã lưu ${lessons.length} bài từ JSON.`);
    return;
  }

  const { lesson: newLesson, errors } = buildCustomLesson({
    title: els.importTitle.value,
    sentences: content,
    level: els.importLevel.value,
    topic: els.importTopic.value,
  });

  if (!newLesson) {
    showImportFeedback(errors.join(' '), true);
    return;
  }

  customLessons = addCustomLesson(customLessons, newLesson);
  saveCustomLessons(customLessons);
  els.importContent.value = '';
  els.importTitle.value = '';
  afterCustomLessonsChanged(newLesson.id, `Đã lưu bài "${newLesson.title}".`);
}

/**
 * @param {Event} event
 */
function handleImportFile(event) {
  const input = /** @type {HTMLInputElement} */ (event.target);
  const file = input.files?.[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = () => {
    const text = String(reader.result ?? '');
    els.importContent.value = text;

    if (file.name.toLowerCase().endsWith('.json')) {
      els.importFormat.value = 'json';
      updateImportFormatUi();
      try {
        const data = JSON.parse(text);
        const item = Array.isArray(data) ? data[0] : data.lessons?.[0] ?? data;
        if (item?.title) els.importTitle.value = String(item.title);
      } catch {
        /* ignore */
      }
    } else {
      els.importFormat.value = 'text';
      updateImportFormatUi();
      if (!els.importTitle.value.trim()) {
        const baseName = file.name.replace(/\.[^.]+$/, '');
        els.importTitle.value = baseName;
      }
    }

    showImportFeedback(`Đã tải file "${file.name}". Bấm Lưu bài để hoàn tất.`);
  };
  reader.readAsText(file);
  input.value = '';
}

function customLessonBackupPayload() {
  return {
    app: 'Reading Aloud',
    type: 'reading-aloud-custom-lessons',
    version: 1,
    exportedAt: new Date().toISOString(),
    lessons: customLessons.map((lesson) => ({
      id: lesson.id,
      title: lesson.title,
      level: lesson.level,
      topic: lesson.topic,
      sentences: lesson.sentences,
      ...(lesson.translations?.length ? { translations: lesson.translations } : {}),
      custom: true,
      createdAt: lesson.createdAt ?? Date.now(),
    })),
  };
}

/**
 * @returns {Promise<IDBDatabase>}
 */
function openImportDirDb() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(IMPORT_DIR_DB, 1);
    request.onupgradeneeded = () => {
      const db = request.result;
      if (!db.objectStoreNames.contains(IMPORT_DIR_STORE)) {
        db.createObjectStore(IMPORT_DIR_STORE);
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error ?? new Error('Không mở được IndexedDB.'));
  });
}

/**
 * @returns {Promise<FileSystemDirectoryHandle | null>}
 */
async function loadImportDirHandle() {
  try {
    const db = await openImportDirDb();
    return await new Promise((resolve, reject) => {
      const tx = db.transaction(IMPORT_DIR_STORE, 'readonly');
      const store = tx.objectStore(IMPORT_DIR_STORE);
      const request = store.get(IMPORT_DIR_KEY);
      request.onsuccess = () => resolve(request.result ?? null);
      request.onerror = () => reject(request.error ?? new Error('Không đọc được thư mục Import.'));
    });
  } catch {
    return null;
  }
}

/**
 * @param {FileSystemDirectoryHandle} handle
 */
async function saveImportDirHandle(handle) {
  const db = await openImportDirDb();
  await new Promise((resolve, reject) => {
    const tx = db.transaction(IMPORT_DIR_STORE, 'readwrite');
    const store = tx.objectStore(IMPORT_DIR_STORE);
    store.put(handle, IMPORT_DIR_KEY);
    tx.oncomplete = () => resolve();
    tx.onerror = () => reject(tx.error ?? new Error('Không lưu được thư mục Import.'));
  });
}

/**
 * @param {FileSystemDirectoryHandle} handle
 * @returns {Promise<boolean>}
 */
async function ensureImportDirPermission(handle) {
  const options = { mode: 'readwrite' };
  if ((await handle.queryPermission(options)) === 'granted') return true;
  if ((await handle.requestPermission(options)) === 'granted') return true;
  return false;
}

/**
 * @returns {Promise<FileSystemDirectoryHandle | null>}
 */
async function resolveImportDirectory() {
  if (!('showDirectoryPicker' in window)) return null;

  const stored = await loadImportDirHandle();
  if (stored && (await ensureImportDirPermission(stored))) {
    return stored;
  }

  showImportFeedback(
    'Chọn thư mục Import trong project Reading (Reading/Import). Lần sau sẽ lưu thẳng vào đây.',
  );

  const handle = await window.showDirectoryPicker({
    id: 'reading-import-folder',
    mode: 'readwrite',
    startIn: 'documents',
  });

  await saveImportDirHandle(handle);
  return handle;
}

/**
 * Trả về tên file chưa tồn tại trong thư mục, tự thêm " (2)", " (3)", ...
 * @param {FileSystemDirectoryHandle} dir
 * @param {string} fileName  ví dụ "reading-my-lessons-2026-09-08.json"
 * @returns {Promise<string>}
 */
async function uniqueFileNameInDir(dir, fileName) {
  const dot = fileName.lastIndexOf('.');
  const base = dot >= 0 ? fileName.slice(0, dot) : fileName;
  const ext  = dot >= 0 ? fileName.slice(dot)   : '';
  let candidate = fileName;
  let counter = 1;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    try {
      await dir.getFileHandle(candidate, { create: false });
      // File tồn tại → thử tên kế tiếp
      counter += 1;
      candidate = `${base} (${counter})${ext}`;
    } catch {
      // File chưa tồn tại → dùng tên này
      return candidate;
    }
  }
}

/**
 * @param {FileSystemDirectoryHandle} dir
 * @param {string} fileName
 * @param {string} contents
 */
async function writeTextFileToDirectory(dir, fileName, contents) {
  const fileHandle = await dir.getFileHandle(fileName, { create: true });
  const writable = await fileHandle.createWritable();
  await writable.write(contents);
  await writable.close();
}

/**
 * @param {string} fileName
 * @param {string} contents
 */
function downloadTextFile(fileName, contents) {
  const blob = new Blob([contents], { type: 'application/json;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = fileName;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

async function exportCustomLessons() {
  if (!customLessons.length) {
    showImportFeedback('Chưa có bài nào để xuất.', true);
    return;
  }

  const payload = customLessonBackupPayload();
  const contents = JSON.stringify(payload, null, 2);
  const date = new Date().toISOString().slice(0, 10);
  const fileName = `reading-my-lessons-${date}.json`;

  try {
    const dir = await resolveImportDirectory();
    if (dir) {
      const uniqueName = await uniqueFileNameInDir(dir, fileName);
      await writeTextFileToDirectory(dir, uniqueName, contents);
      showImportFeedback(
        `Đã xuất ${customLessons.length} bài vào Import/${uniqueName}.`,
      );
      return;
    }
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      showImportFeedback('Đã hủy xuất bài.', true);
      return;
    }
  }

  downloadTextFile(fileName, contents);
  showImportFeedback(
    `Đã tải ${customLessons.length} bài (${fileName}). Hãy chuyển file vào thư mục Reading/Import.`,
  );
}

/**
 * @param {import('./lessons.js').Lesson[]} current
 * @param {import('./lessons.js').Lesson[]} incoming
 */
function mergeCustomLessons(current, incoming) {
  const byId = new Map(current.map((lesson) => [lesson.id, lesson]));
  incoming.forEach((lesson) => {
    byId.set(lesson.id, { ...lesson, custom: true });
  });
  return [...byId.values()];
}

/**
 * @param {Event} event
 */
function handleBackupImportFile(event) {
  const input = /** @type {HTMLInputElement} */ (event.target);
  const file = input.files?.[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = () => {
    const text = String(reader.result ?? '');
    const { lessons, errors } = parseImportJson(text);

    if (!lessons.length) {
      showImportFeedback(errors.join(' ') || 'File JSON không có bài hợp lệ.', true);
      input.value = '';
      return;
    }

    customLessons = mergeCustomLessons(customLessons, lessons);
    saveCustomLessons(customLessons);
    const last = lessons[lessons.length - 1];
    afterCustomLessonsChanged(last.id, `Đã nhập ${lessons.length} bài từ file "${file.name}".`);
    input.value = '';
  };

  reader.onerror = () => {
    showImportFeedback(`Không đọc được file "${file.name}".`, true);
    input.value = '';
  };

  reader.readAsText(file);
}

/**
 * @param {string} lessonId
 * @param {string} message
 */
function afterCustomLessonsChanged(lessonId, message) {
  topicFilter = 'all';
  levelFilter = 'all';
  els.topicSelect.value = topicFilter;
  populateLevelFilter();
  populateLessonSelect();
  refreshTopicTreeIfOpen();
  renderCustomLessonsList();
  els.lessonSelect.value = lessonId;
  void switchLesson(lessonId);
  showImportFeedback(message);
}

function renderCustomLessonsList() {
  if (!customLessons.length) {
    els.customLessonsList.classList.add('hidden');
    els.customLessonsUl.innerHTML = '';
    return;
  }

  els.customLessonsList.classList.remove('hidden');
  els.customLessonsUl.innerHTML = '';

  const sorted = [...customLessons].sort(
    (a, b) => (b.createdAt ?? 0) - (a.createdAt ?? 0),
  );

  for (const item of sorted) {
    const li = document.createElement('li');

    const name = document.createElement('span');
    name.textContent = item.title;

    const meta = document.createElement('span');
    meta.className = 'custom-meta';
    meta.textContent = `${item.level.toUpperCase()} · ${getTopicLabel(item.topic)} · ${item.sentences.length} câu`;

    const btnOpen = document.createElement('button');
    btnOpen.type = 'button';
    btnOpen.className = 'icon-btn icon-btn-ghost';
    btnOpen.title = 'Mở';
    btnOpen.setAttribute('aria-label', `Mở ${item.title}`);
    btnOpen.appendChild(iconFragment(ICONS.play));

    const btnDel = document.createElement('button');
    btnDel.type = 'button';
    btnDel.className = 'icon-btn icon-btn-danger';
    btnDel.title = 'Xóa';
    btnDel.setAttribute('aria-label', `Xóa ${item.title}`);
    btnDel.appendChild(iconFragment(ICONS.trash));

    btnOpen.addEventListener('click', () => {
      els.lessonSelect.value = item.id;
      void switchLesson(item.id);
    });
    btnDel.addEventListener('click', () => deleteCustomLessonById(item.id));

    li.append(name, meta, btnOpen, btnDel);
    els.customLessonsUl.appendChild(li);
  }
}

/**
 * @param {string} lessonId
 */
function deleteCustomLessonById(lessonId) {
  const target = customLessons.find((l) => l.id === lessonId);
  if (!target) return;
  showDeleteConfirm(target.id, target.title);
}

function showDeleteConfirm(lessonId, title) {
  pendingDeleteLessonId = lessonId;
  if (els.confirmDeleteMessage) {
    els.confirmDeleteMessage.innerHTML = '';
    els.confirmDeleteMessage.append(
      'Bạn có chắc muốn xóa bài ',
      Object.assign(document.createElement('strong'), { textContent: `“${title}”` }),
      '? Thao tác này không hoàn lại được.',
    );
  }
  els.confirmDeleteOverlay?.classList.remove('hidden');
  els.btnConfirmDeleteCancel?.focus();
}

function hideDeleteConfirm() {
  pendingDeleteLessonId = '';
  els.confirmDeleteOverlay?.classList.add('hidden');
}

function confirmPendingLessonDelete() {
  const lessonId = pendingDeleteLessonId;
  if (!lessonId) {
    hideDeleteConfirm();
    return;
  }
  hideDeleteConfirm();
  performCustomLessonDelete(lessonId);
}

/**
 * @param {string} lessonId
 */
function performCustomLessonDelete(lessonId) {
  const target = customLessons.find((l) => l.id === lessonId);
  if (!target) return;

  customLessons = removeCustomLesson(customLessons, lessonId);
  saveCustomLessons(customLessons);
  if (lessonPlacements[lessonId] && !LESSON_INDEX.some((item) => item.id === lessonId)) {
    delete lessonPlacements[lessonId];
    saveLessonPlacements(lessonPlacements);
  }

  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const saved = JSON.parse(raw);
      if (saved.lessonId === lessonId) {
        localStorage.removeItem(STORAGE_KEY);
      }
    }
  } catch {
    /* ignore */
  }

  renderCustomLessonsList();
  populateLevelFilter();
  populateLessonSelect();
  refreshTopicTreeIfOpen();

  if (lesson?.id === lessonId) {
    if (els.lessonSelect.value) {
      void switchLesson(els.lessonSelect.value);
    }
  }

  showImportFeedback(`Đã xóa bài "${target.title}".`);
}

function deleteCurrentCustomLesson() {
  if (!lesson?.custom) return;
  deleteCustomLessonById(lesson.id);
}

function populateEditForm() {
  const currentLevel = els.editLevel.value;
  const currentTopic = els.editTopic.value;
  els.editLevel.innerHTML = LEVELS.map(
    (l) => `<option value="${l.id}">${l.label}</option>`,
  ).join('');
  els.editTopic.innerHTML = TOPICS.map(
    (t) => `<option value="${t.id}">${t.label}</option>`,
  ).join('');
  if ([...els.editLevel.options].some((option) => option.value === currentLevel)) {
    els.editLevel.value = currentLevel;
  }
  if ([...els.editTopic.options].some((option) => option.value === currentTopic)) {
    els.editTopic.value = currentTopic;
  }
  updateEditTopicDeleteBtn();
}

function updateEditTopicDeleteBtn() {
  const selectedTopicId = els.editTopic.value;
  const isCustomTopic = !BUILTIN_TOPICS.some((t) => t.id === selectedTopicId);
  els.btnDeleteTopic.classList.toggle('hidden', !isCustomTopic);
}

function toggleEditPanel(force) {
  const isHidden = els.editPanel.classList.contains('hidden');
  const shouldOpen = typeof force === 'boolean' ? force : isHidden;

  if (shouldOpen) {
    if (!lesson) return;
    toggleImportPanel(false);
    toggleHistoryPanel(false);
    toggleMovePanel(false);
    toggleTopicTreePanel(false);
    toggleLessonChunksPanel(false);
    populateEditForm();
    els.editTitle.value = lesson.title;
    els.editLevel.value = lesson.level;
    els.editTopic.value = lesson.topic;

    const lines = [];
    (lesson.sentences || []).forEach((s, idx) => {
      lines.push(s);
      const vi = getSentenceTranslation(idx) || lesson.translations?.[idx];
      if (vi) lines.push(vi);
    });
    els.editContent.value = lines.join('\n');
    hideEditFeedback();
    updateEditTopicDeleteBtn();
    els.editPanel.classList.remove('hidden');
    els.editTitle.focus();
  } else {
    els.editPanel.classList.add('hidden');
    hideEditFeedback();
  }
}

function showEditFeedback(message, isError = false) {
  els.editFeedback.textContent = message;
  els.editFeedback.classList.remove('hidden', 'ok', 'err');
  els.editFeedback.classList.add(isError ? 'err' : 'ok');
}

function hideEditFeedback() {
  els.editFeedback.classList.add('hidden');
}

function populateMoveForm() {
  els.moveLevel.innerHTML = LEVELS.map(
    (l) => `<option value="${l.id}">${l.label}</option>`,
  ).join('');
  els.moveTopic.innerHTML = TOPICS.map(
    (t) => `<option value="${t.id}">${t.label}</option>`,
  ).join('');
}

function lessonIdsForMoveScope(scope) {
  const all = getAllLessons();
  if (scope === 'none') return [];
  if (scope === 'topic') {
    const topicId = topicFilter !== 'all' ? topicFilter : lesson?.topic;
    if (!topicId || topicId === 'all') return all.map((item) => item.id);
    return all.filter((item) => item.topic === topicId).map((item) => item.id);
  }
  if (scope === 'level') {
    const topicId = topicFilter !== 'all' ? topicFilter : lesson?.topic;
    const levelId = levelFilter !== 'all' ? levelFilter : lesson?.level;
    return all
      .filter((item) => {
        if (topicId && topicId !== 'all' && item.topic !== topicId) return false;
        if (levelId && levelId !== 'all' && item.level !== levelId) return false;
        return true;
      })
      .map((item) => item.id);
  }
  return [];
}

function setMoveSelectedIds(ids, selected) {
  for (const id of ids) {
    if (selected) moveSelectedIds.add(id);
    else moveSelectedIds.delete(id);
  }
}

function updateMoveSelectedCount() {
  const count = moveSelectedIds.size;
  if (els.moveSelectedCount) {
    els.moveSelectedCount.textContent = `Đang chọn ${count} bài`;
  }
  if (els.btnMoveSave) {
    els.btnMoveSave.disabled = count === 0;
  }
}

function createMoveCheckbox({ kind, label, count, ids, current }) {
  const wrap = document.createElement('label');
  wrap.className = `move-check is-${kind}`;
  if (current) wrap.classList.add('is-current');
  wrap.addEventListener('click', (event) => event.stopPropagation());

  const input = document.createElement('input');
  input.type = 'checkbox';
  input.dataset.moveIds = ids.join(',');
  const selectedCount = ids.filter((id) => moveSelectedIds.has(id)).length;
  input.checked = ids.length > 0 && selectedCount === ids.length;
  input.indeterminate = selectedCount > 0 && selectedCount < ids.length;
  input.addEventListener('change', () => {
    setMoveSelectedIds(ids, input.checked);
    syncMovePickerCheckboxes();
    updateMoveSelectedCount();
  });

  wrap.appendChild(input);
  wrap.insertAdjacentHTML('beforeend', treeIcon(kind));
  const name = document.createElement('span');
  name.className = 'topic-tree-name';
  name.textContent = label;
  wrap.appendChild(name);
  if (typeof count === 'number') {
    const badge = document.createElement('span');
    badge.className = 'topic-tree-count';
    badge.textContent = `${count} bài`;
    wrap.appendChild(badge);
  }
  return wrap;
}

function syncMovePickerCheckboxes() {
  els.moveLessonList?.querySelectorAll('input[data-move-ids]').forEach((input) => {
    const ids = String(input.dataset.moveIds || '')
      .split(',')
      .filter(Boolean);
    const selectedCount = ids.filter((id) => moveSelectedIds.has(id)).length;
    input.checked = ids.length > 0 && selectedCount === ids.length;
    input.indeterminate = selectedCount > 0 && selectedCount < ids.length;
  });
}

function createMoveDetails(key, summaryEl, childrenEl) {
  const details = document.createElement('details');
  details.open = movePickerExpanded.has(key);
  const summary = document.createElement('summary');
  const twist = document.createElement('span');
  twist.className = 'topic-tree-twist';
  twist.setAttribute('aria-hidden', 'true');
  twist.innerHTML =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>';
  summary.append(twist, summaryEl);
  details.append(summary, childrenEl);
  details.addEventListener('toggle', () => {
    if (details.open) movePickerExpanded.add(key);
    else movePickerExpanded.delete(key);
  });
  return details;
}

function renderMoveLessonPicker() {
  if (!els.moveLessonList) return;
  els.moveLessonList.innerHTML = '';
  const tree = document.createElement('ul');
  tree.className = 'topic-tree';

  for (const topic of getTopicTreeData()) {
    if (!topic.levels.length) continue;
    const li = document.createElement('li');
    li.className = 'topic-tree-item';
    const topicIds = topic.lessons.map((item) => item.id);
    const topicRow = createMoveCheckbox({
      kind: 'folder',
      label: topic.label,
      count: topicIds.length,
      ids: topicIds,
    });

    const children = document.createElement('ul');
    children.className = 'topic-tree-children';
    for (const level of topic.levels) {
      const levelLi = document.createElement('li');
      levelLi.className = 'topic-tree-item';
      const levelIds = level.lessons.map((item) => item.id);
      const levelRow = createMoveCheckbox({
        kind: 'level',
        label: level.label,
        count: levelIds.length,
        ids: levelIds,
      });
      const lessonList = document.createElement('ul');
      lessonList.className = 'topic-tree-children';
      for (const lessonItem of level.lessons) {
        const lessonLi = document.createElement('li');
        lessonLi.className = 'topic-tree-item';
        lessonLi.appendChild(
          createMoveCheckbox({
            kind: 'lesson',
            label: lessonItem.title,
            ids: [lessonItem.id],
            current: lesson?.id === lessonItem.id,
          }),
        );
        lessonList.appendChild(lessonLi);
      }
      levelLi.appendChild(
        createMoveDetails(topicTreeKey('move-level', topic.id, level.id), levelRow, lessonList),
      );
      children.appendChild(levelLi);
    }

    li.appendChild(createMoveDetails(topicTreeKey('move-topic', topic.id), topicRow, children));
    tree.appendChild(li);
  }

  els.moveLessonList.appendChild(tree);
  updateMoveSelectedCount();
}

function prepareMovePickerSelection() {
  moveSelectedIds = new Set(lesson ? [lesson.id] : []);
  movePickerExpanded = new Set();
  const topicId = lesson?.topic || (topicFilter !== 'all' ? topicFilter : '');
  const levelId = lesson?.level || (levelFilter !== 'all' ? levelFilter : '');
  if (topicId) {
    movePickerExpanded.add(topicTreeKey('move-topic', topicId));
    if (levelId) {
      movePickerExpanded.add(topicTreeKey('move-level', topicId, levelId));
    }
  }
}

function toggleMovePanel(force) {
  const isHidden = els.movePanel.classList.contains('hidden');
  const shouldOpen = typeof force === 'boolean' ? force : isHidden;

  if (shouldOpen) {
    if (!lesson) return;
    toggleImportPanel(false);
    toggleHistoryPanel(false);
    toggleEditPanel(false);
    toggleTopicTreePanel(false);
    toggleLessonChunksPanel(false);
    populateMoveForm();
    els.moveLevel.value = lesson.level;
    els.moveTopic.value = lesson.topic;
    prepareMovePickerSelection();
    renderMoveLessonPicker();
    hideMoveFeedback();
    els.movePanel.classList.remove('hidden');
    els.moveTopic.focus();
  } else {
    els.movePanel.classList.add('hidden');
    hideMoveFeedback();
  }
}

function showMoveFeedback(message, isError = false) {
  els.moveFeedback.textContent = message;
  els.moveFeedback.classList.remove('hidden', 'ok', 'err');
  els.moveFeedback.classList.add(isError ? 'err' : 'ok');
}

function hideMoveFeedback() {
  els.moveFeedback.classList.add('hidden');
}

async function handleMoveSave() {
  const selectedIds = [...moveSelectedIds];
  if (!selectedIds.length) {
    showMoveFeedback('Hãy chọn ít nhất một bài để di chuyển.', true);
    return;
  }

  const targetTopic = String(els.moveTopic.value || '').trim();
  const targetLevel = String(els.moveLevel.value || '').trim();

  if (!TOPICS.some((item) => item.id === targetTopic)) {
    showMoveFeedback('Chủ đề không hợp lệ. Hãy chọn lại chủ đề.', true);
    return;
  }
  if (!LEVELS.some((item) => item.id === targetLevel)) {
    showMoveFeedback('Cấp độ không hợp lệ. Hãy chọn lại cấp độ.', true);
    return;
  }

  const selectedLessons = getAllLessons().filter((item) => selectedIds.includes(item.id));
  const toMove = selectedLessons.filter(
    (item) => item.topic !== targetTopic || item.level !== targetLevel,
  );

  if (!toMove.length) {
    showMoveFeedback('Các bài đã chọn đã ở chủ đề và cấp độ này rồi.', true);
    return;
  }

  /** @type {Record<string, { topic: string, level: string }>} */
  const entries = {};
  for (const item of toMove) {
    entries[item.id] = { topic: targetTopic, level: targetLevel };
  }
  if (!persistLessonPlacements(entries)) {
    showMoveFeedback('Không lưu được vị trí bài trên trình duyệt. Hãy thử lại.', true);
    return;
  }

  let customChanged = false;
  for (const item of toMove) {
    const existingIdx = customLessons.findIndex((custom) => custom.id === item.id);
    if (existingIdx < 0) continue;
    customLessons[existingIdx] = {
      ...customLessons[existingIdx],
      id: item.id,
      topic: targetTopic,
      level: targetLevel,
      custom: true,
    };
    customChanged = true;
  }
  const customSaveFailed = customChanged && !saveCustomLessons(customLessons);

  if (lesson && entries[lesson.id]) {
    lesson = {
      ...lesson,
      topic: targetTopic,
      level: targetLevel,
    };
  }

  topicFilter = targetTopic;
  levelFilter = targetLevel;
  els.topicSelect.value = topicFilter;
  populateLevelFilter();
  els.levelFilter.value = levelFilter;
  saveSettings();
  await preloadLessonData(topicFilter, levelFilter);
  renderCustomLessonsList();
  populateLessonSelect();
  refreshTopicTreeIfOpen();

  const focusId = lesson && selectedIds.includes(lesson.id) ? lesson.id : toMove[0]?.id;
  if (focusId && [...els.lessonSelect.options].some((option) => option.value === focusId)) {
    els.lessonSelect.value = focusId;
    await switchLesson(focusId);
  }

  const topicName = getTopicLabel(targetTopic);
  const levelName = getLevelLabel(targetLevel);
  const skipped = selectedLessons.length - toMove.length;
  const skipNote = skipped ? ` (bỏ qua ${skipped} bài đã đúng chỗ)` : '';
  showMoveFeedback(
    customSaveFailed
      ? `Đã lưu ${toMove.length} bài vào "${topicName}" · ${levelName}${skipNote}, nhưng chưa ghi được nội dung bài tùy chỉnh.`
      : `Đã lưu ${toMove.length} bài vào "${topicName}" · ${levelName}.${skipNote}`,
    customSaveFailed,
  );
  setTimeout(() => {
    toggleMovePanel(false);
  }, 1200);
}

function handleAddLevelPrompt() {
  const name = prompt('Nhập tên cấp độ mới (Ví dụ: C2 — Thành thạo, hoặc Lớp 4):');
  if (!name || !name.trim()) return;
  const newLvl = addCustomLevel(name.trim());
  if (!newLvl) {
    alert('Cấp độ này đã tồn tại hoặc không hợp lệ.');
    return;
  }
  populateFilters();
  populateImportForm();
  populateEditForm();
  els.editLevel.value = newLvl.id;
}

function handleAddTopicPrompt() {
  const name = prompt('Nhập tên chủ đề mới (Ví dụ: Phỏng vấn, Phim ảnh, Gia đình):');
  if (!name || !name.trim()) return;
  const newTop = addCustomTopic(name.trim());
  if (!newTop) {
    alert('Chủ đề này đã tồn tại hoặc không hợp lệ.');
    return;
  }
  populateFilters();
  populateImportForm();
  populateEditForm();
  els.editTopic.value = newTop.id;
  updateEditTopicDeleteBtn();
}

function handleDeleteTopic() {
  const topicId = els.editTopic.value;
  const topicObj = TOPICS.find((t) => t.id === topicId);
  if (!topicObj || BUILTIN_TOPICS.some((t) => t.id === topicId)) {
    alert('Không thể xóa chủ đề mặc định.');
    return;
  }
  if (!confirm(`Xác nhận xóa chủ đề "${topicObj.label}"?`)) return;
  removeCustomTopic(topicId);
  populateFilters();
  populateImportForm();
  populateEditForm();
}

async function handleEditSave() {
  if (!lesson) return;
  const title = els.editTitle.value.trim();
  const level = String(els.editLevel.value || '').trim();
  const topic = String(els.editTopic.value || '').trim();
  const content = els.editContent.value.trim();

  if (!title) {
    showEditFeedback('Vui lòng nhập tiêu đề bài luyện.', true);
    return;
  }
  if (!content) {
    showEditFeedback('Vui lòng nhập nội dung các câu.', true);
    return;
  }
  if (!TOPICS.some((item) => item.id === topic)) {
    showEditFeedback('Chủ đề không hợp lệ. Hãy chọn lại chủ đề.', true);
    return;
  }
  if (!LEVELS.some((item) => item.id === level)) {
    showEditFeedback('Cấp độ không hợp lệ. Hãy chọn lại cấp độ.', true);
    return;
  }

  const { lesson: built, errors } = buildCustomLesson({
    title,
    level,
    topic,
    sentences: content,
  });

  if (!built || errors.length) {
    showEditFeedback(errors[0] || 'Không thể cập nhật bài.', true);
    return;
  }

  const sourceLessonId = lesson.id;
  const existingIdx = customLessons.findIndex((item) => item.id === sourceLessonId);
  const previousCustom = existingIdx >= 0 ? customLessons[existingIdx] : null;
  const updatedLesson = {
    ...built,
    id: sourceLessonId,
    title,
    level,
    topic,
    custom: true,
    createdAt: previousCustom?.createdAt ?? Date.now(),
  };

  if (existingIdx >= 0) {
    customLessons[existingIdx] = updatedLesson;
  } else {
    customLessons.push(updatedLesson);
  }

  if (!saveCustomLessons(customLessons)) {
    if (existingIdx >= 0 && previousCustom) {
      customLessons[existingIdx] = previousCustom;
    } else {
      customLessons = customLessons.filter((item) => item.id !== sourceLessonId);
    }
    showEditFeedback('Không lưu được bài trên trình duyệt. Hãy thử lại.', true);
    return;
  }

  if (!persistLessonPlacement(sourceLessonId, topic, level)) {
    showEditFeedback('Đã lưu nội dung, nhưng chưa ghi được chủ đề / cấp độ mới.', true);
    return;
  }

  topicFilter = topic;
  levelFilter = level;
  els.topicSelect.value = topicFilter;
  populateLevelFilter();
  els.levelFilter.value = levelFilter;
  topicTreeExpanded.add(topicTreeKey('topic', topic));
  topicTreeExpanded.add(topicTreeKey('level', topic, level));

  saveSettings();
  await preloadLessonData(topicFilter, levelFilter);
  renderCustomLessonsList();
  populateLessonSelect();
  refreshTopicTreeIfOpen();
  els.lessonSelect.value = sourceLessonId;
  await switchLesson(sourceLessonId);

  showEditFeedback(
    `Đã lưu: ${title} · ${getTopicLabel(topic)} · ${getLevelLabel(level)}.`,
  );
  setTimeout(() => {
    toggleEditPanel(false);
  }, 1000);
}

async function loadSavedLesson() {
  let savedId = '';

  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const saved = JSON.parse(raw);
      if (saved.lessonId) {
        savedId = resolveLessonId(saved.lessonId);
      }
    }
  } catch {
    /* ignore */
  }

  const savedLesson = savedId ? findLessonMetaById(savedId) : null;
  if (savedLesson) {
    const visible = filterLessons(
      { topic: topicFilter, level: levelFilter },
      getAllLessons(),
    ).some((l) => l.id === savedLesson.id);
    if (!visible) {
      topicFilter = 'all';
      levelFilter = 'all';
      els.topicSelect.value = topicFilter;
      populateLevelFilter();
      await preloadLessonData(topicFilter, levelFilter);
      populateLessonSelect();
    }
    els.lessonSelect.value = savedLesson.id;
  }

  suppressAutoReadOnce = true;
  pendingAutoStartMic = false;
  if (els.lessonSelect.value) {
    await loadLesson(els.lessonSelect.value);
  }
  tryAutoStartMic();
}

/**
 * @param {import('./lessons.js').Lesson} found
 */
async function enrichLesson(found) {
  const translations =
    found.translations?.length
      ? found.translations
      : await getLessonTranslations(found.id);
  return { ...found, translations };
}

/**
 * @param {string} lessonId
 */
async function loadLesson(lessonId) {
  invalidateSamplePlayback();
  setLessonLoading(true);
  try {
    const meta = findLessonMetaById(lessonId);
    if (meta && !meta.custom) {
      await loadTopicLessons(meta.topic);
      await loadTranslationChunk(meta.topic);
    }
    const found = await findLessonById(lessonId);
    if (!found || !found.sentences?.length) return;

    lesson = await enrichLesson(found);
  resetLessonPracticeState();
  sentenceStates = lesson.sentences.map((s) => ({
    tokens: tokenizeSentence(s),
    matched: new Set(),
  }));

  currentSentenceIndex = 0;

  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const saved = JSON.parse(raw);
      if (saved.lessonId === resolveLessonId(lessonId) && Array.isArray(saved.matchedBySentence)) {
        saved.matchedBySentence.forEach((indices, i) => {
          if (!sentenceStates[i]) return;
          indices.forEach((idx) => sentenceStates[i].matched.add(idx));
        });
        if (typeof saved.currentSentenceIndex === 'number') {
          currentSentenceIndex = clampSentenceIndex(saved.currentSentenceIndex);
        }
      }
    }
  } catch {
    currentSentenceIndex = 0;
  }

  if (!allPriorSentencesComplete(currentSentenceIndex)) {
    currentSentenceIndex = findFirstIncompleteSentence();
  }

  lessonComplete = currentSentenceIndex >= sentenceStates.length;
  lastFinalResultIndex = -1;
  lastInterimText = '';
  hideError();
  startHistorySession();
  render();
  saveProgress();

  if (!suppressAutoReadOnce) {
    maybeAutoReadSample();
  }
  suppressAutoReadOnce = false;
  } finally {
    setLessonLoading(false);
  }
}

/**
 * @param {number} index
 * @returns {string | null}
 */
function getSentenceTranslation(index) {
  const text = lesson?.translations?.[index];
  return text ? String(text) : null;
}

function allPriorSentencesComplete(upToIndex) {
  for (let i = 0; i < upToIndex; i++) {
    const st = sentenceStates[i];
    if (!isSentenceComplete(st.matched, st.tokens.length)) return false;
  }
  return true;
}

function findFirstIncompleteSentence() {
  for (let i = 0; i < sentenceStates.length; i++) {
    const st = sentenceStates[i];
    if (!isSentenceComplete(st.matched, st.tokens.length)) return i;
  }
  return sentenceStates.length;
}

function clampSentenceIndex(idx) {
  return Math.max(0, Math.min(idx, sentenceStates.length));
}

function resetLesson() {
  const shouldResumeMic = pauseMicForContextChange();
  invalidateSamplePlayback();
  stopSpeaking();
  recordLessonReset();
  sentenceStates.forEach((st) => st.matched.clear());
  currentSentenceIndex = 0;
  lessonComplete = false;
  resetLessonPracticeState();
  lastFinalResultIndex = -1;
  lastInterimText = '';
  render();
  saveProgress();
  resumeMicAfterContextChange(shouldResumeMic);
  maybeAutoReadSample();
}

function loadNextLessonOfSameLevel() {
  if (!lesson) return;

  let nextLessons = [];
  if (lesson.custom) {
    nextLessons = getAllLessons().filter((l) => l.custom);
  } else if (lesson.topic === 'ielts') {
    nextLessons = getAllLessons().filter((l) => !l.custom && l.topic === 'ielts');
  } else {
    nextLessons = getAllLessons().filter((l) => !l.custom && l.topic !== 'ielts' && l.level === lesson.level);
  }

  if (!nextLessons.length) return;

  const currentIndex = nextLessons.findIndex((l) => l.id === lesson.id);
  let nextLesson = null;

  if (currentIndex !== -1 && currentIndex < nextLessons.length - 1) {
    nextLesson = nextLessons[currentIndex + 1];
  } else {
    nextLesson = nextLessons[0];
  }

  if (nextLesson) {
    els.lessonSelect.value = nextLesson.id;
    void switchLesson(nextLesson.id, { autoEnableMic: true });
  }
}

function resetCurrentSentence() {
  if (lessonComplete || !sentenceStates[currentSentenceIndex]) return;
  sentenceStates[currentSentenceIndex].matched.clear();
  lessonComplete = false;
  lastFinalResultIndex = -1;
  render();
  saveProgress();
}

function goPrevSentence() {
  if (lessonComplete || currentSentenceIndex <= 0) return;
  goToSentence(currentSentenceIndex - 1);
}

function goNextSentence() {
  if (lessonComplete) return;
  if (currentSentenceIndex < sentenceStates.length - 1) {
    const st = sentenceStates[currentSentenceIndex];
    if (st && !isSentenceComplete(st.matched, st.tokens.length)) {
      recordManualSkip(currentSentenceIndex);
    }
    goToSentence(currentSentenceIndex + 1);
  }
}

/**
 * @param {number} index
 */
function goToSentence(index) {
  if (!sentenceStates[index] || lessonComplete) return;

  const shouldResumeMic = pauseMicForContextChange();
  currentSentenceIndex = index;
  lessonComplete = false;
  lastFinalResultIndex = -1;
  lastInterimText = '';
  render();
  saveProgress();
  resumeMicAfterContextChange(shouldResumeMic);
  maybeAutoReadSample();
}

function renderRemediationPanel() {
  if (!els.remediationPanel) return;
  const inRemediation = lessonPhase === 'remediation' && remediationQueue.length > 0;
  const inWordBank = lessonPhase === 'wordbank' && wordBankQueue.length > 0;
  const showPractice = inRemediation || inWordBank;
  els.remediationPanel.classList.toggle('hidden', !showPractice);
  els.remediationActions?.classList.toggle('hidden', !inWordBank);
  if (!showPractice) return;

  const item = inWordBank ? wordBankQueue[wordBankIndex] : remediationQueue[remediationIndex];
  if (!item) return;

  if (els.remediationTitle) {
    els.remediationTitle.textContent = inWordBank ? 'Luyện từ khó' : 'Ôn từ khó';
  }
  if (els.remediationIntro) {
    els.remediationIntro.textContent = inWordBank
      ? 'Đọc to từ bên dưới. Bấm «Đã học» khi bạn đã nhuần nhuyễn.'
      : 'Các từ bạn đã đọc sai từ 5 lần trở lên. Hãy đọc lại từng từ một lần để hoàn thành bài.';
  }
  if (els.remediationWord) els.remediationWord.textContent = item.display;
  if (els.remediationContext) {
    const context = item.sentenceText
      ? `Trong câu: ${item.sentenceText}`
      : item.lessonTitle
        ? `Bài: ${item.lessonTitle}`
        : '';
    els.remediationContext.textContent = context;
  }
  if (els.remediationProgress) {
    const index = inWordBank ? wordBankIndex : remediationIndex;
    const total = inWordBank ? wordBankQueue.length : remediationQueue.length;
    els.remediationProgress.textContent = inWordBank
      ? `Từ ${index + 1} / ${total} · Còn ${hardWords.length} từ trong danh sách`
      : `Từ ${index + 1} / ${total} · Đọc đúng từ này một lần để hoàn thành bài`;
  }
  if (els.remediationIpa) {
    const bankEntry = inWordBank ? hardWords.find((entry) => entry.id === item.key) : null;
    const ipa =
      ipaHints.get(item.key) ??
      bankEntry?.ipa ??
      getCachedIpa(item.normalized);
    els.remediationIpa.textContent = ipa ? ipa : 'Đang tải IPA…';
    if (!ipa) {
      void lookupIpa(item.normalized).then((value) => {
        if (value) {
          ipaHints.set(item.key, value);
          if (bankEntry && !bankEntry.ipaManual) {
            bankEntry.ipa = value;
            saveHardWords(hardWords);
          }
        }
        render();
      });
    }
  }
}

function render() {
  if (!lesson) return;

  renderRemediationPanel();
  renderLessonChunksPanel();

  els.lessonTitle.replaceChildren();

  const topicTag = document.createElement('span');
  topicTag.className = 'topic-tag';
  topicTag.dataset.topic = lesson.topic;
  topicTag.textContent = getTopicLabel(lesson.topic);

  const levelTag = document.createElement('span');
  levelTag.className = 'level-tag';
  levelTag.dataset.level = lesson.level;
  levelTag.textContent = lesson.level.toUpperCase();

  const titleText = document.createElement('span');
  titleText.className = 'title-text';
  titleText.textContent = ` ${lesson.title}`;

  els.lessonTitle.append(topicTag, levelTag, titleText);
  els.sentencesRoot.innerHTML = '';

  sentenceStates.forEach((st, i) => {
    const block = document.createElement('div');
    block.className = 'sentence-block';

    const p = document.createElement('p');
    p.className = 'sentence';
    p.dataset.index = String(i);

    const complete = isSentenceComplete(st.matched, st.tokens.length);

    if (complete) {
      p.classList.add('done');
    } else if (i === currentSentenceIndex) {
      p.classList.add('active');
    } else {
      p.classList.add('pending');
    }

    st.tokens.forEach((tok, ti) => {
      const wrap = document.createElement('span');
      wrap.className = 'word-block';

      const span = document.createElement('span');
      span.className = 'word';
      span.textContent = tok.display;
      if (st.matched.has(ti) || complete) {
        span.classList.add('matched');
      }
      wrap.appendChild(span);

      if (shouldShowInlineIpa(i, ti, st)) {
        const key = tokenKey(i, ti);
        const ipa = ipaHints.get(key) ?? getCachedIpa(tok.normalized);
        const ipaEl = document.createElement('span');
        ipaEl.className = 'word-ipa';
        ipaEl.textContent = ipa ? ipa : '…';
        ipaEl.setAttribute('aria-label', ipa ? `Phát âm ${ipa}` : 'Đang tải IPA');
        wrap.appendChild(ipaEl);
        if (!ipa) void ensureIpaHint(i, ti);
      }

      p.appendChild(wrap);
      if (tok.hasSpaceAfter !== false && ti < st.tokens.length - 1) {
        p.appendChild(document.createTextNode(' '));
      }
    });

    block.appendChild(p);

    const viText = getSentenceTranslation(i);
    if (viText) {
      const vi = document.createElement('p');
      vi.className = 'sentence-vi';
      vi.textContent = viText;
      block.appendChild(vi);
    }

    els.sentencesRoot.appendChild(block);
  });

  const total = sentenceStates.length;
  const doneCount = sentenceStates.filter((st) =>
    isSentenceComplete(st.matched, st.tokens.length),
  ).length;

  if (lessonPhase === 'wordbank') {
    els.progressText.textContent = `Luyện từ khó · ${wordBankIndex + 1} / ${wordBankQueue.length}`;
  } else if (lessonPhase === 'remediation') {
    els.progressText.textContent = `Ôn từ khó · ${remediationIndex + 1} / ${remediationQueue.length}`;
  } else {
    els.progressText.textContent = lessonComplete
      ? `Hoàn thành ${total} / ${total} câu`
      : `Câu ${currentSentenceIndex + 1} / ${total} · Đã xong ${doneCount} câu`;
  }

  const showCompletion = lessonComplete && lessonPhase === 'done';
  els.completionBanner.classList.toggle('hidden', !showCompletion);
  const inWordBank = lessonPhase === 'wordbank';
  const hideSentences = showCompletion || lessonPhase === 'remediation' || inWordBank;
  els.sentencesRoot.classList.toggle('hidden', hideSentences);

  const inRemediation = lessonPhase === 'remediation';
  const inPractice = inRemediation || inWordBank;
  els.btnPrevSentence.disabled = lessonComplete || inPractice || currentSentenceIndex <= 0;
  els.btnNextSentence.disabled =
    lessonComplete || inPractice || currentSentenceIndex >= sentenceStates.length - 1;
  els.btnReadSample.disabled = lessonComplete && !inWordBank;
  if (els.btnReadRemaining) {
    els.btnReadRemaining.disabled = lessonComplete || inPractice;
  }
  els.btnResetSentence.disabled = lessonComplete || inPractice;
  els.btnDeleteCustom.classList.toggle('hidden', !lesson.custom);
  els.btnEditLesson?.classList.toggle('hidden', !lesson);
  els.btnMoveLesson?.classList.toggle('hidden', !lesson);
  updateMicToggleUi();

  const activeEl = els.sentencesRoot.querySelector('.sentence.active');
  if (activeEl) {
    activeEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
}

function saveProgress() {
  if (!lesson) return;
  const payload = {
    lessonId: lesson.id,
    currentSentenceIndex,
    matchedBySentence: sentenceStates.map((st) => [...st.matched]),
  };
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
  } catch {
    /* ignore quota */
  }
  updateCurrentHistorySession();
}

/**
 * @param {string} transcript
 * @param {{ countMisreads?: boolean }} [options]
 */
function processTranscript(transcript, options = {}) {
  if (isSpeaking()) return;
  if (lessonComplete && lessonPhase !== 'wordbank') return;

  if (lessonPhase === 'wordbank') {
    processWordBankTranscript(transcript, options);
    return;
  }

  if (lessonPhase === 'remediation') {
    processRemediationTranscript(transcript, options);
    return;
  }

  if (!sentenceStates[currentSentenceIndex]) return;

  const spokenWords = wordsFromTranscript(transcript);
  if (!spokenWords.length) return;

  const st = sentenceStates[currentSentenceIndex];
  const { newlyMatched, misreadFocus } = applyTranscript(spokenWords, st.tokens, st.matched);

  if (newlyMatched.length) {
    clearStrugglingIpa(currentSentenceIndex, newlyMatched);
  }

  if (options.countMisreads) {
    const focusIdx = firstUnmatchedTokenIndex(st.tokens, st.matched);
    if (focusIdx >= 0) {
      const focusKey = tokenKey(currentSentenceIndex, focusIdx);
      if (misreadFocus) {
        recordMisread(currentSentenceIndex, focusIdx);
      } else {
        strugglingTokenKeys.delete(focusKey);
      }
    }
  }

  if (newlyMatched.length || (options.countMisreads && misreadFocus)) {
    render();
    saveProgress();
  }

  if (isSentenceComplete(st.matched, st.tokens.length)) {
    advanceSentence();
  }
}

/**
 * @param {string} transcript
 * @param {{ countMisreads?: boolean }} [options]
 */
function processRemediationTranscript(transcript, options = {}) {
  if (!options.countMisreads) return;
  const item = remediationQueue[remediationIndex];
  if (!item) return;
  if (!transcriptMatchesWord(transcript, item.normalized)) return;
  advanceRemediation();
}

/**
 * @param {string} transcript
 * @param {{ countMisreads?: boolean }} [options]
 */
function processWordBankTranscript(transcript, options = {}) {
  if (!options.countMisreads) return;
  const item = wordBankQueue[wordBankIndex];
  if (!item) return;
  if (!transcriptMatchesWord(transcript, item.normalized)) return;
  els.remediationSuccess?.classList.remove('hidden');
}

function advanceSentence() {
  if (currentSentenceIndex >= sentenceStates.length - 1) {
    currentSentenceIndex = sentenceStates.length;
    startRemediationPhase();
    return;
  }

  currentSentenceIndex += 1;
  lastFinalResultIndex = -1;
  lastInterimText = '';
  render();
  saveProgress();
  maybeAutoReadSample({ force: true });
}

function getSpeechRecognitionCtor() {
  return window.SpeechRecognition || window.webkitSpeechRecognition || null;
}

function isTrustedMicOrigin() {
  const host = window.location?.hostname;
  if (!host) return true;
  return window.isSecureContext || host === 'localhost' || host === '127.0.0.1' || host === '[::1]';
}

function explainMicError(error) {
  const name = error?.name ?? '';
  if (name === 'NotAllowedError' || name === 'PermissionDeniedError') {
    return 'Trình duyệt đang chặn microphone. Hãy bấm biểu tượng ổ khóa trên thanh địa chỉ và chọn Allow/Cho phép microphone.';
  }
  if (name === 'NotFoundError' || name === 'DevicesNotFoundError') {
    return 'Không tìm thấy microphone. Hãy kiểm tra thiết bị mic trong Windows và trình duyệt.';
  }
  if (name === 'NotReadableError' || name === 'TrackStartError') {
    return 'Microphone đang được ứng dụng khác sử dụng hoặc Windows đang chặn quyền mic.';
  }
  return 'Không thể truy cập microphone. Hãy kiểm tra quyền mic của trình duyệt rồi thử lại.';
}

async function requestMicrophonePermission() {
  if (!isTrustedMicOrigin()) {
    showError('Microphone cần HTTPS hoặc localhost. Hãy mở app qua http://127.0.0.1:8080.');
    return false;
  }

  const getUserMedia = window.navigator?.mediaDevices?.getUserMedia;
  if (!getUserMedia) return true;

  try {
    const stream = await getUserMedia.call(window.navigator.mediaDevices, { audio: true });
    stream.getTracks().forEach((track) => track.stop());
    return true;
  } catch (error) {
    showError(explainMicError(error));
    return false;
  }
}

async function startMic() {
  if (importDictation?.isListening()) return;
  if (lessonComplete || isSpeaking() || samplePlaying || micStarting) return;
  clearMicRestartTimer();

  if (!micUserEnabled) micUserEnabled = true;

  const Ctor = getSpeechRecognitionCtor();
  if (!Ctor) {
    showError(
      'Trình duyệt không hỗ trợ nhận dạng giọng nói. Hãy dùng Chrome hoặc Edge.',
    );
    return;
  }

  if (listening || recognition) return;

  micStarting = true;
  updateMicToggleUi();

  const hasMicPermission = await requestMicrophonePermission();
  if (!hasMicPermission) {
    micStarting = false;
    micAwaitingGesture = true;
    updateMicToggleUi();
    return;
  }

  if (!micUserEnabled || lessonComplete || isSpeaking() || samplePlaying) {
    micStarting = false;
    updateMicToggleUi();
    return;
  }

  const sessionGeneration = ++micSessionGeneration;
  const currentRecognition = new Ctor();
  recognition = currentRecognition;
  currentRecognition.lang = 'en-US';
  currentRecognition.continuous = true;
  currentRecognition.interimResults = true;
  currentRecognition.maxAlternatives = 1;

  lastFinalResultIndex = -1;
  lastInterimText = '';

  currentRecognition.onstart = () => {
    if (sessionGeneration !== micSessionGeneration) return;
    micStarting = false;
    listening = true;
    updateMicToggleUi();
    hideError();
  };

  currentRecognition.onend = () => {
    if (sessionGeneration !== micSessionGeneration) return;
    listening = false;
    micStarting = false;
    const shouldRestart =
      currentRecognition._wantRestart &&
      micUserEnabled &&
      !lessonComplete &&
      !isSpeaking() &&
      !samplePlaying;
    recognition = null;
    if (shouldRestart) {
      scheduleMicRestart();
    } else {
      updateMicToggleUi();
    }
  };

  currentRecognition.onerror = (event) => {
    if (sessionGeneration !== micSessionGeneration) return;
    if (event.error === 'not-allowed') {
      showError('Cần quyền microphone. Hãy bấm biểu tượng ổ khóa trên thanh địa chỉ và cho phép quyền mic.');
      stopMic({ keepEnabled: true });
      micAwaitingGesture = true;
      updateMicToggleUi();
      return;
    }
    if (event.error === 'audio-capture') {
      showError('Không lấy được âm thanh từ microphone. Hãy kiểm tra mic trong Windows và trình duyệt.');
      return;
    }
    if (event.error === 'network' || event.error === 'service-not-allowed') {
      showError('Dịch vụ nhận dạng giọng nói của trình duyệt chưa hoạt động. Hãy dùng Chrome/Edge và kiểm tra kết nối internet.');
      return;
    }
    if (event.error === 'no-speech') {
      return;
    }
    if (event.error === 'aborted') {
      return;
    }
    showError(`Lỗi mic: ${event.error}`);
  };

  currentRecognition.onresult = (event) => {
    if (sessionGeneration !== micSessionGeneration || isSpeaking() || samplePlaying) return;

    let interim = '';

    for (let i = event.resultIndex; i < event.results.length; i++) {
      const result = event.results[i];
      const text = result[0].transcript;

      if (result.isFinal) {
        if (i > lastFinalResultIndex) {
          processTranscript(text, { countMisreads: true });
          lastFinalResultIndex = i;
        }
        interim = '';
      } else {
        interim += text;
      }
    }

    if (interim) {
      lastInterimText = normalizeTranscript(interim.trim());
      els.liveTranscript.textContent = lastInterimText || '—';
      processTranscript(interim, { countMisreads: false });
    } else if (event.results[event.results.length - 1]?.isFinal) {
      const finalText = normalizeTranscript(
        event.results[event.results.length - 1][0].transcript.trim(),
      );
      els.liveTranscript.textContent = finalText || '—';
    }
  };

  currentRecognition._wantRestart = true;

  try {
    currentRecognition.start();
  } catch {
    if (sessionGeneration === micSessionGeneration) {
      invalidateMicSession();
    }
    micStarting = false;
    if (recognition === currentRecognition) {
      recognition = null;
    }
    micAwaitingGesture = micUserEnabled;
    showError('Không thể bật mic. Hãy bấm nút mic để thử lại.');
    updateMicToggleUi();
  }
}

function stopMic({ keepEnabled = false } = {}) {
  clearMicRestartTimer();

  if (!keepEnabled) {
    micUserEnabled = false;
    micAwaitingGesture = false;
  }

  invalidateMicSession();

  if (!recognition) {
    listening = false;
    micStarting = false;
    updateMicToggleUi();
    return;
  }

  const currentRecognition = recognition;
  currentRecognition._wantRestart = false;
  try {
    currentRecognition.stop();
  } catch {
    /* ignore */
  }
  recognition = null;
  listening = false;
  micStarting = false;
  updateMicToggleUi();
}

/**
 * @param {string} message
 */
function showError(message) {
  els.errorBanner.textContent = message;
  els.errorBanner.classList.remove('hidden');
}

function hideError() {
  els.errorBanner.classList.add('hidden');
  els.errorBanner.textContent = '';
}
