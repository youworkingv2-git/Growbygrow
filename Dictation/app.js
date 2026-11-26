const STORAGE_KEY = 'english-dictation-v1';

const TOPIC_LABELS = {
  'dictation-short-vowels': 'Nguyên âm ngắn',
  'dictation-long-vowels-diphthongs': 'Nguyên âm dài / ngữ điệu',
  'dictation-final-sounds': 'Âm cuối',
  'dictation-consonant-clusters': 'Cụm phụ âm',
  'dictation-silent-letters': 'Chữ câm',
  'dictation-th-sh-ch-j': 'th, sh, ch, j',
  'dictation-endings-s-ed': 'Đuôi -s / -ed',
  'dictation-common-words-for-vietnamese': 'Từ thường gặp',
  'sentences-daily': 'Câu — sinh hoạt hàng ngày',
  'sentences-school': 'Câu — trường học',
  'sentences-past': 'Câu — quá khứ',
  'sentences-useful': 'Câu — giao tiếp hữu ích',
};

const state = {
  page: 'home',
  theme: 'dark',
  contentMode: 'words',
  words: [],
  sentences: [],
  selectedTopic: null,
  session: null,
  loadError: '',
};

let activeAudio = null;

function loadSaved() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return;
    const saved = JSON.parse(raw);
    if (saved.theme === 'light' || saved.theme === 'dark') state.theme = saved.theme;
    if (saved.progress && typeof saved.progress === 'object') state.progress = saved.progress;
  } catch {
    /* ignore */
  }
  if (!state.progress) state.progress = {};
}

function saveSaved() {
  localStorage.setItem(
    STORAGE_KEY,
    JSON.stringify({ theme: state.theme, progress: state.progress }),
  );
}

function escapeHtml(text) {
  return String(text ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function normalizeAnswer(text) {
  return String(text ?? '')
    .trim()
    .replace(/\s+/g, ' ')
    .toLowerCase();
}

function shuffle(list) {
  const copy = [...list];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function topicLabel(topic) {
  return TOPIC_LABELS[topic] || topic.replace(/-/g, ' ');
}

function getItemsForMode() {
  if (state.contentMode === 'sentences') {
    return state.sentences.map((item) => ({
      id: item.id,
      topic: item.topic,
      answer: item.text,
      hint: item.meaning_vi,
      ipa: '',
      audio: '',
      meta: item,
    }));
  }
  return state.words.map((item) => ({
    id: item.id,
    topic: item.topic,
    answer: item.word,
    hint: item.meaning_vi,
    ipa: item.ipa_us || '',
    audio: item.audio_us || '',
    meta: item,
  }));
}

function groupByTopic(items) {
  const map = new Map();
  items.forEach((item) => {
    if (!map.has(item.topic)) map.set(item.topic, []);
    map.get(item.topic).push(item);
  });
  return [...map.entries()].sort((a, b) => topicLabel(a[0]).localeCompare(topicLabel(b[0]), 'vi'));
}

function progressKey(mode, topic) {
  return `${mode}:${topic}`;
}

function getTopicProgress(mode, topic, total) {
  const key = progressKey(mode, topic);
  const entry = state.progress[key] || { mastered: [], attempts: 0, correct: 0 };
  const masteredCount = entry.mastered.filter((id) =>
    getItemsForMode().some((item) => item.id === id && item.topic === topic),
  ).length;
  return { ...entry, masteredCount, total };
}

function recordAttempt(item, isCorrect) {
  const key = progressKey(state.contentMode, item.topic);
  const entry = state.progress[key] || { mastered: [], attempts: 0, correct: 0 };
  entry.attempts += 1;
  if (isCorrect) {
    entry.correct += 1;
    if (!entry.mastered.includes(item.id)) entry.mastered.push(item.id);
  }
  state.progress[key] = entry;
  saveSaved();
}

function diffAnswer(typed, correct) {
  const t = typed;
  const c = correct;
  const m = t.length;
  const n = c.length;
  const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0));
  for (let i = 1; i <= m; i += 1) {
    for (let j = 1; j <= n; j += 1) {
      if (t[i - 1].toLowerCase() === c[j - 1].toLowerCase()) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
      }
    }
  }
  let i = m;
  let j = n;
  const result = [];
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && t[i - 1].toLowerCase() === c[j - 1].toLowerCase()) {
      result.push(`<span class="char-correct">${escapeHtml(t[i - 1])}</span>`);
      i -= 1;
      j -= 1;
    } else if (j > 0 && (i === 0 || dp[i][j - 1] >= dp[i - 1][j])) {
      result.push(`<span class="char-missing">${escapeHtml(c[j - 1])}</span>`);
      j -= 1;
    } else {
      result.push(`<span class="char-incorrect">${escapeHtml(t[i - 1])}</span>`);
      i -= 1;
    }
  }
  return result.reverse().join('');
}

