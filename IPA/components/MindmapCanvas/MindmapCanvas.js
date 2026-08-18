/**
 * MindmapCanvas.js - Interactive 2D Mindmap Canvas Renderer
 * Supports Pinch-to-Zoom, Pan/Drag, smooth Bézier curves, 4 Visual Node States:
 * - LOCKED (40% opacity + padlock icon)
 * - UNLOCKED (Pulsing border glow)
 * - MASTERED (Gold border + 3-star badge)
 * - WEAK (Red tint + review alert)
 */
class MindmapCanvas {
  constructor(containerId, data, onSelectNode) {
    this.container = document.getElementById(containerId);
    this.data = data;
    this.onSelectNode = onSelectNode;

    this.currentWorld = '1';
    this.transform = { x: 50, y: 80, scale: 1.0 };
    this.isDragging = false;
    this.dragStart = { x: 0, y: 0 };

    this.canvas = document.createElement('canvas');
    this.ctx = this.canvas.getContext('2d');
    this.container.appendChild(this.canvas);

    this.nodePositions = new Map();
    this.animFrame = null;
    this.pulseTime = 0;

    this.initEvents();
    this.resize();
  }

  resize() {
    const rect = this.container.getBoundingClientRect();
    this.canvas.width = rect.width * window.devicePixelRatio;
    this.canvas.height = rect.height * window.devicePixelRatio;
    this.canvas.style.width = rect.width + 'px';
    this.canvas.style.height = rect.height + 'px';
    this.ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
    this.render();
  }

  setWorld(worldId) {
    this.currentWorld = String(worldId);
    this.transform = { x: 60, y: 100, scale: 1.0 };
    this.render();
  }

  initEvents() {
    window.addEventListener('resize', () => this.resize());

    // Mouse & Touch Pan/Drag
    this.canvas.addEventListener('mousedown', (e) => {
      this.isDragging = true;
      this.dragStart = { x: e.clientX - this.transform.x, y: e.clientY - this.transform.y };
    });

    window.addEventListener('mousemove', (e) => {
      if (!this.isDragging) return;
      this.transform.x = e.clientX - this.dragStart.x;
      this.transform.y = e.clientY - this.dragStart.y;
      this.render();
    });

    window.addEventListener('mouseup', () => {
      this.isDragging = false;
    });

    // Pinch-to-Zoom (Wheel)
    this.canvas.addEventListener('wheel', (e) => {
      e.preventDefault();
      const zoomFactor = e.deltaY < 0 ? 1.1 : 0.9;
      this.transform.scale = Math.min(Math.max(0.5, this.transform.scale * zoomFactor), 2.5);
      this.render();
    });

    // Canvas Click / Tap
    this.canvas.addEventListener('click', (e) => {
      const rect = this.canvas.getBoundingClientRect();
      const clickX = e.clientX - rect.left;
      const clickY = e.clientY - rect.top;

      for (const [nodeId, pos] of this.nodePositions.entries()) {
        const dx = clickX - pos.screenX;
        const dy = clickY - pos.screenY;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist <= pos.radius) {
          const node = this.data.nodes.find(n => n.id === nodeId);
          if (node && this.onSelectNode) {
            this.onSelectNode(node, pos.state);
          }
          break;
        }
      }
    });

