import { normalizeTranscript } from './matcher.js';

/** @typedef {'en' | 'vi' | 'idle'} ImportDictationPhase */

/**
 * Voice input for Import panel: EN segment → VI segment → append to textarea.
 * Chrome / Edge Web Speech API.
 */
export function createImportDictation(options) {
  const {
    getSpeechRecognitionCtor,
    isMicOriginAllowed,
    requestMicrophonePermission,
    getTextarea,
    onFeedback,
    onListeningChange,
    elements: { wrap, statusEl, liveEl, btnToggle, btnNext },
  } = options;

  /** @type {ImportDictationPhase} */
  let phase = 'idle';
  let listening = false;
  let starting = false;
  let sessionGen = 0;
  let restartTimer = 0;
  /** @type {SpeechRecognition | null} */
  let recognition = null;
  let draftEn = '';
  let draftVi = '';
  let interim = '';

  function setPhase(next) {
    phase = next;
    refreshUi();
  }

  function currentLang() {
    return phase === 'vi' ? 'vi-VN' : 'en-US';
  }

  function mergedDraft() {
    const base = phase === 'vi' ? draftVi : draftEn;
    const tail = interim.trim();
    if (!tail) return base.trim();
    if (!base.trim()) return tail;
    return `${base.trim()} ${tail}`.trim();
  }

  function refreshUi() {
    if (statusEl) {
      if (!listening && phase === 'idle') {
        statusEl.textContent =
          'Bấm Bắt đầu nghe, đọc tiếng Anh (cả câu/đoạn). Xong đoạn Anh → đọc tiếng Việt → Lưu cặp câu.';
      } else if (listening && phase === 'en') {
        statusEl.textContent = 'Đang nghe tiếng Anh… (đọc tới dấu phẩy/chấm rồi bấm Xong đoạn Anh)';
      } else if (listening && phase === 'vi') {
        statusEl.textContent = 'Đang nghe tiếng Việt… (dịch đoạn vừa đọc, rồi bấm Lưu cặp câu)';
      } else if (phase === 'vi' && !listening) {
        statusEl.textContent = 'Bấm Bắt đầu nghe để đọc bản tiếng Việt.';
      } else if (phase === 'en' && !listening) {
        statusEl.textContent = 'Bấm Bắt đầu nghe để tiếp tục tiếng Anh.';
      }
    }

    if (liveEl) {
      const enShow = phase === 'en' ? mergedDraft() : draftEn;
      const viShow = phase === 'vi' ? mergedDraft() : draftVi;
      const parts = [];
      if (enShow) parts.push(`EN: ${enShow}`);
      if (viShow) parts.push(`VI: ${viShow}`);
      liveEl.textContent = parts.join('\n') || '—';
    }

    if (btnToggle) {
      btnToggle.textContent = listening ? 'Dừng nghe' : 'Bắt đầu nghe';
      btnToggle.setAttribute('aria-pressed', String(listening));
    }

    if (btnNext) {
      if (phase === 'en') {
        btnNext.textContent = 'Xong đoạn Anh → đọc Việt';
        btnNext.disabled = !draftEn.trim() && !interim.trim();
      } else if (phase === 'vi') {
        btnNext.textContent = 'Lưu cặp câu';
        btnNext.disabled = !draftEn.trim() || (!draftVi.trim() && !interim.trim());
      } else {
        btnNext.textContent = 'Xong đoạn Anh → đọc Việt';
        btnNext.disabled = true;
      }
    }
  }

  function clearRestartTimer() {
    if (!restartTimer) return;
    window.clearTimeout(restartTimer);
    restartTimer = 0;
  }

  function scheduleListeningRestart(delay = 180) {
    clearRestartTimer();
    if (phase === 'idle') return;
    restartTimer = window.setTimeout(() => {
      restartTimer = 0;
      if (phase === 'idle' || listening || starting) return;
      void startListening();
    }, delay);
  }

  function stopListening() {
    clearRestartTimer();
    sessionGen += 1;
    if (recognition) {
      try {
        recognition._wantRestart = false;
        recognition.stop();
      } catch {
        /* ignore */
      }
      recognition = null;
    }
    const tail = interim.trim();
    if (tail) {
      if (phase === 'vi') draftVi = mergedDraft();
      else if (phase === 'en') draftEn = mergedDraft();
    }
    interim = '';
    listening = false;
    starting = false;
    onListeningChange?.(false);
    refreshUi();
  }

  async function startListening() {
    const Ctor = getSpeechRecognitionCtor?.();
    if (!Ctor) {
      onFeedback?.('Trình duyệt không hỗ trợ nhận dạng giọng nói. Dùng Chrome hoặc Edge.', true);
      return;
    }

    if (isMicOriginAllowed && !isMicOriginAllowed()) {
      onFeedback?.(
        'Không mở trực tiếp file index.html. Chạy python -m http.server 8080 trong thư mục Reading rồi vào http://127.0.0.1:8080.',
        true,
      );
      return;
    }

    if (listening || starting) return;

    if (phase === 'idle') setPhase('en');

    starting = true;
    refreshUi();

    const ok = await requestMicrophonePermission?.();
    if (!ok) {
      starting = false;
      refreshUi();
      return;
    }

    const gen = ++sessionGen;
    const rec = new Ctor();
    recognition = rec;
    rec.lang = currentLang();
    rec.continuous = true;
    rec.interimResults = true;
    rec.maxAlternatives = 1;

    rec.onstart = () => {
      if (gen !== sessionGen) return;
      starting = false;
      listening = true;
      onListeningChange?.(true);
      refreshUi();
    };

    rec.onend = () => {
      if (gen !== sessionGen) return;
      const shouldRestart = Boolean(rec._wantRestart) && phase !== 'idle';
      listening = false;
      starting = false;
      recognition = null;
      onListeningChange?.(false);
      refreshUi();
      if (shouldRestart) scheduleListeningRestart();
    };

    rec.onerror = (event) => {
      if (gen !== sessionGen) return;
      if (event.error === 'not-allowed') {
        onFeedback?.('Microphone bị chặn. Cho phép mic trên thanh địa chỉ.', true);
      } else if (event.error !== 'aborted' && event.error !== 'no-speech') {
        onFeedback?.(`Lỗi nhận dạng: ${event.error}`, true);
      }
      stopListening();
    };

    rec.onresult = (event) => {
      if (gen !== sessionGen) return;
      let nextInterim = '';
      for (let i = event.resultIndex; i < event.results.length; i++) {
        const result = event.results[i];
        const text = result[0]?.transcript?.trim() ?? '';
        if (!text) continue;
        if (result.isFinal) {
          const piece = phase === 'en' ? normalizeTranscript(text) : text;
          if (phase === 'vi') draftVi = draftVi ? `${draftVi} ${piece}` : piece;
          else draftEn = draftEn ? `${draftEn} ${piece}` : piece;
          nextInterim = '';
        } else {
          nextInterim += (nextInterim ? ' ' : '') + text;
        }
      }
      interim = nextInterim;
      refreshUi();
    };

    rec._wantRestart = true;

    try {
      rec.start();
    } catch {
      starting = false;
      recognition = null;
      onFeedback?.('Không bật được microphone. Thử bấm lại.', true);
      refreshUi();
    }
  }

  function toggleListening() {
    if (listening || starting) stopListening();
    else void startListening();
  }

  function appendPair(enLine, viLine) {
    const ta = getTextarea?.();
    if (!ta) return;
    const en = enLine.trim();
    const vi = viLine.trim();
    if (!en) return;
    let block = en;
    if (vi) block += `\n${vi}`;
    const cur = ta.value;
    ta.value = cur ? `${cur.replace(/\n?$/, '')}\n${block}\n` : `${block}\n`;
    ta.dispatchEvent(new Event('input', { bubbles: true }));
  }

  function finishEnSegment() {
    stopListening();
    const en = (phase === 'en' ? mergedDraft() : draftEn).trim();
    if (!en) {
      onFeedback?.('Chưa có tiếng Anh. Đọc đoạn Anh trước.', true);
      refreshUi();
      return;
    }
    draftEn = en;
    draftVi = '';
    interim = '';
    setPhase('vi');
    onFeedback?.('Đọc bản tiếng Việt cho đoạn vừa rồi.', false);
  }

  function savePair() {
    stopListening();
    const en = draftEn.trim();
    const vi = (phase === 'vi' ? mergedDraft() : draftVi).trim();
    if (!en) {
      onFeedback?.('Thiếu câu tiếng Anh.', true);
      return;
    }
    if (!vi) {
      onFeedback?.('Thiếu bản tiếng Việt. Đọc hoặc gõ dịch trước khi lưu cặp.', true);
      return;
    }
    appendPair(en, vi);
    draftEn = '';
    draftVi = '';
    interim = '';
    setPhase('en');
    onFeedback?.('Đã thêm cặp câu vào ô nội dung. Tiếp tục đọc đoạn Anh tiếp theo.', false);
  }

  function handleNext() {
    if (phase === 'en') finishEnSegment();
    else if (phase === 'vi') savePair();
  }

  function setVisible(textMode) {
    wrap?.classList.toggle('hidden', !textMode);
    if (!textMode) shutdown();
    refreshUi();
  }

  function shutdown() {
    stopListening();
    draftEn = '';
    draftVi = '';
    interim = '';
    setPhase('idle');
  }

  btnToggle?.addEventListener('click', () => toggleListening());
  btnNext?.addEventListener('click', () => handleNext());

  return {
    setVisible,
    shutdown,
    stopListening,
    isListening: () => listening || starting,
  };
}
