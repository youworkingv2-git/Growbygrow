/**
 * Dynamic skill-tree mindmap: IPA hub → grapheme roots → word leaves
 */
function leafNode(word, ipa, meaning, grapheme, stageId, color) {
  const parts = splitByGrapheme(word, grapheme);
  return {
    id: `leaf-${stageId}-${word}`,
    type: "leaf",
    label: word,
    word,
    ipa,
    meaning,
    grapheme,
    prefix: parts.prefix,
    suffix: parts.suffix,
    stageId,
    color,
    children: []
  };
}

function exampleWord(ex) {
  if (typeof ex === "string") return { word: ex, ipa: "", meaning: "" };
  return { word: ex.word, ipa: ex.ipa || "", meaning: ex.meaning || "" };
}

function graphemesForStage(stage, color) {
  if (stage.map && stage.map.spellings && stage.map.spellings.length) {
    return stage.map.spellings.map((sp) => ({
      id: `${stage.id}-g-${sp.grapheme}`,
      type: "grapheme",
      label: sp.grapheme,
      speak: graphemeSpeak(sp.grapheme),
      ipa: sp.ipa || stage.targetIpa,
      stageId: stage.id,
      color,
      children: (sp.examples || []).slice(0, 4).map((ex) => {
        const e = exampleWord(ex);
        return leafNode(e.word, e.ipa, e.meaning, sp.grapheme, stage.id, color);
      })
    }));
  }
  const g = String(stage.spelling || "").split(" / ")[0].split("·")[0].trim() || stage.targetIpa;
  const words = (stage.core.examples || []).slice(0, 4);
  return [
    {
      id: `${stage.id}-g-main`,
      type: "grapheme",
      label: g,
      speak: graphemeSpeak(g),
      ipa: stage.targetIpa,
      stageId: stage.id,
      color,
      children: words.map((ex) => {
        const e = exampleWord(ex);
        return leafNode(e.word, e.ipa, e.meaning, g, stage.id, color);
      })
    }
  ];
}

function buildForest() {
  return {
    id: "root",
    type: "root",
    label: "PHONICS",
    color: "#6366f1",
    children: ALL_WORLDS.map((world) => ({
      id: world.id,
      type: "world",
      label: world.titleVi,
      sub: world.title,
      emoji: world.emoji,
      color: world.color,
      worldId: world.id,
      children: world.stages.map((stage) => ({
        id: stage.id,
        type: "ipa",
        label: stage.targetIpa,
        spelling: stage.spelling,
        speakWord: stage.speakWord,
        cue: ipaCue(stage.targetIpa),
        worldId: world.id,
        color: world.color,
        stageId: stage.id,
        children: graphemesForStage(stage, world.color)
      }))
    }))
  };
}

class SkillMap {
  constructor() {
    this.svg = document.getElementById("skill-svg");
    this.wrap = document.getElementById("svg-wrap");
    this.zoomG = document.getElementById("skill-zoom");
    this.forest = buildForest();
    this.nodeMap = new Map();
    this.transform = { x: 40, y: 40, k: 0.72 };
    this.dragging = false;
    this.moved = false;
    this.last = { x: 0, y: 0 };
    this.pinch = null;
    this.expanded = null;
    this.onIpaTap = null;
    this.flatten(this.forest);
    this.layout();
    this.bind();
    this.draw();
  }

  flatten(node, parent = null) {
    node.parentId = parent ? parent.id : null;
    this.nodeMap.set(node.id, node);
    (node.children || []).forEach((c) => this.flatten(c, node));
  }

  layout() {
    const GAP = 18;
    const sizeOf = (n) => {
      if (n.type === "leaf") return 72;
      if (n.type === "grapheme") return 88;
      if (n.type === "ipa") return 108;
      if (n.type === "world") return 120;
      return 140;
    };
    const walk = (node) => {
      const kids = node.children || [];
      if (!kids.length) {
        node.subW = sizeOf(node);
        node.lx = 0;
        return;
      }
      kids.forEach(walk);
      let cursor = 0;
      kids.forEach((k) => {
        k.lx = cursor + k.subW / 2;
        cursor += k.subW + GAP;
      });
      const span = cursor - GAP;
      const mid = (kids[0].lx + kids[kids.length - 1].lx) / 2;
      kids.forEach((k) => {
        k.lx -= mid;
      });
      node.subW = Math.max(sizeOf(node), span);
      node.lx = 0;
    };
    walk(this.forest);
    const yGap = { root: 0, world: 150, ipa: 128, grapheme: 96, leaf: 78 };
    const place = (node, acc, depthY) => {
      node.x = acc + (node.lx || 0);
      node.y = depthY;
      const nextY = depthY + (yGap[node.type] || 100);
      (node.children || []).forEach((c) => place(c, node.x, nextY));
    };
    place(this.forest, 0, 0);
  }

