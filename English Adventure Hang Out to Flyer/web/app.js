const SAVE_KEY = "english-adventure-unlock";

const WORLDS = [
  { id: "W0", name: "Tutorial Village", vi: "Làng tập làm quen", lessons: 4, color: "#c9892e", band: "Pre-A1" },
  { id: "W1", name: "My Home", vi: "Nhà của mình", lessons: 10, color: "#d4654a", band: "Beginner" },
  { id: "W2", name: "My School", vi: "Trường học", lessons: 12, color: "#3d6ea8", band: "A1" },
  { id: "W3", name: "Food City", vi: "Thành phố đồ ăn", lessons: 12, color: "#e09132", band: "A1" },
  { id: "W4", name: "Animal World", vi: "Thế giới động vật", lessons: 12, color: "#3f8a4a", band: "A1" },
  { id: "W5", name: "City", vi: "Thành phố", lessons: 12, color: "#5a6472", band: "A1+" },
  { id: "W6", name: "Weather & Seasons", vi: "Thời tiết", lessons: 10, color: "#4aa3c7", band: "A1+" },
  { id: "W7", name: "Hobbies", vi: "Sở thích", lessons: 12, color: "#7a4ea8", band: "A1+" },
  { id: "W8", name: "Travel", vi: "Du lịch", lessons: 12, color: "#1f7a6c", band: "A2" },
  { id: "W9", name: "Adventure World", vi: "Thế giới phiêu lưu", lessons: 14, color: "#24364a", band: "A2" },
  { id: "W10", name: "Flyer Island", vi: "Đảo Flyer", lessons: 16, color: "#c9892e", band: "A2 Flyers" }
];

const FURNITURE = new Set(["door", "window", "bed", "desk", "chair", "lamp"]);

const FALLBACK_MEANING = {
  hello: "xin chào", hi: "chào", goodbye: "tạm biệt", please: "làm ơn", "thank you": "cảm ơn",
  star: "ngôi sao", ball: "quả bóng", hat: "mũ", lamp: "đèn", chair: "ghế", window: "cửa sổ",
  bed: "giường", door: "cửa", desk: "bàn", mum: "mẹ", dad: "bố", sister: "chị/em gái",
  doll: "búp bê", blue: "xanh dương", red: "đỏ", green: "xanh lá",
  pencil: "bút chì", book: "sách", bag: "cặp", ruler: "thước", eraser: "cục tẩy",
  on: "ở trên", in: "ở trong", under: "ở dưới", happy: "vui", sad: "buồn", angry: "giận",
  apple: "táo", banana: "chuối", carrot: "cà rốt", milk: "sữa", cake: "bánh", fish: "cá", onion: "hành",
  cat: "mèo", dog: "chó", bird: "chim", cow: "bò", elephant: "voi", fly: "bay", swim: "bơi", big: "to", small: "nhỏ",
  park: "công viên", school: "trường", hospital: "bệnh viện", library: "thư viện", shop: "cửa hàng",
  doctor: "bác sĩ", pilot: "phi công", farmer: "nông dân", bus: "xe buýt", "next to": "bên cạnh",
  umbrella: "ô", sun: "mặt trời", snow: "tuyết", sunny: "nắng", rainy: "mưa", jacket: "áo khoác",
  windy: "gió", hot: "nóng", cold: "lạnh", coat: "áo choàng",
  football: "bóng đá", piano: "đàn piano", computer: "máy tính", swimming: "bơi", reading: "đọc", playing: "đang chơi",
  plane: "máy bay", train: "tàu", ticket: "vé", beach: "bãi biển", hotel: "khách sạn", key: "chìa khóa",
  airport: "sân bay", tomorrow: "ngày mai", yesterday: "hôm qua",
  went: "đã đi", saw: "đã thấy", bigger: "to hơn", map: "bản đồ", castle: "lâu đài",
  cooking: "nấu ăn", sleeping: "ngủ", hungry: "đói", yellow: "vàng"
};

let lessons = [];
let words = [];
let playWorld = "W0";
let queue = [];
let playIndex = 0;
let playing = false;
let isReview = false;
let xp = 0;
let hearts = 3;
let stars = 0;
let currentSay = "";
let playerName = "friend";
let missed = new Map();
let unlockedMax = Number(localStorage.getItem(SAVE_KEY) || 0);

function worldIndex(id) {
  return WORLDS.findIndex((w) => w.id === id);
}

function worldById(id) {
  return WORLDS.find((w) => w.id === id);
}

function nextWorldId(id) {
  const i = worldIndex(id);
  return i >= 0 && WORLDS[i + 1] ? WORLDS[i + 1].id : null;
}

