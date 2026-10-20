/** @type {{ id: string, label: string }[]} */
export const BUILTIN_LEVELS = [
  { id: 'a1', label: 'A1 — Sơ cấp' },
  { id: 'a2', label: 'A2 — Cơ bản' },
  { id: 'b1', label: 'B1 — Trung cấp' },
  { id: 'b2', label: 'B2 — Khá' },
  { id: 'c1', label: 'C1 — Nâng cao' },
];

/** @type {{ id: string, label: string }[]} */
export const BUILTIN_TOPICS = [
  { id: 'grade4', label: 'Lớp 4' },
  { id: 'streamline', label: 'Streamline English Departures' },
  { id: 'daily', label: 'Đời sống' },
  { id: 'travel', label: 'Du lịch' },
  { id: 'work', label: 'Công việc' },
  { id: 'study', label: 'Học tập' },
  { id: 'ielts', label: 'IELTS Speaking' },
  { id: 'toeic', label: 'TOEIC Listening' },
  { id: 'health', label: 'Sức khỏe' },
  { id: 'tech', label: 'Công nghệ' },
  { id: 'society', label: 'Xã hội' },
  { id: 'food', label: 'Ẩm thực' },
  { id: 'sports', label: 'Thể thao' },
  { id: 'communication', label: 'Giao tiếp thực tế' },
  { id: 'custom', label: 'Của tôi' },
];

export const USER_TOPICS_KEY = 'reading-aloud-user-topics';
export const USER_LEVELS_KEY = 'reading-aloud-user-levels';

let memoryTopics = [];
let memoryLevels = [];

export function loadUserTopics() {
  try {
    if (typeof localStorage === 'undefined') return memoryTopics;
    const raw = localStorage.getItem(USER_TOPICS_KEY);
    if (!raw) return memoryTopics;
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : memoryTopics;
  } catch {
    return memoryTopics;
  }
}

export function saveUserTopics(topics) {
  memoryTopics = topics;
  try {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem(USER_TOPICS_KEY, JSON.stringify(topics));
    }
  } catch {}
}

export function loadUserLevels() {
  try {
    if (typeof localStorage === 'undefined') return memoryLevels;
    const raw = localStorage.getItem(USER_LEVELS_KEY);
    if (!raw) return memoryLevels;
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : memoryLevels;
  } catch {
    return memoryLevels;
  }
}

export function saveUserLevels(levels) {
  memoryLevels = levels;
  try {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem(USER_LEVELS_KEY, JSON.stringify(levels));
    }
  } catch {}
}

export const LEVELS = [...BUILTIN_LEVELS, ...loadUserLevels()];
export const TOPICS = [...BUILTIN_TOPICS, ...loadUserTopics()];

export function refreshMeta() {
  const userLevels = loadUserLevels();
  const userTopics = loadUserTopics();

  LEVELS.length = 0;
  LEVELS.push(...BUILTIN_LEVELS, ...userLevels);

  TOPICS.length = 0;
  TOPICS.push(...BUILTIN_TOPICS, ...userTopics);
}

export function addCustomTopic(label, id = '') {
  const name = String(label || '').trim();
  if (!name) return null;
  const topicId = (
    id ||
    'topic-' +
      name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-|-$/g, '') ||
    'topic-' + Date.now()
  );
  const current = loadUserTopics();
  if (current.some((t) => t.id === topicId) || BUILTIN_TOPICS.some((t) => t.id === topicId)) {
    return null;
  }
  const newTopic = { id: topicId, label: name, custom: true };
  current.push(newTopic);
  saveUserTopics(current);
  refreshMeta();
  return newTopic;
}

export function removeCustomTopic(topicId) {
  const current = loadUserTopics();
  const filtered = current.filter((t) => t.id !== topicId);
  saveUserTopics(filtered);
  refreshMeta();
  return filtered;
}

export function addCustomLevel(label, id = '') {
  const name = String(label || '').trim();
  if (!name) return null;
  const levelId = (
    id ||
    name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '') ||
    'lvl-' + Date.now()
  );
  const current = loadUserLevels();
  if (current.some((l) => l.id === levelId) || BUILTIN_LEVELS.some((l) => l.id === levelId)) {
    return null;
  }
  const newLevel = { id: levelId, label: name, custom: true };
  current.push(newLevel);
  saveUserLevels(current);
  refreshMeta();
  return newLevel;
}

export function removeCustomLevel(levelId) {
  const current = loadUserLevels();
  const filtered = current.filter((l) => l.id !== levelId);
  saveUserLevels(filtered);
  refreshMeta();
  return filtered;
}

/** Default topic preloaded for fast first paint (common lessons + tests). */
export const DEFAULT_PRELOAD_TOPIC = 'daily';