    // Start pulse animation loop
    const animate = () => {
      this.pulseTime += 0.05;
      this.render();
      this.animFrame = requestAnimationFrame(animate);
    };
    animate();
  }

  calculateLayout(worldNodes) {
    const positions = new Map();
    const rootNodes = worldNodes.filter(n => !n.parent_id || !worldNodes.some(p => p.id === n.parent_id));

    let startX = 140;
    let startY = 120;
    const levelSpacingX = 180;
    const siblingSpacingY = 130;

    worldNodes.forEach((node, index) => {
      const col = index % 3;
      const row = Math.floor(index / 3);
      const x = startX + col * levelSpacingX;
      const y = startY + row * siblingSpacingY;
      positions.set(node.id, { x, y });
    });

    return positions;
  }

  render() {
    const width = this.canvas.width / window.devicePixelRatio;
    const height = this.canvas.height / window.devicePixelRatio;

    this.ctx.clearRect(0, 0, width, height);

    const worldNodes = this.data.nodes.filter(n => String(n.world_id) === String(this.currentWorld));
    if (worldNodes.length === 0) return;

    const layoutPos = this.calculateLayout(worldNodes);
    this.nodePositions.clear();

    this.ctx.save();
    this.ctx.translate(this.transform.x, this.transform.y);
    this.ctx.scale(this.transform.scale, this.transform.scale);

    // 1. Draw connecting Bézier curves
    worldNodes.forEach(node => {
      if (node.parent_id && layoutPos.has(node.parent_id) && layoutPos.has(node.id)) {
        const parentPos = layoutPos.get(node.parent_id);
        const childPos = layoutPos.get(node.id);

        const parentState = window.progressTracker.getNodeState(
          this.data.nodes.find(n => n.id === node.parent_id),
          this.data.nodes
        );

        this.ctx.beginPath();
        this.ctx.moveTo(parentPos.x, parentPos.y);

        const cp1x = parentPos.x + (childPos.x - parentPos.x) / 2;
        const cp1y = parentPos.y;
        const cp2x = parentPos.x + (childPos.x - parentPos.x) / 2;
        const cp2y = childPos.y;

        this.ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, childPos.x, childPos.y);
        this.ctx.lineWidth = 4;
        this.ctx.strokeStyle = parentState === 'LOCKED' ? 'rgba(148, 163, 184, 0.3)' : 'rgba(99, 102, 241, 0.7)';
        this.ctx.setLineDash(parentState === 'LOCKED' ? [6, 6] : []);
        this.ctx.stroke();
      }
    });

    // 2. Draw Nodes
    worldNodes.forEach(node => {
      const pos = layoutPos.get(node.id);
      if (!pos) return;

      const state = window.progressTracker.getNodeState(node, this.data.nodes);
      const radius = 42;

      // Transform to screen space for click detection
      const screenX = pos.x * this.transform.scale + this.transform.x;
      const screenY = pos.y * this.transform.scale + this.transform.y;
      this.nodePositions.set(node.id, { screenX, screenY, radius: radius * this.transform.scale, state });

      this.ctx.save();
      this.ctx.translate(pos.x, pos.y);

      // Node background & visual states
      this.ctx.beginPath();
      this.ctx.arc(0, 0, radius, 0, Math.PI * 2);

      if (state === 'LOCKED') {
        this.ctx.fillStyle = 'rgba(30, 41, 59, 0.4)';
        this.ctx.fill();
        this.ctx.lineWidth = 3;
        this.ctx.strokeStyle = 'rgba(148, 163, 184, 0.4)';
        this.ctx.stroke();

        // Lock Padlock Icon
        this.ctx.fillStyle = '#94a3b8';
        this.ctx.font = '22px sans-serif';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        this.ctx.fillText('🔒', 0, 0);

      } else if (state === 'UNLOCKED') {
        const pulse = Math.sin(this.pulseTime) * 3;
        this.ctx.fillStyle = 'rgba(30, 41, 59, 0.9)';
        this.ctx.fill();

        // Pulsing border glow
        this.ctx.shadowColor = '#38bdf8';
        this.ctx.shadowBlur = 12 + pulse;
        this.ctx.lineWidth = 4;
        this.ctx.strokeStyle = '#38bdf8';
        this.ctx.stroke();

        // Node IPA Symbol & Title
        this.ctx.shadowBlur = 0;
        this.ctx.fillStyle = '#67e8f9';
        this.ctx.font = 'bold 18px Outfit, sans-serif';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        this.ctx.fillText(node.ipa_symbol, 0, -6);

        this.ctx.fillStyle = '#94a3b8';
        this.ctx.font = '10px Nunito, sans-serif';
        this.ctx.fillText(node.title.slice(0, 14), 0, 14);

      } else if (state === 'MASTERED') {
        this.ctx.fillStyle = 'rgba(30, 41, 59, 0.95)';
        this.ctx.fill();

        // Gold border glow
        this.ctx.shadowColor = '#f59e0b';
        this.ctx.shadowBlur = 14;
        this.ctx.lineWidth = 4;
        this.ctx.strokeStyle = '#f59e0b';
        this.ctx.stroke();

        this.ctx.shadowBlur = 0;
        this.ctx.fillStyle = '#fde68a';
        this.ctx.font = 'bold 18px Outfit, sans-serif';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        this.ctx.fillText(node.ipa_symbol, 0, -8);

        // 3-Star Badge Attached
        this.ctx.fillStyle = '#fbbf24';
        this.ctx.font = '12px sans-serif';
        this.ctx.fillText('⭐⭐⭐', 0, 12);

      } else if (state === 'WEAK') {
        const pulse = Math.sin(this.pulseTime * 2) * 4;
        this.ctx.fillStyle = 'rgba(127, 29, 29, 0.85)';
        this.ctx.fill();

        // Red tint glowing alert border
        this.ctx.shadowColor = '#ef4444';
        this.ctx.shadowBlur = 16 + pulse;
        this.ctx.lineWidth = 4;
        this.ctx.strokeStyle = '#f87171';
        this.ctx.stroke();

        this.ctx.shadowBlur = 0;
        this.ctx.fillStyle = '#fecaca';
        this.ctx.font = 'bold 18px Outfit, sans-serif';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        this.ctx.fillText(node.ipa_symbol, 0, -6);

        this.ctx.fillStyle = '#fca5a5';
        this.ctx.font = 'bold 10px Nunito, sans-serif';
        this.ctx.fillText('⚠️ Review', 0, 14);
      }

      this.ctx.restore();
    });

    this.ctx.restore();
  }
}

window.MindmapCanvas = MindmapCanvas;
