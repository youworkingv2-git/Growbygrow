const WORLDS = [
  { id: "W0", name: "Tutorial Village", vi: "Làng tập làm quen", lessons: 4, color: "#c9892e", band: "Pre-A1", mvp: true },
  { id: "W1", name: "My Home", vi: "Nhà của mình", lessons: 10, color: "#d4654a", band: "Beginner", mvp: true },
  { id: "W2", name: "My School", vi: "Trường học", lessons: 12, color: "#3d6ea8", band: "A1", mvp: false },
  { id: "W3", name: "Food City", vi: "Thành phố đồ ăn", lessons: 12, color: "#e09132", band: "A1", mvp: false },
  { id: "W4", name: "Animal World", vi: "Thế giới động vật", lessons: 12, color: "#3f8a4a", band: "A1", mvp: false },
  { id: "W5", name: "City", vi: "Thành phố", lessons: 12, color: "#5a6472", band: "A1+", mvp: false },
  { id: "W6", name: "Weather & Seasons", vi: "Thời tiết", lessons: 10, color: "#4aa3c7", band: "A1+", mvp: false },
  { id: "W7", name: "Hobbies", vi: "Sở thích", lessons: 12, color: "#7a4ea8", band: "A1+", mvp: false },
  { id: "W8", name: "Travel", vi: "Du lịch", lessons: 12, color: "#1f7a6c", band: "A2", mvp: false },
  { id: "W9", name: "Adventure World", vi: "Thế giới phiêu lưu", lessons: 14, color: "#24364a", band: "A2", mvp: false },
  { id: "W10", name: "Flyer Island", vi: "Đảo Flyer", lessons: 16, color: "#c9892e", band: "A2 Flyers", mvp: false }
];

const FINDS = [
  { say: "Find the lamp.", answer: "lamp" },
  { say: "Find the chair.", answer: "chair" },
  { say: "Find the window.", answer: "window" },
  { say: "There is a bed. Find the bed.", answer: "bed" }
];

let lessons = [];
let words = [];
let playIndex = 0;
let playing = false;
let xp = 0;
let hearts = 3;
let stars = 0;
let currentSay = "";

function speak(text) {
  currentSay = text;
  if (!window.speechSynthesis) return;
  window.speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(text);
  u.lang = "en-US";
  u.rate = 0.85;
  const voices = window.speechSynthesis.getVoices();
  const en = voices.find((v) => v.lang.startsWith("en"));
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
  trail.innerHTML = WORLDS.map((w) => `
    <li class="world ${w.mvp ? "mvp" : ""}">
      <div class="mark" style="background:${w.color}">${w.id}</div>
      <div>
        <h3>${w.name} · ${w.vi}</h3>
        <p>${w.lessons} bài · ${w.band}${w.mvp ? " · đang làm MVP" : ""}</p>
      </div>
      <button type="button" data-world="${w.id}">Xem bài</button>
    </li>
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

function startPlay() {
  playing = true;
  playIndex = 0;
  hearts = 3;
  stars = 0;
  xp = 0;
  setHud();
  setFeedback("");
  document.getElementById("play-hint").textContent = "Nghe rồi chạm đúng đồ vật. Sai thì Try again — không game over.";
  nextFind();
}

function nextFind() {
  document.querySelectorAll(".obj").forEach((el) => el.classList.remove("is-right", "is-wrong"));
  if (playIndex >= FINDS.length) {
    playing = false;
    stars = 3;
    xp += 20;
    setHud();
    setLine("Great! There is a lamp. Teddy was here.");
    speak("Great job! You found the things in my room.");
    setFeedback("Xong bài My Room · +20 XP  ·  ★★★", "ok");
    return;
  }
  const step = FINDS[playIndex];
  setLine(step.say);
  speak(step.say);
}

function tapObject(id, btn) {
  if (!playing) {
    setLine(`This is a ${id}.`);
    speak(id);
    return;
  }
  const step = FINDS[playIndex];
  if (id === step.answer) {
    btn.classList.add("is-right");
    xp += 10;
    stars = Math.min(3, stars + 1);
    setHud();
    setFeedback("Great!", "ok");
    speak("Great!");
    playIndex += 1;
    setTimeout(nextFind, 700);
  } else {
    btn.classList.add("is-wrong");
    hearts = Math.max(0, hearts - 1);
    setHud();
    setFeedback("Try again! Listen carefully.", "bad");
    speak("Try again. Listen carefully.");
    setTimeout(() => speak(step.say), 1100);
  }
}

async function load() {
  renderTrail();

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
  worldSelect.value = "W1";
  renderLessons("W1");

  const topics = ["ALL", ...new Set(words.map((w) => w.topic))];
  const topicSelect = document.getElementById("filter-topic");
  topicSelect.innerHTML = topics.map((t) => `<option value="${t}">${t}</option>`).join("");
  renderWords("ALL");
}

document.querySelectorAll(".tab").forEach((btn) => {
  btn.addEventListener("click", () => showView(btn.dataset.view));
});
document.querySelector("[data-open-play]").addEventListener("click", () => {
  showView("play");
  startPlay();
});
document.getElementById("world-trail").addEventListener("click", (e) => {
  const btn = e.target.closest("[data-world]");
  if (!btn) return;
  document.getElementById("filter-world").value = btn.dataset.world;
  renderLessons(btn.dataset.world);
  showView("lessons");
});
document.getElementById("filter-world").addEventListener("change", (e) => renderLessons(e.target.value));
document.getElementById("filter-topic").addEventListener("change", (e) => renderWords(e.target.value));
document.getElementById("word-grid").addEventListener("click", (e) => {
  const btn = e.target.closest(".word");
  if (btn) speak(btn.dataset.say);
});
document.getElementById("btn-start").addEventListener("click", startPlay);
document.getElementById("btn-listen").addEventListener("click", () => speak(currentSay || "This is my room."));
document.getElementById("room").addEventListener("click", (e) => {
  const btn = e.target.closest(".obj");
  if (btn) tapObject(btn.dataset.id, btn);
});
if (window.speechSynthesis) window.speechSynthesis.onvoiceschanged = () => {};

load().catch((err) => {
  document.getElementById("lesson-count").textContent = "Không tải được dữ liệu. Hãy mở trang qua http://localhost, không mở file trực tiếp.";
  console.error(err);
});