function speakText(text, rate = 1) {
  if (!('speechSynthesis' in window) || !text) return Promise.resolve();
  window.speechSynthesis.cancel();
  return new Promise((resolve) => {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'en-US';
    utterance.rate = rate;
    const voices = window.speechSynthesis.getVoices();
    const voice =
      voices.find((v) => v.lang.startsWith('en') && /US|United States/i.test(v.name)) ||
      voices.find((v) => v.lang.startsWith('en'));
    if (voice) utterance.voice = voice;
    utterance.onend = () => resolve();
    utterance.onerror = () => resolve();
    window.speechSynthesis.speak(utterance);
  });
}

function stopAudio() {
  if (activeAudio) {
    activeAudio.pause();
    activeAudio = null;
  }
  if ('speechSynthesis' in window) window.speechSynthesis.cancel();
}

async function playItem(item, rate = 1) {
  stopAudio();
  if (item.audio) {
    try {
      activeAudio = new Audio(item.audio);
      activeAudio.playbackRate = rate;
      await activeAudio.play();
      return;
    } catch {
      /* fallback to TTS */
    }
  }
  await speakText(item.answer, rate);
}

function getHint(answer, revealCount) {
  if (!revealCount) return '';
  const chars = answer.split('');
  return chars
    .map((ch, index) => (index < revealCount ? ch : ch === ' ' ? ' ' : '_'))
    .join('');
}

function startSession(topic, options = {}) {
  const all = getItemsForMode().filter((item) => item.topic === topic);
  const pool = options.onlyWrong
    ? all.filter((item) =>
        (state.session?.results || [])
          .filter((r) => !r.isCorrect)
          .some((r) => r.itemId === item.id),
      )
    : shuffle(all);
  const limit = Math.min(options.count || 10, pool.length);
  state.session = {
    topic,
    queue: pool.slice(0, limit),
    index: 0,
    results: [],
    draft: '',
    hintCount: 0,
    answered: null,
    startedAt: Date.now(),
  };
  state.page = 'practice';
  render();
  const current = state.session.queue[0];
  if (current) playItem(current);
}

function submitAnswer() {
  const session = state.session;
  if (!session || session.answered) return;
  const item = session.queue[session.index];
  const typed = session.draft;
  const isCorrect = normalizeAnswer(typed) === normalizeAnswer(item.answer);
  session.answered = { typed, isCorrect };
  session.results.push({
    itemId: item.id,
    typed,
    isCorrect,
    hintCount: session.hintCount,
  });
  recordAttempt(item, isCorrect);
  render();
}

function nextQuestion() {
  const session = state.session;
  if (!session) return;
  session.index += 1;
  session.draft = '';
  session.hintCount = 0;
  session.answered = null;
  if (session.index >= session.queue.length) {
    state.page = 'summary';
    render();
    return;
  }
  render();
  playItem(session.queue[session.index]);
}

async function loadData() {
  state.loadError = '';
  try {
    const [wordsRes, sentencesRes] = await Promise.all([
      fetch('./data/dictation-words.json'),
      fetch('./data/dictation-sentences.json'),
    ]);
    if (!wordsRes.ok) throw new Error('Không tải được dictation-words.json');
    const wordsJson = await wordsRes.json();
    state.words = wordsJson['english-dictation'] || [];
    if (sentencesRes.ok) {
      const sentencesJson = await sentencesRes.json();
      state.sentences = sentencesJson.sentences || [];
    }
  } catch (err) {
    state.loadError =
      err.message ||
      'Cần chạy qua máy chủ tĩnh (npm start). Mở file trực tiếp sẽ không tải được dữ liệu.';
  }
}

function setTheme(theme) {
  state.theme = theme;
  document.documentElement.classList.toggle('light', theme === 'light');
  saveSaved();
  render();
}

function renderHeader(title, subtitle) {
  return `
    <header class="header">
      <div class="brand">
        <div class="logo" aria-hidden="true">D</div>
        <div>
          <h1>${escapeHtml(title)}</h1>
          ${subtitle ? `<p class="muted small">${escapeHtml(subtitle)}</p>` : ''}
        </div>
      </div>
      <button type="button" class="icon-button" id="themeToggle" title="Đổi giao diện">${
        state.theme === 'dark' ? '☀️' : '🌙'
      }</button>
    </header>
  `;
}

