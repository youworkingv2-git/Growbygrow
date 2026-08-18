/**
 * Phonics Quest v3 — skill tree + Sorting / Word Builder / Boss / Mic / Dictionary
 */
const STORAGE_KEY = "phonics-quest-v3";

const state = {
  tab: "home",
  screen: "home",
  worldId: null,
  stageId: null,
  play: null
};

function defaultProgress() {
  return {
    xp: 0,
    accent: "uk",
    onboarded: false,
    modes: {},
    theory: {},
    stars: {},
    captured: {},
    spoken: {},
    irregulars: {},
    badges: []
  };
}

function loadProgress() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY) || localStorage.getItem("phonics-quest-v2") || "{}";
    return { ...defaultProgress(), ...JSON.parse(raw) };
  } catch {
    return defaultProgress();
  }
}

let progress = loadProgress();
progress.modes = progress.modes || {};
progress.theory = progress.theory || {};
progress.captured = progress.captured || {};
progress.spoken = progress.spoken || {};
progress.irregulars = progress.irregulars || {};
progress.badges = progress.badges || [];

function saveProgress() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
}

function $(id) {
  return document.getElementById(id);
}

function worldById(id) {
  return ALL_WORLDS.find((w) => w.id === id);
}

function stageById(world, id) {
  return world.stages.find((s) => s.id === id);
}

function locateStage(stageId) {
  for (const world of ALL_WORLDS) {
    const index = world.stages.findIndex((s) => s.id === stageId);
    if (index >= 0) return { world, stage: world.stages[index], index };
  }
  return null;
}

function worldIndex(id) {
  return ALL_WORLDS.findIndex((w) => w.id === id);
}

function availableModes(stage) {
  const list = ["sort", "build"];
  if (stage.boss) list.push("boss");
  return list;
}

function modeDone(stageId, mode) {
  return !!progress.modes[`${stageId}:${mode}`];
}

function modeCount(stageId) {
  const loc = locateStage(stageId);
  if (!loc) return 0;
  return availableModes(loc.stage).filter((m) => modeDone(stageId, m)).length;
}

function starsOf(stageId) {
  const loc = locateStage(stageId);
  if (!loc) return progress.stars[stageId] || 0;
  const av = availableModes(loc.stage);
  const n = av.filter((m) => modeDone(stageId, m)).length;
  if (av.length === 2 && n === 2) return 3;
  return n;
}

function isMastered(stageId) {
  const loc = locateStage(stageId);
  if (!loc) return false;
  return availableModes(loc.stage).every((m) => modeDone(stageId, m));
}

function worldStars(world) {
  const got = world.stages.reduce((a, s) => a + starsOf(s.id), 0);
  const max = world.stages.length * 3;
  return { got, max };
}

function worldCompleted(world) {
  return world.stages.every((s) => starsOf(s.id) >= 1);
}

function isWorldUnlocked(world) {
  const i = worldIndex(world.id);
  if (i <= 0) return true;
  if (world.id === "boss") return WORLDS.every(worldCompleted);
  return worldCompleted(ALL_WORLDS[i - 1]);
}

function isStageUnlocked(world, index) {
  if (!isWorldUnlocked(world)) return false;
  if (index === 0) return true;
  return starsOf(world.stages[index - 1].id) >= 1;
}

