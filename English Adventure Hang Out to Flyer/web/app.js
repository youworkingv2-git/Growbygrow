const WORLDS = [
  { id: "W0", name: "Tutorial Village", vi: "Làng tập làm quen", lessons: 4, color: "#c9892e", band: "Pre-A1", mvp: true, playable: true },
  { id: "W1", name: "My Home", vi: "Nhà của mình", lessons: 10, color: "#d4654a", band: "Beginner", mvp: true, playable: true },
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

const W0_BEATS = [
  {
    id: "W0-T01",
    title: "First Steps",
    hint: "Beat 1/4 · Nghe Hello rồi chọn đúng lời chào",
    type: "listen_choose",
    say: "Hello!",
    line: "Hello! Hi! Come in.",
    choices: ["Hello", "Goodbye", "Please"],
    answer: "hello"
  },
  {
    id: "W0-T02",
    title: "Your Name",
    hint: "Beat 2/4 · Gõ tên rồi bấm OK",
    type: "name",
    say: "What's your name?",
    line: "What's your name?"
  },
  {
    id: "W0-T03",
    title: "How to Play",
    hint: "Beat 3/4 · Nghe Find the star rồi chạm ngôi sao",
    type: "find_it",
    say: "Find the star.",
    line: "Find the star.",
    objects: [
      { id: "ball", label: "ball", left: "18%", top: "22%" },
      { id: "star", label: "star", left: "48%", top: "18%" },
      { id: "hat", label: "hat", left: "72%", top: "24%" }
    ],
    answer: "star"
  },
  {
    id: "W0-T04",
    title: "Thank You",
    hint: "Beat 4/4 · Nghe Thank you rồi chọn đúng",
    type: "listen_choose",
    say: "Thank you.",
    line: "Please help. Thank you! Goodbye!",
    choices: ["Hello", "Thank you", "No"],
    answer: "thank you"
  }
];

const W1_FINDS = [
  { say: "Find the lamp.", answer: "lamp" },
  { say: "Find the chair.", answer: "chair" },
  { say: "Find the window.", answer: "window" },
  { say: "There is a bed. Find the bed.", answer: "bed" }
];

let lessons = [];
let words = [];
let playWorld = "W0";
let playIndex = 0;
let playing = false;
let xp = 0;
let hearts = 3;
let stars = 0;
let currentSay = "";
let playerName = "friend";

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
  trail.innerHTML = WORLDS.map((w) => `
    <li class="world ${w.mvp ? "mvp" : ""}">
      <div class="mark" style="background:${w.color}">${w.id}</div>
      <div>
        <h3>${w.name} · ${w.vi}</h3>
        <p>${w.lessons} bài · ${w.band}${w.playable ? " · bấm Chơi" : ""}</p>
      </div>
      <button type="button" class="${w.playable ? "play" : ""}" data-world="${w.id}" data-playable="${w.playable ? "1" : "0"}">
        ${w.playable ? "Chơi" : "Xem bài"}
      </button>
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

function setMeta(world) {
  document.querySelectorAll(".chip").forEach((el) => el.classList.toggle("is-on", el.dataset.play === world));
  if (world === "W0") {
    document.getElementById("play-kicker").textContent = "World 0 · Tutorial Village";
    document.getElementById("play-title").textContent = "Làng tập làm quen";
    document.getElementById("play-hook").textContent = "Mira đợi ở cổng làng. Làm 4 việc nhỏ rồi được vào nhà.";
    document.getElementById("play-howto").innerHTML = `
      <p><b>Cách chơi World 0</b></p>
      <ol>
        <li>Bấm <b>Bắt đầu</b> để Mira nói tiếng Anh.</li>
        <li>Beat 1: nghe <i>Hello!</i> → chọn Hello.</li>
        <li>Beat 2: nghe <i>What's your name?</i> → gõ tên → OK.</li>
        <li>Beat 3: nghe <i>Find the star.</i> → chạm ngôi sao, không chạm ball/hat.</li>
        <li>Beat 4: nghe <i>Thank you.</i> → chọn Thank you.</li>
      </ol>`;
  } else {
    document.getElementById("play-kicker").textContent = "World 1 · Lesson 04";
    document.getElementById("play-title").textContent = "My Room";
    document.getElementById("play-hook").textContent = "Phòng ngủ. Nghe rồi chạm đúng đồ vật.";
    document.getElementById("play-howto").innerHTML = `
      <p><b>Cách chơi My Room</b></p>
      <ol>
        <li>Bấm <b>Bắt đầu</b>.</li>
        <li>Nghe Mira: Find the lamp / chair / window / bed.</li>
        <li>Chạm đúng đồ trong phòng. Sai thì Try again.</li>
      </ol>`;
  }
}

function villageShell(inner) {
  return `
    <span class="mira-label">Mira</span>
    <div class="gate" title="gate"></div>
    ${inner}
  `;
}

function renderW0Beat() {
  const scene = document.getElementById("stage-scene");
  scene.className = "scene village";
  const beat = W0_BEATS[playIndex];
  if (!beat) {
    scene.innerHTML = villageShell(`<div class="choices"><button class="choice is-right" type="button" data-next-home>Vào nhà →</button></div>`);
    return;
  }
  document.getElementById("play-hint").textContent = beat.hint;
  setLine(beat.line);
  if (beat.type === "listen_choose") {
    scene.innerHTML = villageShell(`
      <div class="choices">
        ${beat.choices.map((c) => `<button class="choice" type="button" data-choice="${c.toLowerCase()}">${c}</button>`).join("")}
      </div>`);
  } else if (beat.type === "name") {
    scene.innerHTML = villageShell(`
      <form class="name-box" id="name-form">
        <input id="name-input" maxlength="16" placeholder="Anna" autocomplete="nickname" />
        <button class="cta" type="submit">OK</button>
      </form>`);
    const form = document.getElementById("name-form");
    const input = document.getElementById("name-input");
    input.focus();
    form.addEventListener("submit", (e) => {
      e.preventDefault();
      const name = input.value.trim() || "friend";
      playerName = name;
      setFeedback("Great!", "ok");
      speak(`Hi, ${name}!`);
      setLine(`Hi, ${name}! My name is Mira.`);
      xp += 10;
      stars = Math.min(3, stars + 1);
      setHud();
      playIndex += 1;
      setTimeout(runBeat, 900);
    });
  } else if (beat.type === "find_it") {
    scene.innerHTML = villageShell(beat.objects.map((o) =>
      `<button class="obj ${o.id}" type="button" data-id="${o.id}" style="left:${o.left};top:${o.top};position:absolute">${o.label}</button>`
    ).join(""));
  }
  speak(beat.say);
}

function renderW1Room() {
  const scene = document.getElementById("stage-scene");
  scene.className = "scene";
  scene.innerHTML = `
    <div class="room" id="room">
      <button class="obj door" data-id="door" style="left:6%;top:28%"><span>door</span></button>
      <button class="obj window" data-id="window" style="left:38%;top:10%"><span>window</span></button>
      <button class="obj bed" data-id="bed" style="left:58%;top:48%"><span>bed</span></button>
      <button class="obj desk" data-id="desk" style="left:8%;top:62%"><span>desk</span></button>
      <button class="obj chair" data-id="chair" style="left:28%;top:68%"><span>chair</span></button>
      <button class="obj lamp" data-id="lamp" style="left:78%;top:18%"><span>lamp</span></button>
    </div>`;
}

function startPlay(world) {
  playWorld = world || "W0";
  playing = true;
  playIndex = 0;
  hearts = 3;
  stars = 0;
  xp = 0;
  setHud();
  setFeedback("");
  setMeta(playWorld);
  showView("play");
  if (playWorld === "W0") {
    document.getElementById("play-hint").textContent = "Beat 1/4 · Chào Mira";
    runBeat();
  } else {
    renderW1Room();
    document.getElementById("play-hint").textContent = "Nghe rồi chạm đúng đồ vật.";
    nextFind();
  }
}

function runBeat() {
  if (playIndex >= W0_BEATS.length) {
    playing = false;
    stars = 3;
    xp += 15;
    setHud();
    setLine("Goodbye! Come to my home.");
    speak("Goodbye! Come to my home.");
    setFeedback("Xong World 0 · +15 XP · có thể vào My Home", "ok");
    document.getElementById("play-hint").textContent = "Tutorial xong. Bấm W1 Phòng ngủ để chơi tiếp.";
    renderW0Beat();
    return;
  }
  renderW0Beat();
}

function nextFind() {
  document.querySelectorAll(".obj").forEach((el) => el.classList.remove("is-right", "is-wrong"));
  if (playIndex >= W1_FINDS.length) {
    playing = false;
    stars = 3;
    xp += 20;
    setHud();
    setLine("Great! There is a lamp. Teddy was here.");
    speak("Great job! You found the things in my room.");
    setFeedback("Xong bài My Room · +20 XP · ★★★", "ok");
    return;
  }
  const step = W1_FINDS[playIndex];
  setLine(step.say);
  document.getElementById("play-hint").textContent = `Tìm: ${step.answer}`;
  speak(step.say);
}

function wrong() {
  hearts = Math.max(0, hearts - 1);
  setHud();
  setFeedback("Try again! Listen carefully.", "bad");
  speak("Try again. Listen carefully.");
  const beat = playWorld === "W0" ? W0_BEATS[playIndex] : W1_FINDS[playIndex];
  setTimeout(() => speak(beat.say), 1100);
}

function handleChoice(value, btn) {
  if (!playing) {
    setFeedback("Bấm Bắt đầu trước nhé.", "bad");
    return;
  }
  if (playWorld !== "W0") return;
  const beat = W0_BEATS[playIndex];
  if (beat.type !== "listen_choose") return;
  if (value === beat.answer) {
    btn.classList.add("is-right");
    xp += 10;
    stars = Math.min(3, stars + 1);
    setHud();
    setFeedback("Great!", "ok");
    speak("Great!");
    playIndex += 1;
    setTimeout(runBeat, 800);
  } else {
    btn.classList.add("is-wrong");
    wrong();
  }
}

function handleFind(id, btn) {
  if (!playing) {
    setLine(playWorld === "W0" ? `This is a ${id}.` : `This is a ${id}.`);
    speak(id);
    return;
  }
  const answer = playWorld === "W0" ? W0_BEATS[playIndex].answer : W1_FINDS[playIndex].answer;
  if (id === answer) {
    btn.classList.add("is-right");
    xp += 10;
    stars = Math.min(3, stars + 1);
    setHud();
    setFeedback("Great!", "ok");
    speak("Great!");
    playIndex += 1;
    setTimeout(playWorld === "W0" ? runBeat : nextFind, 800);
  } else {
    btn.classList.add("is-wrong");
    wrong();
  }
}

async function load() {
  renderTrail();
  playWorld = "W0";
  playing = false;
  playIndex = 0;
  setMeta("W0");
  const scene = document.getElementById("stage-scene");
  scene.className = "scene village";
  scene.innerHTML = villageShell("");
  setLine("Hello! Tap Bắt đầu to play.");
  setFeedback("");
  document.getElementById("play-hint").textContent = "Bấm Bắt đầu. Trình duyệt sẽ đọc Hello!";

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
document.querySelectorAll("[data-play]").forEach((btn) => {
  btn.addEventListener("click", () => startPlay(btn.dataset.play));
});
document.getElementById("world-trail").addEventListener("click", (e) => {
  const btn = e.target.closest("[data-world]");
  if (!btn) return;
  if (btn.dataset.playable === "1") {
    startPlay(btn.dataset.world);
    return;
  }
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
document.getElementById("btn-start").addEventListener("click", () => startPlay(playWorld));
document.getElementById("btn-listen").addEventListener("click", () => speak(currentSay || "Hello!"));
document.getElementById("stage-scene").addEventListener("click", (e) => {
  const home = e.target.closest("[data-next-home]");
  if (home) {
    startPlay("W1");
    return;
  }
  const choice = e.target.closest("[data-choice]");
  if (choice) {
    handleChoice(choice.dataset.choice, choice);
    return;
  }
  const obj = e.target.closest("[data-id]");
  if (obj) handleFind(obj.dataset.id, obj);
});
if (window.speechSynthesis) window.speechSynthesis.onvoiceschanged = () => {};

load().catch((err) => {
  document.getElementById("lesson-count").textContent = "Không tải được dữ liệu. Hãy mở trang qua http://localhost.";
  console.error(err);
});