  nodeState(node) {
    if (node.type === "root") return "mastered";
    if (node.type === "world") {
      const w = worldById(node.id);
      if (!isWorldUnlocked(w)) return "locked";
      if (worldCompleted(w)) return "mastered";
      return "unlocked";
    }
    const stageId = node.stageId || (node.type === "ipa" ? node.id : null);
    if (!stageId) return "unlocked";
    const loc = locateStage(stageId);
    if (!loc || !isStageUnlocked(loc.world, loc.index)) return "locked";
    if (isMastered(stageId)) return "mastered";
    return "unlocked";
  }

  applyTransform() {
    this.zoomG.setAttribute(
      "transform",
      `translate(${this.transform.x},${this.transform.y}) scale(${this.transform.k})`
    );
  }

  shouldShow(node) {
    const k = this.transform.k;
    if (node.type === "grapheme") return k >= 1.05 || this.expanded === node.stageId || this.expanded === node.parentId;
    if (node.type === "leaf") return k >= 1.45 || this.expanded === node.stageId;
    return true;
  }

  draw() {
    const links = [];
    const nodes = [];
    this.nodeMap.forEach((n) => {
      if (n.type === "root") nodes.push(n);
      else {
        const p = this.nodeMap.get(n.parentId);
        if (!p) return;
        if (!this.shouldShow(n) && n.type !== "ipa" && n.type !== "world") return;
        if (n.type === "grapheme" && !this.shouldShow(n)) return;
        if (n.type === "leaf" && !this.shouldShow(n)) return;
        if ((n.type === "grapheme" || n.type === "leaf") && !this.shouldShow(n)) return;
        links.push([p, n]);
        nodes.push(n);
      }
    });

    const linkHtml = links
      .filter(([p, n]) => {
        if (n.type === "grapheme" && !this.shouldShow(n)) return false;
        if (n.type === "leaf" && !this.shouldShow(n)) return false;
        if (p.type === "ipa" && n.type === "grapheme" && !this.shouldShow(n)) return false;
        return true;
      })
      .map(([p, n]) => {
        const d = `M ${p.x} ${p.y} C ${p.x} ${(p.y + n.y) / 2}, ${n.x} ${(p.y + n.y) / 2}, ${n.x} ${n.y}`;
        const st = this.nodeState(n.type === "leaf" || n.type === "grapheme" ? this.nodeMap.get(n.stageId) || n : n);
        return `<path class="sk-link ${st}" d="${d}"></path>`;
      })
      .join("");

    const nodeHtml = nodes
      .map((n) => {
        if ((n.type === "grapheme" || n.type === "leaf") && !this.shouldShow(n)) return "";
        const st = this.nodeState(n);
        const r = n.type === "root" ? 28 : n.type === "world" ? 24 : n.type === "ipa" ? 22 : n.type === "grapheme" ? 16 : 12;
        const label = n.type === "world" ? `${n.emoji} ${n.label}` : n.label;
        const dy = n.type === "leaf" ? 22 : n.type === "grapheme" ? 26 : 34;
        const lock = st === "locked" && (n.type === "ipa" || n.type === "world") ? "🔒" : "";
        const stars = n.type === "ipa" && st === "mastered" ? "★★★" : n.type === "ipa" && modeCount(n.id) ? "★".repeat(modeCount(n.id)) : "";
        const captured = n.type === "leaf" && progress.captured[n.word] ? " captured" : "";
        const spoken = n.type === "leaf" && progress.spoken[n.word] ? " spoken" : "";
        return `<g class="sknode ${n.type} ${st}${captured}${spoken}" data-id="${n.id}" data-kind="${n.type}" transform="translate(${n.x},${n.y})">
          <circle class="sk-orb" r="${r}" style="--c:${n.color || "#6366f1"}"></circle>
          <text class="sk-lock" text-anchor="middle" dy="4">${lock}</text>
          <text class="sk-label" text-anchor="middle" dy="${dy}">${escapeXml(label)}</text>
          <text class="sk-stars" text-anchor="middle" dy="-28">${stars}</text>
        </g>`;
      })
      .join("");

    this.zoomG.innerHTML = `<g class="sk-links">${linkHtml}</g><g class="sk-nodes">${nodeHtml}</g>`;
    this.applyTransform();
  }