function isOpen(id) {
  return worldIndex(id) <= unlockedMax;
}

function saveUnlock() {
  localStorage.setItem(SAVE_KEY, String(unlockedMax));
}

function unlockNext(fromId) {
  const next = nextWorldId(fromId);
  if (!next) return null;
  unlockedMax = Math.max(unlockedMax, worldIndex(next));
  saveUnlock();
  renderTrail();
  renderChips();
  return next;
}

function playData(world) {
  return WORLD_PLAY[world];
}

function fullQueue(world) {
  return (playData(world).items || []).slice();
}

function reviewQueue(world, missWords) {
  return fullQueue(world).filter((item) => item.answer && missWords.includes(item.answer));
}

function meaningOf(word) {
  const key = String(word).toLowerCase();
  const hit = words.find((w) => w.word.toLowerCase() === key);
  return (hit && hit.meaning_vi) || FALLBACK_MEANING[key] || "";
}

function markMiss(word) {
  if (!word) return;
  const key = String(word).toLowerCase();
  const prev = missed.get(key) || { word: key, mistakes: 0, meaning: meaningOf(key) };
  prev.mistakes += 1;
  prev.meaning = prev.meaning || meaningOf(key);
  missed.set(key, prev);
}

function missedList() {
  return [...missed.values()].sort((a, b) => b.mistakes - a.mistakes);
}

function speak(text) {
  currentSay = text;
  if (!window.speechSynthesis) return;
  window.speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(text);
  u.lang = "en-US";
  u.rate = 0.85;
  const voices = window.speechSynthesis.getVoices();
  const en = voices.find((v) => /en[-_]/i.test(v.lang) && /child|female|zira|samantha|google/i.test(v.name))
    || voices.find((v) => v.lang.startsWith("en"));
  if (en) u.voice = en;
  window.speechSynthesis.speak(u);
}

function showView(id) {
  document.querySelectorAll(".view").forEach((el) => el.classList.toggle("is-on", el.id === `view-${id}`));
  document.querySelectorAll(".tab").forEach((el) => el.classList.toggle("is-on", el.dataset.view === id));
}

function parseCsv(text) {
  const lines = text.trim().split(/\r?\n/);
  const headers = lines[0].split(",");
  return lines.slice(1).map((line) => {
    const cols = [];
    let cur = "";
    let inQ = false;
    for (let i = 0; i < line.length; i += 1) {
      const ch = line[i];
      if (ch === '"') inQ = !inQ;
      else if (ch === "," && !inQ) { cols.push(cur); cur = ""; }
      else cur += ch;
    }
    cols.push(cur);
    const row = {};
    headers.forEach((h, i) => { row[h] = cols[i] || ""; });
    return row;
  });
}

function renderTrail() {
  const trail = document.getElementById("world-trail");
  trail.innerHTML = WORLDS.map((w, i) => {
    const open = i <= unlockedMax;
    return `
    <li class="world ${open ? "" : "is-locked"} ${i === unlockedMax ? "mvp" : ""}">
      <div class="mark" style="background:${w.color}">${w.id}</div>
      <div>
        <h3>${w.name} · ${w.vi}</h3>
        <p>${w.lessons} bài · ${w.band}${open ? "" : " · khóa"}</p>
      </div>
      <button type="button" class="${open ? "play" : ""}" data-world="${w.id}" data-playable="${open ? "1" : "0"}">
        ${open ? "Chơi" : "Khóa"}
      </button>
    </li>`;
  }).join("");
}

function renderChips() {
  const box = document.getElementById("world-chips");
  box.innerHTML = WORLDS.map((w, i) => `
    <button type="button" class="chip ${w.id === playWorld ? "is-on" : ""}" data-play="${w.id}" ${i > unlockedMax ? "disabled" : ""}>
      ${w.id}
    </button>
  `).join("");
}

function skillCell(v) {
  return Number(v) ? '<span class="skill-on">✓</span>' : '<span class="skill-off">·</span>';
}

function renderLessons(worldId) {
  const rows = worldId === "ALL" ? lessons : lessons.filter((r) => r.world_id === worldId);
  document.getElementById("lesson-count").textContent = `${rows.length} bài`;
  document.getElementById("lesson-body").innerHTML = rows.map((r) => `
    <tr>
      <td>${r.lesson_id}</td>
      <td><b>${r.title}</b><br>${r.title_vi}</td>
      <td>${r.topic}</td>
      <td>${r.vocabulary}</td>
      <td>${r.sentence_patterns}</td>
      <td>${skillCell(r.listening)}</td>
      <td>${skillCell(r.speaking)}</td>
      <td>${skillCell(r.reading)}</td>
      <td>${skillCell(r.writing)}</td>
      <td>${r.mini_game}</td>
      <td>${r.level}</td>
    </tr>
  `).join("");
}

