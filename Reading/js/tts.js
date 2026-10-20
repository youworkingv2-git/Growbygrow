/** @type {SpeechSynthesisUtterance | null} */
let currentUtterance = null;
let speaking = false;
let speakGeneration = 0;
/** @type {{ gen: number, resolve: (ok: boolean) => void } | null} */
let activeSpeak = null;
/** @type {string | null} */
let selectedVoiceUri = null;

/** @type {readonly number[]} */
export const TTS_SPEECH_RATES = [0.5, 0.75, 1, 1.25, 1.5];

const DEFAULT_SPEECH_RATE = 1;

/** @type {number} */
let selectedSpeechRate = DEFAULT_SPEECH_RATE;

/**
 * @param {unknown} rate
 * @returns {number}
 */
export function normalizeSpeechRate(rate) {
  const value = Number(rate);
  return TTS_SPEECH_RATES.includes(value) ? value : DEFAULT_SPEECH_RATE;
}

/**
 * @returns {number}
 */
export function getSelectedSpeechRate() {
  return selectedSpeechRate;
}

/**
 * @param {unknown} rate
 */
export function setSelectedSpeechRate(rate) {
  selectedSpeechRate = normalizeSpeechRate(rate);
}

/**
 * @param {number | undefined} override
 * @returns {number}
 */
export function resolveSpeechRate(override) {
  if (typeof override === 'number' && !Number.isNaN(override)) return override;
  return selectedSpeechRate;
}
/** @type {Set<() => void>} */
const voiceListeners = new Set();
/** @type {Set<string>} */
const brokenVoiceUris = new Set();

/**
 * @returns {boolean}
 */
export function isTtsSupported() {
  return typeof window !== 'undefined' && 'speechSynthesis' in window;
}

/**
 * @returns {boolean}
 */
export function isSpeaking() {
  return speaking;
}

/**
 * @returns {SpeechSynthesisVoice[]}
 */
export function getEnglishVoices() {
  if (!isTtsSupported()) return [];
  return window.speechSynthesis
    .getVoices()
    .filter((v) => {
      if (brokenVoiceUris.has(v.voiceURI)) return false;
      if (/mobile|cortana/i.test(v.name)) return false;
      return /^en(-|$)/i.test(v.lang);
    })
    .sort((a, b) => {
      const rank = (/** @type {SpeechSynthesisVoice} */ v) => {
        if (v.lang.toLowerCase().startsWith('en-us')) return 0;
        if (v.lang.toLowerCase().startsWith('en-gb')) return 1;
        if (v.lang.toLowerCase().startsWith('en')) return 2;
        return 3;
      };
      const dr = rank(a) - rank(b);
      if (dr !== 0) return dr;
      return a.name.localeCompare(b.name);
    });
}

/**
 * @param {() => void} callback
 */
export function onVoicesReady(callback) {
  if (getEnglishVoices().length) callback();
  voiceListeners.add(callback);
}

function notifyVoiceListeners() {
  if (!getEnglishVoices().length) return;
  voiceListeners.forEach((cb) => cb());
}

/**
 * @param {string | null} uri
 */
export function setSelectedVoiceUri(uri) {
  selectedVoiceUri = uri || null;
}

/**
 * @returns {string | null}
 */
export function getSelectedVoiceUri() {
  return selectedVoiceUri;
}

/**
 * @param {SpeechSynthesisVoice[]} voices
 * @returns {SpeechSynthesisVoice | undefined}
 */
function resolveVoice(voices) {
  if (!voices.length) return undefined;

  if (selectedVoiceUri) {
    const saved = voices.find((v) => v.voiceURI === selectedVoiceUri);
    if (saved) return saved;
  }

  return (
    voices.find((v) => v.lang.toLowerCase().startsWith('en-us') && v.localService) ||
    voices.find((v) => v.lang.toLowerCase().startsWith('en-us')) ||
    voices.find((v) => v.lang.toLowerCase().startsWith('en-gb')) ||
    voices[0]
  );
}

/**
 * @param {SpeechSynthesisVoice} voice
 * @returns {string}
 */
export function formatVoiceLabel(voice) {
  const lang = voice.lang.replace('_', '-');
  return `${voice.name} (${lang})`;
}