function renderHome() {
  const items = getItemsForMode();
  const groups = groupByTopic(items);
  const modeLabel = state.contentMode === 'words' ? 'Từ / cụm ngắn' : 'Câu hoàn chỉnh';

  const topicsHtml =
    groups.length === 0
      ? `<p class="muted">${escapeHtml(state.loadError || 'Chưa có dữ liệu.')}</p>`
      : groups
          .map(([topic, list]) => {
            const prog = getTopicProgress(state.contentMode, topic, list.length);
            const pct = list.length ? Math.round((prog.masteredCount / list.length) * 100) : 0;
            return `
              <button type="button" class="button topic-card" data-topic="${escapeHtml(topic)}">
                <div class="row between">
                  <strong>${escapeHtml(topicLabel(topic))}</strong>
                  <span class="badge">${list.length} mục</span>
                </div>
                <p class="muted small">Đã thuộc: ${prog.masteredCount}/${list.length} · ${pct}%</p>
                <div class="progress-track"><div class="progress-fill" style="width:${pct}%"></div></div>
              </button>
            `;
          })
          .join('');

  return `
    ${renderHeader('English Dictation', 'Nghe — chép — luyện phát âm')}
    <div class="stack">
      <section class="panel stack">
        <h2>Chọn loại bài</h2>
        <div class="mode-toggle">
          <button type="button" class="button ${state.contentMode === 'words' ? 'active' : ''}" data-mode="words">Từ đơn</button>
          <button type="button" class="button ${state.contentMode === 'sentences' ? 'active' : ''}" data-mode="sentences">Câu</button>
        </div>
        <p class="muted small">Đang luyện: <strong>${modeLabel}</strong>. Tiến độ lưu trên trình duyệt.</p>
      </section>
      <section class="panel stack">
        <h2>Chủ đề</h2>
        <div class="topic-grid">${topicsHtml}</div>
      </section>
    </div>
  `;
}

function renderPractice() {
  const session = state.session;
  const item = session.queue[session.index];
  const total = session.queue.length;
  const num = session.index + 1;
  const isSentence = state.contentMode === 'sentences';
  const answered = session.answered;

  let body = '';
  if (answered) {
    const inputClass = answered.isCorrect ? 'search success-input' : 'search danger-input';
    body = `
      <p class="muted">${isSentence ? 'Nghe và chép câu:' : 'Nghe và chép từ:'}</p>
      <div class="play-row">
        <button type="button" class="button play-btn" id="playBtn">🔊 Nghe lại</button>
        <button type="button" class="button ghost small" id="slowBtn">🐢 Chậm</button>
      </div>
      <input class="${inputClass}${isSentence ? ' sentence-input' : ''}" type="text" value="${escapeHtml(answered.typed)}" disabled />
      ${
        answered.isCorrect
          ? '<p class="feedback" style="color: var(--success); font-weight: 600;">Chính xác!</p>'
          : `<p class="feedback">Đáp án đúng: <strong>${escapeHtml(item.answer)}</strong></p>
             <p class="small">So sánh: ${diffAnswer(answered.typed, item.answer)}</p>`
      }
      ${item.ipa ? `<p class="muted small">IPA: ${escapeHtml(item.ipa)}</p>` : ''}
      <p class="muted small">${escapeHtml(item.hint)}</p>
      <button type="button" class="button primary" id="nextBtn">${num >= total ? 'Xem kết quả' : 'Câu tiếp theo'}</button>
    `;
  } else {
    body = `
      <p class="muted">${isSentence ? 'Nghe và chép lại câu tiếng Anh:' : 'Nghe và chép lại từ tiếng Anh:'}</p>
      <div class="play-row">
        <button type="button" class="button primary play-btn" id="playBtn">🔊 Phát âm</button>
        <button type="button" class="button ghost small" id="slowBtn">🐢 Chậm</button>
      </div>
      <input class="search${isSentence ? ' sentence-input' : ''}" id="answerInput" type="text" autocomplete="off"
        placeholder="${isSentence ? 'Gõ cả câu...' : 'Gõ từ bạn nghe được...'}"
        value="${escapeHtml(session.draft)}" autofocus />
      <div class="row">
        <button type="button" class="button primary" id="submitBtn">Kiểm tra</button>
        <button type="button" class="button" id="hintBtn">Gợi ý (${session.hintCount})</button>
      </div>
      ${
        session.hintCount
          ? `<p class="muted small">Gợi ý: <code>${escapeHtml(getHint(item.answer, session.hintCount))}</code></p>`
          : ''
      }
      <p class="muted small">${escapeHtml(item.hint)}</p>
    `;
  }

  return `
    ${renderHeader(topicLabel(session.topic), `Câu ${num}/${total}`)}
    <section class="panel stack">
      <div class="progress-track"><div class="progress-fill" style="width:${Math.round((num / total) * 100)}%"></div></div>
      ${body}
      <button type="button" class="button ghost small" id="backHome">← Về trang chủ</button>
    </section>
  `;
}