function renderWords(topic) {
  const list = topic === "ALL" ? words : words.filter((w) => w.topic === topic);
  document.getElementById("word-grid").innerHTML = list.map((w) => `
    <button class="word" type="button" data-say="${w.word}">
      <b>${w.word}</b>
      <small>${w.meaning_vi} · ${w.lesson_id}</small>
      <p class="ex">${w.example}</p>
    </button>
  `).join("");
}

function setHud() {
  document.getElementById("hud-hearts").textContent = "❤ ".repeat(hearts).trim() || "—";
  document.getElementById("hud-stars").textContent = `${"★".repeat(stars)}${"☆".repeat(Math.max(0, 3 - stars))}`;
  document.getElementById("hud-xp").textContent = `${xp} XP`;
}

function setLine(text) {
  document.getElementById("npc-line").textContent = `Mira: ${text}`;
}

function setFeedback(text, kind) {
  const el = document.getElementById("feedback");
  el.textContent = text;
  el.className = `feedback ${kind || ""}`;
}

function setMeta(world) {
  const w = worldById(world);
  const next = nextWorldId(world);
  document.getElementById("play-kicker").textContent = isReview ? `${world} · Ôn từ sai` : `${world} · ${w.name}`;
  document.getElementById("play-title").textContent = isReview ? "Chơi lại từ sai" : w.vi;
  document.getElementById("play-hook").textContent = isReview
    ? "Chỉ những từ vừa làm sai. Đúng ngay thì khỏi ôn tiếp."
    : `Nghe Mira rồi chọn hoặc chạm đúng. Xong ${world} sẽ mở ${next || "Flyer Champion"}.`;
  document.getElementById("play-howto").innerHTML = `
    <p><b>Hành trình</b></p>
    <ol>
      <li>Chơi hết màn của world này.</li>
      <li>Ôn từ sai nếu có.</li>
      <li>Bấm mở world tiếp theo, đến W10.</li>
    </ol>`;
  renderChips();
}

function villageShell(inner) {
  return `<span class="mira-label">Mira</span><div class="gate" title="gate"></div>${inner}`;
}

function fieldHtml(objects) {
  return `<div class="field">${(objects || []).map((o) =>
    `<button class="obj field-obj" type="button" data-id="${o}">${o}</button>`
  ).join("")}</div>`;
}

function roomHtml() {
  return `
    <div class="room" id="room">
      <button class="obj door" data-id="door" style="left:6%;top:28%"><span>door</span></button>
      <button class="obj window" data-id="window" style="left:38%;top:10%"><span>window</span></button>
      <button class="obj bed" data-id="bed" style="left:58%;top:48%"><span>bed</span></button>
      <button class="obj desk" data-id="desk" style="left:8%;top:62%"><span>desk</span></button>
      <button class="obj chair" data-id="chair" style="left:28%;top:68%"><span>chair</span></button>
      <button class="obj lamp" data-id="lamp" style="left:78%;top:18%"><span>lamp</span></button>
    </div>`;
}

function currentItem() {
  return queue[playIndex];
}

function wrapScene(item, inner) {
  const sceneName = item.scene || playData(playWorld).scene;
  const scene = document.getElementById("stage-scene");
  scene.className = `scene ${sceneName}`;
  scene.innerHTML = sceneName === "village" ? villageShell(inner) : inner;
}

function renderItem(item) {
  if (!item) return;
  const total = queue.length;
  const n = playIndex + 1;
  document.getElementById("play-hint").textContent = isReview
    ? `Ôn ${n}/${total} · ${item.answer || ""}`
    : `${item.hint || playWorld} · ${n}/${total}`;
  setLine(item.line || item.say);

  if (item.type === "name") {
    wrapScene(item, `
      <form class="name-box" id="name-form">
        <input id="name-input" maxlength="16" placeholder="Anna" autocomplete="nickname" />
        <button class="cta" type="submit">OK</button>
      </form>`);
    const form = document.getElementById("name-form");
    const input = document.getElementById("name-input");
    input.focus();
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      playerName = input.value.trim() || "friend";
      setFeedback("Great!", "ok");
      speak(`Hi, ${playerName}!`);
      setLine(`Hi, ${playerName}! My name is Mira.`);
      xp += 10;
      stars = Math.min(3, stars + 1);
      setHud();
      playIndex += 1;
      setTimeout(runQueue, 900);
    });
    speak(item.say);
    return;
  }

  if (item.type === "listen_choose") {
    wrapScene(item, `<div class="choices">${item.choices.map((c) =>
      `<button class="choice" type="button" data-choice="${c.toLowerCase()}">${c}</button>`
    ).join("")}</div>`);
    speak(item.say);
    return;
  }

  const objs = item.objects || [];
  if (item.scene === "room" && objs.every((o) => FURNITURE.has(o))) {
    const scene = document.getElementById("stage-scene");
    scene.className = "scene";
    scene.innerHTML = roomHtml();
  } else {
    wrapScene(item, fieldHtml(objs));
  }
  speak(item.say);
}