function nextPlayable() {
  for (const world of ALL_WORLDS) {
    if (!isWorldUnlocked(world)) continue;
    for (let i = 0; i < world.stages.length; i++) {
      const s = world.stages[i];
      if (!isStageUnlocked(world, i)) continue;
      if (!isMastered(s.id)) return { world, stage: s };
    }
  }
  return { world: ALL_WORLDS[0], stage: ALL_WORLDS[0].stages[0] };
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function shuffle(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function speak(text) {
  if (!text || !window.speechSynthesis) return;
  window.speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(String(text));
  u.lang = progress.accent === "us" ? "en-US" : "en-GB";
  u.rate = 0.9;
  const voices = window.speechSynthesis.getVoices();
  const prefer = voices.find((v) => v.lang && v.lang.startsWith(u.lang));
  if (prefer) u.voice = prefer;
  window.speechSynthesis.speak(u);
}

function buzz(ok) {
  if (navigator.vibrate) navigator.vibrate(ok ? 12 : [18, 40, 18]);
}

function stopPlay() {
  const p = state.play;
  if (!p) return;
  if (p.raf) cancelAnimationFrame(p.raf);
  if (p.timer) clearInterval(p.timer);
  if (p.rec) {
    try {
      p.rec.stop();
    } catch (_) {}
  }
  state.play = null;
}

function setChrome() {
  const treeOn = state.screen === "map";
  const playOn = ["sort", "build", "boss", "mic", "theory", "result"].includes(state.screen);
  $("tree-screen").classList.toggle("hidden", !treeOn);
  $("view").classList.toggle("hidden", treeOn);
  $("btn-back").hidden = ["home", "map", "dict", "me"].includes(state.screen);
  $("tabbar").classList.toggle("hidden", playOn);
  $("xp-chip").textContent = `⭐ ${progress.xp}`;
  document.querySelectorAll(".tab").forEach((t) => t.classList.toggle("active", t.dataset.tab === state.tab));
  if (treeOn) {
    $("top-title").textContent = "Cây kỹ năng";
    $("top-sub").textContent = "IPA → gốc chữ → lá từ";
    document.documentElement.style.setProperty("--world", "#6366f1");
    return;
  }
  if (state.stageId) {
    const loc = locateStage(state.stageId);
    if (loc) {
      document.documentElement.style.setProperty("--world", loc.world.color);
      $("top-title").textContent = loc.stage.title;
      $("top-sub").textContent = `${loc.world.emoji} ${loc.world.titleVi}`;
      return;
    }
  }
  document.documentElement.style.setProperty("--world", "#6366f1");
  const titles = {
    home: ["Phonics Quest", "Skill tree học tiếng Anh"],
    dict: ["Sổ tay âm thanh", "Từ đã thu phục"],
    me: ["Hồ sơ", "Tiến độ & giọng"]
  };
  const t = titles[state.screen] || titles.home;
  $("top-title").textContent = t[0];
  $("top-sub").textContent = t[1];
}

function render() {
  setChrome();
  if (state.screen === "map") {
    if (skillMap) skillMap.refresh();
    return;
  }
  const map = {
    home: renderHome,
    dict: renderDict,
    me: renderMe,
    theory: renderTheory,
    sort: renderSort,
    build: renderBuild,
    boss: renderBoss,
    mic: renderMic,
    result: renderResult
  };
  $("view").innerHTML = (map[state.screen] || renderHome)();
  if (state.screen === "sort") bootSort();
  if (state.screen === "build") bootBuild();
  if (state.screen === "boss") bootBoss();
}

function renderHome() {
  const next = nextPlayable();
  const doneWorlds = WORLDS.filter(worldCompleted).length;
  if (!progress.onboarded) {
    return `
      <section class="hero">
        <p>🌳 Skill Tree</p>
        <h1>Bản đồ trí tuệ động</h1>
        <p>Mỗi âm IPA là một trạm. Gốc chữ xòe ra. Lá từ vựng nở khi bạn thu phục.</p>
      </section>
      <div class="onboard" style="margin-top:16px">
        <div class="onboard-card"><h3>🧺 Sorting Quest</h3><p class="muted">Kéo bong bóng từ vào đúng hộp âm. Combo khi kéo nhanh.</p></div>
        <div class="onboard-card"><h3>🌿 Word Builder</h3><p class="muted">Nghe từ → chọn nhánh ghép chữ (ai / ay / a_e) để hoàn lá cây.</p></div>
        <div class="onboard-card"><h3>👹 Exception Slayer</h3><p class="muted">Trùm tung quy tắc giả. Chọn chiêu ngoại lệ trước khi hết giờ.</p></div>
      </div>
      <button class="primary" data-action="start">Vào bản đồ cây</button>
    `;
  }
  return `
    <section class="hero">
      <p>${next.world.emoji} World ${next.world.number}</p>
      <h1>${escapeHtml(next.stage.targetIpa)}</h1>
      <p>${escapeHtml(next.stage.title)} · ${escapeHtml(next.stage.subtitle)}</p>
      <button class="cta" data-action="continue">Tiếp tục trạm này</button>
      <button class="cta ghost" data-action="tab" data-tab="map">Mở cây kỹ năng</button>
    </section>
    <p class="section-title">Vòng lặp</p>
    <div class="card">
      <p class="rule">Học lý thuyết → Sorting & Builder → Boss → Huy hiệu + lá cây</p>
      <p class="muted">Xám = khóa · Sáng = mở · Vàng 3 sao = thành thục.</p>
    </div>
    <div class="stat-grid" style="margin-top:12px">
      <div class="stat"><b>${doneWorlds}/10</b><span class="muted">Thế giới</span></div>
      <div class="stat"><b>${Object.keys(progress.captured).length}</b><span class="muted">Lá thu phục</span></div>
    </div>
  `;
}

function openSheet(node) {
  const sheet = $("node-sheet");
  if (node.type === "leaf") {
    const owned = progress.captured[node.word];
    sheet.classList.remove("hidden");
    sheet.innerHTML = `
      <div class="sheet-handle"></div>
      <div class="sheet-head">
        <strong>${escapeHtml(node.word)}</strong>
        <span class="ph">/${escapeHtml(node.ipa || "")}/</span>
      </div>
      <p class="muted">${escapeHtml(node.meaning || "Lá từ vựng")}${owned ? " · Đã thu phục" : ""}</p>
      <div class="sheet-actions">
        <button class="secondary" data-action="speak" data-text="${escapeHtml(node.word)}">🔊 Đọc từ</button>
        <button class="primary" data-action="close-sheet">Đóng</button>
      </div>
    `;
    return;
  }
  const loc = locateStage(node.id);
  if (!loc) return;
  const { world, stage, index } = loc;
  const unlocked = isStageUnlocked(world, index);
  const st = !unlocked ? "locked" : isMastered(stage.id) ? "mastered" : "unlocked";
  state.worldId = world.id;
  state.stageId = stage.id;
  const theoryOn = !!progress.theory[stage.id];
  const gamesOn = unlocked && theoryOn;
  sheet.classList.remove("hidden");
  sheet.innerHTML = `
    <div class="sheet-handle"></div>
    <div class="sheet-head">
      <span class="orb-mini" style="background:${world.color}">${st === "locked" ? "🔒" : "🔊"}</span>
      <div>
        <strong>${escapeHtml(stage.targetIpa)}</strong>
        <p class="muted">${escapeHtml(stage.title)} · ${"★".repeat(starsOf(stage.id))}${"☆".repeat(Math.max(0, 3 - starsOf(stage.id)))}</p>
      </div>
    </div>
    ${
      !unlocked
        ? `<p class="muted">Hoàn thành trạm trước để mở khóa.</p>`
        : `<p class="muted">Chạm trạm: nghe âm. Gốc chữ: nghe quy tắc. Lá: nghe từ.</p>
        <div class="mode-grid">
          <button class="mode-card" data-action="open-theory" data-stage="${stage.id}">📘<span>Lý thuyết</span></button>
          <button class="mode-card" data-action="open-sort" data-stage="${stage.id}" ${gamesOn ? "" : "disabled"}>🧺<span>Sorting Quest</span></button>
          <button class="mode-card" data-action="open-build" data-stage="${stage.id}" ${gamesOn ? "" : "disabled"}>🌿<span>Word Builder</span></button>
          <button class="mode-card" data-action="open-boss" data-stage="${stage.id}" ${gamesOn && stage.boss ? "" : "disabled"}>👹<span>Boss Slayer</span></button>
          <button class="mode-card" data-action="open-mic" data-stage="${stage.id}" ${gamesOn ? "" : "disabled"}>🎤<span>Luyện mic</span></button>
        </div>
        ${!theoryOn ? `<p class="muted">Học lý thuyết trước để mở Sorting & Builder.</p>` : ""}`
    }
    <button class="secondary" data-action="close-sheet">Đóng</button>
  `;
}

function renderTheory() {
  const loc = locateStage(state.stageId);
  const s = loc.stage;
  const branches = (s.variation?.branches || [])
    .map(
      (b) => `<div class="tree-leaf"><strong>${escapeHtml(b.label)}</strong><span>${escapeHtml(b.ipa)}</span></div>`
    )
    .join("");
  const ex = (s.core.examples || [])
    .map(
      (e) => `<div class="ex"><div><b>${escapeHtml(e.word)}</b><div class="ph">/${escapeHtml(e.ipa)}/</div><small>${escapeHtml(e.meaning || "")}</small></div>
      <button class="speak-mini" data-action="speak" data-text="${escapeHtml(e.word)}">🔊</button></div>`
    )
    .join("");
  return `
    <div class="chips"><span class="chip">📘 Mở node âm</span></div>
    <div class="ipa-hero">
      <div class="ipa">${escapeHtml(s.targetIpa)}</div>
      <div class="spell">${escapeHtml(s.spelling)}</div>
      <button class="speak-mini" data-action="speak" data-text="${escapeHtml(ipaCue(s.targetIpa))}">🔊 Âm IPA</button>
    </div>
    <p class="rule">${escapeHtml(s.core.rule)}</p>
    <p class="guide">${escapeHtml(s.core.guide)}</p>
    ${s.map ? `<div class="tree"><div class="tree-root">${escapeHtml(s.map.ipa)}</div><div class="tree-branches">${(s.map.spellings || []).map((sp) => `<div class="tree-leaf"><strong>${escapeHtml(sp.grapheme)}</strong><span>${escapeHtml((sp.examples || []).join(" · "))}</span></div>`).join("")}</div></div>` : ""}
    ${branches ? `<div class="tree-branches" style="margin-top:8px">${branches}</div>` : ""}
    <div class="examples">${ex}</div>
    <button class="primary" data-action="finish-theory">Thu hoạch lý thuyết · mở màn chơi</button>
  `;
}

function neighborStage(stage) {
  const loc = locateStage(stage.id);
  const list = loc.world.stages;
  const n = list[loc.index + 1] || list[loc.index - 1];
  if (n && n.id !== stage.id && n.targetIpa !== stage.targetIpa) return n;
  for (const w of ALL_WORLDS) {
    const s = w.stages.find((x) => x.targetIpa !== stage.targetIpa);
    if (s) return s;
  }
  return stage;
}

function stageLeaves(stage) {
  const node = skillMap.nodeMap.get(stage.id);
  const out = [];
  (node?.children || []).forEach((g) => {
    (g.children || []).forEach((leaf) => out.push({ ...leaf, targetIpa: stage.targetIpa, grapheme: g.label }));
  });
  if (!out.length) {
    (stage.core.examples || []).forEach((e) => {
      if (e.word && e.word.length > 1) out.push({ word: e.word, ipa: e.ipa, meaning: e.meaning, targetIpa: stage.targetIpa, grapheme: stage.spelling.split(" / ")[0] });
    });
  }
  return out;
}

function captureWord(leaf, stage) {
  if (!leaf?.word || leaf.word.length < 2) return;
  progress.captured[leaf.word] = {
    word: leaf.word,
    ipa: leaf.ipa || stage.targetIpa,
    meaning: leaf.meaning || "",
    stageId: stage.id,
    grapheme: leaf.grapheme || stage.spelling
  };
}

function completeMode(mode, extraXp) {
  const loc = locateStage(state.stageId);
  progress.modes[`${loc.stage.id}:${mode}`] = true;
  progress.xp += extraXp;
  progress.stars[loc.stage.id] = starsOf(loc.stage.id);
  if (isMastered(loc.stage.id) && !progress.badges.includes(loc.stage.id)) {
    progress.badges.push(loc.stage.id);
  }
  saveProgress();
  state.play = {
    result: {
      passed: true,
      title: mode === "boss" ? "Trùm ngã!" : "Mảnh ghép đã gắn",
      text: isMastered(loc.stage.id) ? "Huy hiệu thành thục · 3 sao" : `+${extraXp} XP · tiếp tục cửa còn lại`
    }
  };
  state.screen = "result";
  render();
}

function failMode(text) {
  state.play = { result: { passed: false, title: "Chưa thông màn", text } };
  state.screen = "result";
  render();
}

function renderSort() {
  return `
    <div class="sort-hud">
      <span id="sort-combo">Combo x0</span>
      <span id="sort-score">0</span>
      <span id="sort-left">8 từ</span>
    </div>
    <p class="prompt" id="sort-prompt">Nghe từ · kéo vào đúng hộp âm</p>
    <div class="sort-sky" id="sort-sky"></div>
    <div class="sort-baskets" id="sort-baskets"></div>
  `;
}

function bootSort() {
  const loc = locateStage(state.stageId);
  const stage = loc.stage;
  const other = neighborStage(stage);
  const goods = stageLeaves(stage).map((w) => ({ ...w, targetIpa: stage.targetIpa }));
  const bads = stageLeaves(other).map((w) => ({ ...w, targetIpa: other.targetIpa }));
  const pool = shuffle([...goods.slice(0, 5), ...bads.slice(0, 4)]).slice(0, 8);
  const baskets = shuffle([
    { ipa: stage.targetIpa, color: loc.world.color },
    { ipa: other.targetIpa, color: locateStage(other.id).world.color }
  ]).slice(0, 2);
  $("sort-baskets").innerHTML = baskets
    .map((b) => `<div class="basket" data-ipa="${escapeHtml(b.ipa)}" style="--c:${b.color}"><b>${escapeHtml(b.ipa)}</b><small>Hộp âm</small></div>`)
    .join("");
  const play = {
    type: "sort",
    pool,
    next: 0,
    live: [],
    score: 0,
    combo: 0,
    lastHit: 0,
    resolved: 0,
    need: pool.length,
    dragging: null,
    lastT: performance.now()
  };
  state.play = play;
  const sky = $("sort-sky");

  function spawn() {
    if (play.next >= play.pool.length) return;
    const item = play.pool[play.next++];
    const el = document.createElement("button");
    el.className = "bubble";
    el.textContent = item.word;
    const x = 12 + Math.random() * 62;
    el.style.left = `${x}%`;
    el.style.top = "-48px";
    sky.appendChild(el);
    const ball = { item, el, x, y: -48, vy: 42 + Math.random() * 18 };
    play.live.push(ball);
    el.addEventListener("pointerdown", (e) => {
      e.preventDefault();
      play.dragging = ball;
      el.classList.add("held");
      el.setPointerCapture(e.pointerId);
      speak(item.word);
    });
    el.addEventListener("pointermove", (e) => {
      if (play.dragging !== ball) return;
      const rec = sky.getBoundingClientRect();
      ball.y = e.clientY - rec.top - 28;
      ball.x = ((e.clientX - rec.left) / rec.width) * 100;
      el.style.top = `${ball.y}px`;
      el.style.left = `${ball.x}%`;
    });
    el.addEventListener("pointerup", (e) => {
      if (play.dragging !== ball) return;
      play.dragging = null;
      el.classList.remove("held");
      dropOnBaskets(ball, e);
    });
  }

  function dropOnBaskets(ball, e) {
    const hit = [...document.querySelectorAll(".basket")].find((b) => {
      const r = b.getBoundingClientRect();
      return e.clientX >= r.left && e.clientX <= r.right && e.clientY >= r.top && e.clientY <= r.bottom;
    });
    if (!hit) return;
    const ok = hit.dataset.ipa === ball.item.targetIpa;
    resolveBall(ball, ok);
  }

  function resolveBall(ball, ok) {
    if (ball.done) return;
    ball.done = true;
    play.resolved += 1;
    if (ok) {
      const now = performance.now();
      play.combo = now - play.lastHit < 1600 ? play.combo + 1 : 1;
      play.lastHit = now;
      play.score += 10 * play.combo;
      captureWord(ball.item, stage);
      buzz(true);
    } else {
      play.combo = 0;
      buzz(false);
    }
    ball.el.classList.add(ok ? "ok" : "no");
    setTimeout(() => ball.el.remove(), 280);
    play.live = play.live.filter((b) => b !== ball);
    $("sort-combo").textContent = `Combo x${play.combo}`;
    $("sort-score").textContent = String(play.score);
    $("sort-left").textContent = `${play.need - play.resolved} từ`;
    if (play.resolved >= play.need) finishSort();
  }

  function finishSort() {
    if (play.ended) return;
    play.ended = true;
    const score = play.score;
    const need = play.need;
    stopPlay();
    const passed = score >= need * 6;
    if (passed) {
      saveProgress();
      completeMode("sort", 20 + score);
    } else failMode("Cần kéo đúng nhiều hơn để gắn mảnh cây. Thử lại!");
  }

  function tick(t) {
    if (play.ended) return;
    const dt = Math.min(0.05, (t - play.lastT) / 1000);
    play.lastT = t;
    const h = sky.clientHeight;
    play.live.forEach((b) => {
      if (play.dragging === b) return;
      b.y += b.vy * dt;
      b.el.style.top = `${b.y}px`;
      if (b.y > h - 10) resolveBall(b, false);
    });
    play.raf = requestAnimationFrame(tick);
  }

  spawn();
  play.timer = setInterval(spawn, 1500);
  play.raf = requestAnimationFrame(tick);
}

function renderBuild() {
  return `<div id="build-root"></div>`;
}

function bootBuild() {
  const loc = locateStage(state.stageId);
  const stage = loc.stage;
  const node = skillMap.nodeMap.get(stage.id);
  const graphemes = (node?.children || []).map((g) => g.label);
  const words = stageLeaves(stage).filter((w) => w.word && w.word.length > 2);
  const rounds = shuffle(words).slice(0, 5);
  const extra = ["ai", "ay", "ee", "oa", "ow"].filter((g) => !graphemes.includes(g));
  const play = { type: "build", rounds, i: 0, correct: 0, graphemes: graphemes.length ? graphemes : [stage.spelling.split(" / ")[0]], extra };
  state.play = play;
  drawBuildRound();
}

function drawBuildRound() {
  const play = state.play;
  const loc = locateStage(state.stageId);
  const q = play.rounds[play.i];
  if (!q) {
    if (play.correct >= Math.ceil(play.rounds.length * 0.6)) {
      play.rounds.forEach((w) => captureWord(w, loc.stage));
      saveProgress();
      completeMode("build", 24 + play.correct * 8);
    } else failMode("Cần ghép đúng hơn 60% để hoàn lá cây.");
    return;
  }
  const parts = splitByGrapheme(q.word, q.grapheme);
  const choices = shuffle([...play.graphemes, ...play.extra].filter((v, i, a) => a.indexOf(v) === i)).slice(0, 3);
  if (!choices.includes(q.grapheme)) choices[0] = q.grapheme;
  speak(q.word);
  $("build-root").innerHTML = `
    <p class="muted" style="text-align:center">Câu ${play.i + 1}/${play.rounds.length}</p>
    <div class="mini-tree">
      <div class="tree-root">${escapeHtml(loc.stage.targetIpa)}</div>
      <div class="tree-branches">${play.graphemes.map((g) => `<div class="tree-leaf"><strong>${escapeHtml(g)}</strong></div>`).join("")}</div>
    </div>
    <p class="prompt">Nghe từ · chọn gốc chữ để hoàn lá</p>
    <div style="text-align:center"><button class="speak-mini" data-action="speak" data-text="${escapeHtml(q.word)}">🔊</button></div>
    <div class="builder-word">
      <span>${escapeHtml(parts.prefix)}</span>
      <span class="blank">?</span>
      <span>${escapeHtml(parts.suffix)}</span>
    </div>
    <div class="tiles" id="build-choices">
      ${shuffle(choices)
        .map((g) => `<button class="tile" data-action="build-pick" data-g="${escapeHtml(g)}">${escapeHtml(g)}</button>`)
        .join("")}
    </div>
  `;
}

function pickBuild(g) {
  const play = state.play;
  const q = play.rounds[play.i];
  const ok = g === q.grapheme;
  buzz(ok);
  if (ok) play.correct += 1;
  const blank = document.querySelector(".blank");
  if (blank) {
    blank.textContent = q.grapheme;
    blank.classList.add(ok ? "ok" : "no");
  }
  setTimeout(() => {
    play.i += 1;
    drawBuildRound();
  }, 650);
}

function bossRoster(stage) {
  if (stage.boss?.items?.length) return stage.boss.items.slice(0, 5);
  if (stage.boss?.kind === "multi-sound") {
    const main = stage.boss.sounds[0];
    return stage.boss.sounds.slice(1).map((s) => ({
      word: s.example,
      expectedIpa: main.ipa,
      actualIpa: s.ipa,
      meaning: s.meaning,
      note: `${stage.boss.spelling} còn đọc ${s.ipa}`
    }));
  }
  return [];
}

function renderBoss() {
  return `<div id="boss-root"></div>`;
}

function bootBoss() {
  const loc = locateStage(state.stageId);
  const roster = bossRoster(loc.stage);
  if (!roster.length) {
    $("boss-root").innerHTML = `<div class="card"><p class="rule">Âm này trung thành với quy tắc — không có trùm.</p></div>`;
    setTimeout(() => completeMode("boss", 30), 450);
    return;
  }
  state.play = { type: "boss", roster, i: 0, hp: roster.length, hearts: 3, timer: null, left: 8 };
  drawBossRound();
}

function drawBossRound() {
  const play = state.play;
  const item = play.roster[play.i];
  if (!item || play.hearts <= 0) {
    if (play.timer) clearInterval(play.timer);
    if (play.hp <= 0) {
      play.roster.forEach((it) => {
        progress.irregulars[it.word] = it;
      });
      saveProgress();
      completeMode("boss", 40);
    } else failMode("Trùm còn đứng. Chọn chiêu ngoại lệ nhanh hơn!");
    return;
  }
  play.left = 8;
  const opts = shuffle([item.actualIpa, item.expectedIpa, "/æ/", "/iː/"].filter((v, i, a) => a.indexOf(v) === i)).slice(0, 3);
  speak(item.word);
  $("boss-root").innerHTML = `
    <div class="boss-arena">
      <div class="boss-monster">👹</div>
      <h2 class="boss-name">${escapeHtml(item.word.toUpperCase())}</h2>
      <p class="muted">${escapeHtml(item.meaning || "")}</p>
      <div class="hp-row">${"🖤".repeat(play.hp)}${"🤍".repeat(Math.max(0, play.roster.length - play.hp))}</div>
      <div class="hearts">Bạn ${"❤️".repeat(play.hearts)}</div>
      <div class="fake-atk">Chiêu giả: <s>${escapeHtml(item.expectedIpa)}</s></div>
      <div class="countdown" id="boss-count">${play.left}</div>
      <p class="prompt">Chọn chiêu ngoại lệ đúng</p>
      <div class="tiles">
        ${opts.map((o) => `<button class="tile" data-action="boss-pick" data-ipa="${escapeHtml(o)}">${escapeHtml(o)}</button>`).join("")}
      </div>
    </div>
  `;
  if (play.timer) clearInterval(play.timer);
  play.timer = setInterval(() => {
    play.left -= 1;
    const el = $("boss-count");
    if (el) el.textContent = String(play.left);
    if (play.left <= 0) {
      clearInterval(play.timer);
      play.hearts -= 1;
      play.i += 1;
      buzz(false);
      drawBossRound();
    }
  }, 1000);
}

function pickBoss(ipa) {
  const play = state.play;
  const item = play.roster[play.i];
  if (play.timer) clearInterval(play.timer);
  const ok = ipa === item.actualIpa;
  if (ok) {
    play.hp -= 1;
    play.i += 1;
    buzz(true);
  } else {
    play.hearts -= 1;
    play.i += 1;
    buzz(false);
  }
  drawBossRound();
}

function renderMic() {
  const Rec = window.SpeechRecognition || window.webkitSpeechRecognition;
  return `
    <div class="card">
      <p class="rule">Đọc lá từ vào mic. Nếu khớp, lá được thu phục trên cây.</p>
      <p class="muted">${Rec ? "Chạm mic, đọc rõ một lần." : "Trình duyệt này chưa hỗ trợ nhận giọng. Dùng Chrome trên Android, hoặc luyện bằng Sorting / Builder."}</p>
    </div>
    <div class="ipa-hero">
      <div class="spell" id="mic-word">—</div>
      <p class="ph" id="mic-ipa"></p>
      <button class="speak-mini" id="mic-hear" data-action="mic-hear">🔊</button>
    </div>
    <button class="primary" data-action="mic-listen" ${Rec ? "" : "disabled"}>🎤 Đọc ngay</button>
    <p class="muted" id="mic-status" style="text-align:center;margin-top:10px"></p>
    <button class="secondary" data-action="mic-skip">Từ khác</button>
  `;
}

function nextMicWord() {
  const loc = locateStage(state.stageId);
  const leaves = stageLeaves(loc.stage);
  const pick = shuffle(leaves)[0];
  if (!state.play || state.play.type !== "mic") state.play = { type: "mic" };
  state.play.leaf = pick;
  const w = $("mic-word");
  if (w) {
    w.textContent = pick.word;
    $("mic-ipa").textContent = `/${pick.ipa || loc.stage.targetIpa.replace(/\//g, "")}/`;
  }
}

function startMic() {
  const Rec = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!Rec || !state.play?.leaf) return;
  const rec = new Rec();
  rec.lang = progress.accent === "us" ? "en-US" : "en-GB";
  rec.interimResults = false;
  rec.maxAlternatives = 3;
  $("mic-status").textContent = "Đang nghe…";
  rec.onresult = (ev) => {
    const said = [...ev.results[0]].map((r) => r.transcript.toLowerCase()).join(" ");
    const target = state.play.leaf.word.toLowerCase();
    const ok = said.replace(/[^a-z]/g, "").includes(target.replace(/[^a-z]/g, ""));
    $("mic-status").textContent = ok ? `Chuẩn! “${state.play.leaf.word}” đã vào sổ tay.` : `Nghe được: “${said}”. Thử lại.`;
    if (ok) {
      const loc = locateStage(state.stageId);
      progress.spoken[state.play.leaf.word] = true;
      captureWord(state.play.leaf, loc.stage);
      progress.xp += 8;
      saveProgress();
      buzz(true);
      if (skillMap) skillMap.refresh();
    } else buzz(false);
  };
  rec.onerror = () => {
    $("mic-status").textContent = "Không nghe được. Kiểm tra quyền mic.";
  };
  rec.start();
  state.play.rec = rec;
}

function renderDict() {
  const words = Object.values(progress.captured);
  const irr = Object.values(progress.irregulars);
  const wordCards = words.length
    ? words
        .map(
          (w) => `<button class="dict-card" data-action="speak" data-text="${escapeHtml(w.word)}">
            <b>${escapeHtml(w.word)}</b>
            <span class="ph">${escapeHtml(w.ipa)}</span>
            <small>${escapeHtml(w.meaning || w.grapheme || "")}</small>
          </button>`
        )
        .join("")
    : `<p class="muted">Chưa thu phục lá nào. Chơi Sorting / Builder hoặc đọc mic.</p>`;
  const irrCards = irr.length
    ? irr
        .map(
          (w) => `<div class="dict-card glass">
            <b>👹 ${escapeHtml(w.word)}</b>
            <span class="expect">${escapeHtml(w.expectedIpa)}</span>
            <span class="ph">${escapeHtml(w.actualIpa)}</span>
            <small>${escapeHtml(w.note || w.meaning || "")}</small>
          </div>`
        )
        .join("")
    : `<p class="muted">Tủ kính trống. Hạ Exception Slayer để nhốt từ bất quy tắc.</p>`;
  return `
    <p class="section-title">Từ điển hình ảnh · ${words.length} lá</p>
    <div class="dict-grid">${wordCards}</div>
    <p class="section-title">Tủ kính ngoại lệ</p>
    <div class="dict-grid">${irrCards}</div>
  `;
}

function renderMe() {
  const worldsDone = WORLDS.filter(worldCompleted).length;
  const starSum = ALL_WORLDS.reduce((a, w) => a + worldStars(w).got, 0);
  return `
    <div class="stat-grid">
      <div class="stat"><b>${progress.xp}</b><span class="muted">XP</span></div>
      <div class="stat"><b>${starSum}</b><span class="muted">Sao</span></div>
      <div class="stat"><b>${worldsDone}/10</b><span class="muted">Thế giới</span></div>
      <div class="stat"><b>${progress.badges.length}</b><span class="muted">Huy hiệu</span></div>
    </div>
    <div class="card" style="margin-top:14px">
      <div class="toggle-row">
        <span>Giọng nghe</span>
        <div class="seg">
          <button class="${progress.accent === "uk" ? "on" : ""}" data-action="accent" data-v="uk">UK</button>
          <button class="${progress.accent === "us" ? "on" : ""}" data-action="accent" data-v="us">US</button>
        </div>
      </div>
    </div>
    <p class="section-title">Node trên cây</p>
    <div class="card">
      <p class="muted">Khóa xám · Mới mở phát sáng · Thành thục ánh kim 3 sao. Zoom cây để thấy gốc chữ và lá từ.</p>
    </div>
    <button class="secondary danger" data-action="reset">Xóa tiến độ</button>
  `;
}

function renderResult() {
  const r = state.play?.result || { passed: true, title: "Xong", text: "" };
  return `
    <div class="card" style="text-align:center">
      <div class="result-emoji">${r.passed ? "🌟" : "💪"}</div>
      <h2>${escapeHtml(r.title)}</h2>
      <p class="muted">${escapeHtml(r.text)}</p>
    </div>
    <button class="primary" data-action="back-map">Về bản đồ cây</button>
  `;
}

function goBack() {
  stopPlay();
  if (["sort", "build", "boss", "mic", "theory", "result"].includes(state.screen)) {
    state.screen = "map";
    state.tab = "map";
    render();
    openSheet(skillMap.nodeMap.get(state.stageId) || { type: "ipa", id: state.stageId });
    return;
  }
  state.screen = "home";
  state.tab = "home";
  render();
}

function startAt(stageId) {
  const loc = locateStage(stageId);
  if (!loc) return;
  state.worldId = loc.world.id;
  state.stageId = loc.stage.id;
  state.screen = "map";
  state.tab = "map";
  render();
  if (skillMap) {
    skillMap.expanded = loc.stage.id;
    skillMap.fitTo(loc.stage.id);
    openSheet(skillMap.nodeMap.get(loc.stage.id));
  }
}

document.addEventListener("click", (e) => {
  const el = e.target.closest("[data-action]");
  if (!el) return;
  const action = el.dataset.action;
  if (action === "speak") {
    speak(el.dataset.text);
    return;
  }
  if (action === "tab") {
    stopPlay();
    $("node-sheet").classList.add("hidden");
    state.tab = el.dataset.tab;
    state.screen = state.tab;
    render();
    if (state.tab === "map" && skillMap) {
      const n = nextPlayable();
      skillMap.fitTo(n.stage.id);
    }
    return;
  }
  if (action === "back") {
    goBack();
    return;
  }
  if (action === "start") {
    progress.onboarded = true;
    saveProgress();
    startAt(nextPlayable().stage.id);
    return;
  }
  if (action === "continue") {
    startAt(nextPlayable().stage.id);
    return;
  }
  if (action === "close-sheet") {
    $("node-sheet").classList.add("hidden");
    return;
  }
  if (action === "zoom-in") {
    skillMap.zoomBy(1.18);
    return;
  }
  if (action === "zoom-out") {
    skillMap.zoomBy(1 / 1.18);
    return;
  }
  if (action === "zoom-fit") {
    skillMap.fitTo(nextPlayable().stage.id);
    return;
  }
  if (action === "open-theory") {
    state.stageId = el.dataset.stage;
    state.screen = "theory";
    $("node-sheet").classList.add("hidden");
    render();
    return;
  }
  if (action === "finish-theory") {
    progress.theory[state.stageId] = true;
    progress.xp += 6;
    saveProgress();
    state.screen = "map";
    render();
    openSheet(skillMap.nodeMap.get(state.stageId));
    return;
  }
  if (action === "open-sort" || action === "open-build" || action === "open-boss" || action === "open-mic") {
    state.stageId = el.dataset.stage;
    $("node-sheet").classList.add("hidden");
    stopPlay();
    state.screen = action.replace("open-", "");
    render();
    if (state.screen === "mic") nextMicWord();
    return;
  }
  if (action === "build-pick") {
    pickBuild(el.dataset.g);
    return;
  }
  if (action === "boss-pick") {
    pickBoss(el.dataset.ipa);
    return;
  }
  if (action === "mic-hear") {
    if (state.play?.leaf) speak(state.play.leaf.word);
    return;
  }
  if (action === "mic-listen") {
    startMic();
    return;
  }
  if (action === "mic-skip") {
    nextMicWord();
    speak(state.play.leaf.word);
    return;
  }
  if (action === "back-map") {
    stopPlay();
    state.screen = "map";
    state.tab = "map";
    render();
    if (state.stageId) openSheet(skillMap.nodeMap.get(state.stageId));
    if (skillMap) skillMap.refresh();
    return;
  }
  if (action === "accent") {
    progress.accent = el.dataset.v;
    saveProgress();
    render();
    return;
  }
  if (action === "reset") {
    if (confirm("Xóa toàn bộ sao, lá cây và tủ kính?")) {
      progress = defaultProgress();
      progress.onboarded = true;
      saveProgress();
      state.screen = "home";
      state.tab = "home";
      render();
      if (skillMap) skillMap.refresh();
    }
  }
});

if (window.speechSynthesis) window.speechSynthesis.onvoiceschanged = () => {};

skillMap = new SkillMap();
skillMap.onIpaTap = (node) => {
  if (node.type === "ipa") {
    const loc = locateStage(node.id);
    if (!loc) return;
    state.worldId = loc.world.id;
    state.stageId = loc.stage.id;
    openSheet(node);
  } else if (node.type === "leaf") openSheet(node);
};

render();