function settleActiveSpeak(ok) {
  if (!activeSpeak) return;
  const { resolve } = activeSpeak;
  activeSpeak = null;
  speaking = false;
  currentUtterance = null;
  resolve(ok);
}

function abortSpeaking() {
  speakGeneration += 1;
  if (isTtsSupported()) {
    window.speechSynthesis.cancel();
  }
  settleActiveSpeak(false);
}

export function stopSpeaking() {
  abortSpeaking();
}

/**
 * Map Vietnamese names to English phonetic approximations so standard English
 * TTS engines pronounce them naturally in Vietnamese style.
 * @type {Record<string, string>}
 */
export const VIETNAMESE_NAMES_TTS = {
  Linh: 'Lin',
  linh: 'lin',
  Minh: 'Ming',
  minh: 'ming',
  Hoa: 'Hwah',
  hoa: 'hwah',
  Mai: 'My',
  mai: 'my',
  Nam: 'Nahm',
  Lan: 'Lahn',
  Phuc: 'Fook',
  Duc: 'Dook',
  Hanh: 'Hahn',
  Trang: 'Trahng',
  Quan: 'Kwan',
  Khoa: 'Kwah',
  Ngoc: 'Nawk',
  Quang: 'Kwahng',
  Thao: 'Tow',
  Cuong: 'Kwong',
  Phuong: 'Fwong',
  Huong: 'Hwong',
  Giang: 'Zahng',
  Binh: 'Bing',
  Chau: 'Chow',
  Tung: 'Toong',
  Viet: 'Vyet',
  Hai: 'Hy',
  Hung: 'Hoong',
  Thanh: 'Tahn',
  Khanh: 'Kahn',
  Trung: 'Troong',
  Kien: 'Kyen',
  Tuan: 'Twan',
  Khang: 'Kahng',
  Trinh: 'Trin',
  Vinh: 'Vin',
  Quyen: 'Kwen',
  Thuyen: 'Twen',
  Thuy: 'Twee',
  Nguyen: 'Nwen',
  Hoang: 'Hwahng',
  Huynh: 'Hwin',
  Duong: 'Zwong',
  Hanoi: 'Hahnoy',
  Saigon: 'Sygon',
  Danang: 'Dahnang',
};

/**
 * Format text before sending to SpeechSynthesis so Vietnamese names are pronounced properly.
 * @param {string} text
 * @returns {string}
 */
export function formatTextForTts(text) {
  if (!text) return '';
  return text.replace(/\b[A-Za-zÀ-ỹ]+\b/g, (match) => {
    return VIETNAMESE_NAMES_TTS[match] || match;
  });
}

/**
 * @param {string} text
 * @param {{ rate?: number }=} options
 * @returns {Promise<boolean>}
 */
export function speakText(text, options = {}) {
  return new Promise((resolve) => {
    if (!isTtsSupported() || !text.trim()) {
      resolve(false);
      return;
    }

    abortSpeaking();

    const gen = speakGeneration;
    activeSpeak = { gen, resolve };

    const spokenText = formatTextForTts(text);
    const utterance = new SpeechSynthesisUtterance(spokenText);
    utterance.lang = 'en-US';
    utterance.rate = resolveSpeechRate(options.rate);

    const voice = resolveVoice(getEnglishVoices());
    if (voice) {
      utterance.voice = voice;
      utterance.lang = voice.lang;
    }

    const finish = (ok) => {
      if (!activeSpeak || activeSpeak.gen !== gen) return;
      settleActiveSpeak(ok);
    };

    utterance.onend = () => finish(true);
    utterance.onerror = (event) => {
      const isUserAbort = event && (event.error === 'interrupted' || event.error === 'aborted');
      if (!isUserAbort && voice) {
        console.warn(`Voice failed: ${voice.name} (${voice.voiceURI}). Error: ${event?.error}`);
        brokenVoiceUris.add(voice.voiceURI);
        notifyVoiceListeners();
      }
      finish(false);
    };

    currentUtterance = utterance;
    speaking = true;
    window.speechSynthesis.speak(utterance);
  });
}

if (isTtsSupported()) {
  window.speechSynthesis.onvoiceschanged = notifyVoiceListeners;
  notifyVoiceListeners();
  setTimeout(notifyVoiceListeners, 250);
}