function nextCta(list) {
  if (list.length) {
    return `<button class="cta" type="button" data-review>Chơi lại ${list.length} từ sai</button>
            <button class="cta ghost" type="button" data-skip-review>Bỏ qua, world tiếp</button>`;
  }
  const next = nextWorldId(playWorld);
  if (next) {
    const w = worldById(next);
    return `<button class="cta" type="button" data-next-world="${next}">Mở ${next} · ${w.vi} →</button>`;
  }
  return `<p><b>Flyer Champion!</b> Bạn đã đi hết bản đồ.</p>`;
}

function showRecap(list) {
  const item = { scene: playData(playWorld).scene };
  const perfect = list.length === 0;
  const items = list.map((m) => `
    <li>
      <button type="button" data-say="${m.word}">
        <b>${m.word}</b>
        <small>${m.meaning || ""} · sai ${m.mistakes} lần</small>
      </button>
    </li>`).join("");
  const body = perfect
    ? `<p>Không có từ sai. World ${playWorld} xong!</p>`
    : `<p>Từ vừa làm sai — chạm để nghe, rồi chơi lại.</p><ul class="miss-list">${items}</ul>`;
  wrapScene(item, `<div class="recap">
      <h3>${isReview ? "Ôn xong vòng này" : "Tổng hợp sau bài"}</h3>
      ${body}
      <div class="recap-actions">${nextCta(list)}</div>
    </div>`);
  document.getElementById("play-hint").textContent = perfect
    ? (nextWorldId(playWorld) ? `Xong ${playWorld}. Mở world tiếp theo.` : "Hết hành trình.")
    : `Cần ôn ${list.length} từ.`;
}

function finishRun() {
  playing = false;
  const list = missedList();
  if (list.length === 0) {
    stars = 3;
    xp += isReview ? 10 : 20;
    setHud();
    setLine("Great job!");
    speak("Great job!");
    setFeedback(`Xong ${playWorld}`, "ok");
    unlockNext(playWorld);
  } else {
    setLine("Let's practice these words.");
    speak("Let's practice these words.");
    setFeedback(`Có ${list.length} từ cần ôn lại`, "bad");
  }
  showRecap(list);
}

function runQueue() {
  if (playIndex >= queue.length) {
    finishRun();
    return;
  }
  renderItem(currentItem());
}

function startPlay(world, review) {
  const id = world || "W0";
  if (!isOpen(id)) {
    setFeedback(`Hãy xong ${WORLDS[unlockedMax].id} trước.`, "bad");
    return;
  }
  playWorld = id;
  isReview = Boolean(review);
  playing = true;
  playIndex = 0;
  hearts = 3;
  stars = 0;
  if (!isReview) {
    missed = new Map();
    queue = fullQueue(playWorld);
  } else {
    const wordsToRetry = missedList().map((m) => m.word);
    missed = new Map();
    queue = reviewQueue(playWorld, wordsToRetry);
    if (!queue.length) {
      isReview = false;
      playing = false;
      unlockNext(playWorld);
      showRecap([]);
      return;
    }
  }
  setHud();
  setFeedback("");
  setMeta(playWorld);
  showView("play");
  runQueue();
}

function startReview() {
  startPlay(playWorld, true);
}

function skipReview() {
  missed = new Map();
  isReview = false;
  playing = false;
  unlockNext(playWorld);
  setFeedback("Đã bỏ qua phần ôn.", "ok");
  showRecap([]);
}

function wrong() {
  const item = currentItem();
  markMiss(item && item.answer);
  hearts = Math.max(0, hearts - 1);
  setHud();
  setFeedback("Try again! Listen carefully.", "bad");
  speak("Try again. Listen carefully.");
  setTimeout(() => item && speak(item.say), 1100);
}

function advance() {
  xp += 10;
  stars = Math.min(3, stars + 1);
  setHud();
  setFeedback("Great!", "ok");
  speak("Great!");
  playIndex += 1;
  setTimeout(runQueue, 800);
}