  bind() {
    const wrap = this.wrap;
    wrap.addEventListener("pointerdown", (e) => {
      if (e.target.closest(".tree-controls")) return;
      this.dragging = true;
      this.moved = false;
      this.last = { x: e.clientX, y: e.clientY };
      wrap.setPointerCapture(e.pointerId);
    });
    wrap.addEventListener("pointermove", (e) => {
      if (!this.dragging) return;
      const dx = e.clientX - this.last.x;
      const dy = e.clientY - this.last.y;
      if (Math.hypot(dx, dy) > 6) this.moved = true;
      this.transform.x += dx;
      this.transform.y += dy;
      this.last = { x: e.clientX, y: e.clientY };
      this.applyTransform();
    });
    const end = (e) => {
      if (!this.dragging) return;
      this.dragging = false;
      if (!this.moved) this.handleTap(e);
    };
    wrap.addEventListener("pointerup", end);
    wrap.addEventListener("pointercancel", end);
    wrap.addEventListener(
      "wheel",
      (e) => {
        e.preventDefault();
        this.zoomAt(e.offsetX, e.offsetY, e.deltaY < 0 ? 1.12 : 1 / 1.12);
      },
      { passive: false }
    );
    wrap.addEventListener(
      "touchstart",
      (e) => {
        if (e.touches.length === 2) {
          this.pinch = distT(e.touches[0], e.touches[1]);
        }
      },
      { passive: true }
    );
    wrap.addEventListener(
      "touchmove",
      (e) => {
        if (e.touches.length === 2 && this.pinch) {
          e.preventDefault();
          const d = distT(e.touches[0], e.touches[1]);
          const rec = wrap.getBoundingClientRect();
          this.zoomAt(rec.width / 2, rec.height / 2, d / this.pinch);
          this.pinch = d;
        }
      },
      { passive: false }
    );
  }

  zoomAt(cx, cy, factor) {
    const k0 = this.transform.k;
    const k1 = Math.min(2.4, Math.max(0.35, k0 * factor));
    const s = k1 / k0;
    this.transform.x = cx - (cx - this.transform.x) * s;
    this.transform.y = cy - (cy - this.transform.y) * s;
    this.transform.k = k1;
    this.draw();
  }

  zoomBy(f) {
    const rec = this.wrap.getBoundingClientRect();
    this.zoomAt(rec.width / 2, rec.height / 2, f);
  }

  fitTo(nodeId) {
    const n = this.nodeMap.get(nodeId) || this.forest;
    const rec = this.wrap.getBoundingClientRect();
    this.transform.k = n.type === "ipa" ? 1.35 : 0.78;
    this.transform.x = rec.width / 2 - n.x * this.transform.k;
    this.transform.y = rec.height / 2 - n.y * this.transform.k - 40;
    this.draw();
  }

  handleTap(e) {
    const g = e.target.closest(".sknode");
    if (!g) return;
    const node = this.nodeMap.get(g.dataset.id);
    if (!node) return;
    this.playLayerAudio(node);
    if (node.type === "ipa") {
      this.expanded = node.id;
      this.draw();
      this.fitTo(node.id);
      if (this.onIpaTap) this.onIpaTap(node);
    } else if (node.type === "world") {
      const first = node.children[0];
      if (first) this.fitTo(first.id);
    } else if (node.type === "leaf" && this.onIpaTap) {
      this.onIpaTap(node);
    }
  }

  playLayerAudio(node) {
    if (node.type === "ipa") speak(node.cue || node.speakWord);
    else if (node.type === "grapheme") speak(node.speak);
    else if (node.type === "leaf") speak(node.word);
    else if (node.type === "world") speak(node.sub || node.label);
    else speak("Phonics Quest");
  }

  refresh() {
    this.draw();
  }
}

function distT(a, b) {
  return Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY);
}

function escapeXml(s) {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

var skillMap = null;