function renderSummary() {
  const session = state.session;
  const correct = session.results.filter((r) => r.isCorrect).length;
  const total = session.results.length;
  const elapsed = Math.max(1, Math.round((Date.now() - session.startedAt) / 1000));

  const rows = session.results
    .map((r, i) => {
      const item = session.queue.find((q) => q.id === r.itemId);
      return `
        <div class="panel" style="padding: 0.85rem;">
          <div class="row between">
            <strong>#${i + 1}</strong>
            <span style="color: ${r.isCorrect ? 'var(--success)' : 'var(--danger)'}; font-weight: 700;">
              ${r.isCorrect ? 'Đúng' : 'Sai'}
            </span>
          </div>
          <p class="small">Bạn: ${escapeHtml(r.typed)}</p>
          ${r.isCorrect ? '' : `<p class="small">Đúng: ${escapeHtml(item?.answer || '')}</p>`}
        </div>
      `;
    })
    .join('');

  return `
    ${renderHeader('Kết quả', topicLabel(session.topic))}
    <div class="stack">
      <section class="panel stack">
        <div class="stats-grid">
          <div class="stat"><span class="muted small">Đúng</span><strong>${correct}/${total}</strong></div>
          <div class="stat"><span class="muted small">Thời gian</span><strong>${elapsed}s</strong></div>
        </div>
        <div class="row">
          <button type="button" class="button primary" id="retryWrong" ${correct === total ? 'disabled' : ''}>Luyện lại câu sai</button>
          <button type="button" class="button" id="retryAll">Làm lại chủ đề</button>
        </div>
        <button type="button" class="button ghost" id="backHome">← Chọn chủ đề khác</button>
      </section>
      <section class="stack">${rows}</section>
    </div>
  `;
}

function render() {
  const root = document.getElementById('root');
  if (!root) return;
  document.documentElement.classList.toggle('light', state.theme === 'light');

  if (state.page === 'practice') root.innerHTML = renderPractice();
  else if (state.page === 'summary') root.innerHTML = renderSummary();
  else root.innerHTML = renderHome();

  bindEvents();
}

function bindEvents() {
  document.getElementById('themeToggle')?.addEventListener('click', () => {
    setTheme(state.theme === 'dark' ? 'light' : 'dark');
  });

  document.querySelectorAll('[data-mode]').forEach((el) => {
    el.addEventListener('click', () => {
      state.contentMode = el.dataset.mode;
      state.page = 'home';
      render();
    });
  });

  document.querySelectorAll('[data-topic]').forEach((el) => {
    el.addEventListener('click', () => {
      startSession(el.dataset.topic);
    });
  });

  document.getElementById('backHome')?.addEventListener('click', () => {
    stopAudio();
    state.session = null;
    state.page = 'home';
    render();
  });

  const session = state.session;
  const item = session?.queue?.[session.index];

  document.getElementById('playBtn')?.addEventListener('click', () => {
    if (item) playItem(item);
  });
  document.getElementById('slowBtn')?.addEventListener('click', () => {
    if (item) playItem(item, 0.75);
  });

  document.getElementById('answerInput')?.addEventListener('input', (e) => {
    if (session) session.draft = e.target.value;
  });

  document.getElementById('submitBtn')?.addEventListener('click', submitAnswer);
  document.getElementById('answerInput')?.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') submitAnswer();
  });

  document.getElementById('hintBtn')?.addEventListener('click', () => {
    if (!session || session.answered || !item) return;
    session.hintCount = Math.min(session.hintCount + 1, item.answer.length);
    render();
    document.getElementById('answerInput')?.focus();
  });

  document.getElementById('nextBtn')?.addEventListener('click', nextQuestion);

  document.getElementById('retryAll')?.addEventListener('click', () => {
    if (session) startSession(session.topic);
  });

  document.getElementById('retryWrong')?.addEventListener('click', () => {
    if (session) startSession(session.topic, { onlyWrong: true, count: session.results.length });
  });
}

async function init() {
  loadSaved();
  document.documentElement.classList.toggle('light', state.theme === 'light');
  render();
  await loadData();
  if ('speechSynthesis' in window) {
    window.speechSynthesis.getVoices();
    window.speechSynthesis.onvoiceschanged = () => window.speechSynthesis.getVoices();
  }
  render();
}

init();