function handleChoice(value, btn) {
  if (!playing) {
    setFeedback("Bấm Bắt đầu trước nhé.", "bad");
    return;
  }
  const item = currentItem();
  if (!item || item.type !== "listen_choose") return;
  if (value === item.answer) {
    btn.classList.add("is-right");
    advance();
  } else {
    btn.classList.add("is-wrong");
    wrong();
  }
}

function handleFind(id, btn) {
  if (!playing) {
    setLine(`This is a ${id}.`);
    speak(id);
    return;
  }
  const item = currentItem();
  if (!item || !item.answer) return;
  if (id === item.answer) {
    btn.classList.add("is-right");
    advance();
  } else {
    btn.classList.add("is-wrong");
    wrong();
  }
}

async function load() {
  renderTrail();
  renderChips();
  playWorld = WORLDS[Math.min(unlockedMax, WORLDS.length - 1)].id;
  playing = false;
  isReview = false;
  setMeta(playWorld);
  wrapScene({ scene: playData(playWorld).scene }, "");
  setLine("Hello! Tap Bắt đầu to play.");
  setFeedback("");
  document.getElementById("play-hint").textContent = `World đang mở: ${playWorld}. Bấm Bắt đầu.`;
  document.getElementById("hero-play").dataset.play = playWorld;
  document.getElementById("hero-play").textContent = `Chơi ${playWorld} →`;

  const [csvText, vocabJson] = await Promise.all([
    fetch("../docs/curriculum/lesson-matrix-full.csv").then((r) => r.text()),
    fetch("../docs/curriculum/vocabulary-bank-mvp.json").then((r) => r.json())
  ]);
  lessons = parseCsv(csvText);
  words = vocabJson.words;

  const worldSelect = document.getElementById("filter-world");
  worldSelect.innerHTML = `<option value="ALL">Tất cả</option>` + WORLDS.map((w) =>
    `<option value="${w.id}">${w.id} · ${w.name}</option>`
  ).join("");
  worldSelect.value = "W0";
  renderLessons("W0");

  const topics = ["ALL", ...new Set(words.map((w) => w.topic))];
  const topicSelect = document.getElementById("filter-topic");
  topicSelect.innerHTML = topics.map((t) => `<option value="${t}">${t}</option>`).join("");
  renderWords("ALL");
}

document.querySelectorAll(".tab").forEach((btn) => {
  btn.addEventListener("click", () => showView(btn.dataset.view));
});
document.getElementById("world-chips").addEventListener("click", (e) => {
  const btn = e.target.closest("[data-play]");
  if (btn && !btn.disabled) startPlay(btn.dataset.play);
});
document.getElementById("hero-play").addEventListener("click", (e) => {
  startPlay(e.currentTarget.dataset.play || "W0");
});
document.getElementById("world-trail").addEventListener("click", (e) => {
  const btn = e.target.closest("[data-world]");
  if (!btn) return;
  if (btn.dataset.playable === "1") {
    startPlay(btn.dataset.world);
    return;
  }
  setFeedback("World này còn khóa. Hãy xong world đang mở.", "bad");
  showView("map");
});
document.getElementById("filter-world").addEventListener("change", (e) => renderLessons(e.target.value));
document.getElementById("filter-topic").addEventListener("change", (e) => renderWords(e.target.value));
document.getElementById("word-grid").addEventListener("click", (e) => {
  const btn = e.target.closest(".word");
  if (btn) speak(btn.dataset.say);
});
document.getElementById("btn-start").addEventListener("click", () => startPlay(playWorld));
document.getElementById("btn-listen").addEventListener("click", () => speak(currentSay || "Hello!"));
document.getElementById("stage-scene").addEventListener("click", (e) => {
  const review = e.target.closest("[data-review]");
  if (review) { startReview(); return; }
  const skip = e.target.closest("[data-skip-review]");
  if (skip) { skipReview(); return; }
  const next = e.target.closest("[data-next-world]");
  if (next) { startPlay(next.dataset.nextWorld); return; }
  const sayBtn = e.target.closest(".miss-list [data-say]");
  if (sayBtn) { speak(sayBtn.dataset.say); return; }
  const choice = e.target.closest("[data-choice]");
  if (choice) { handleChoice(choice.dataset.choice, choice); return; }
  const obj = e.target.closest("[data-id]");
  if (obj) handleFind(obj.dataset.id, obj);
});
if (window.speechSynthesis) window.speechSynthesis.onvoiceschanged = () => {};

load().catch((err) => {
  document.getElementById("lesson-count").textContent = "Không tải được dữ liệu. Hãy mở trang qua http://localhost.";
  console.error(err);
});
