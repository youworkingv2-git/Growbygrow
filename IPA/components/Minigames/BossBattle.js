/**
 * BossBattle.js - Minigame C: Boss Exception Slayer
 * Presents irregular word (e.g. "SAID" or "HAVE").
 * Shows timer (10s) and 2 attack buttons (/seɪd/ vs /sed/).
 * Correct: Reduce boss HP by 50%. Incorrect: Player takes damage and log to WeaknessQueue.
 */
class MinigameBossBattle {
  constructor(containerEl, stageNode, allWords, onComplete) {
    this.container = containerEl;
    this.node = stageNode;
    this.allWords = allWords;
    this.onComplete = onComplete;

    this.bossHp = 100;
    this.playerHp = 100;
    this.timer = 10;
    this.timerInterval = null;
    this.score = 0;
    this.mistakes = [];

    this.exceptionWords = this.allWords.filter(w => w.is_exception || w.node_id === stageNode.id);
    if (this.exceptionWords.length === 0) {
      this.exceptionWords = this.allWords.slice(0, 3);
    }

    this.currentIndex = 0;
    this.render();
  }

  render() {
    if (this.bossHp <= 0) {
      clearInterval(this.timerInterval);
      window.audioEngine.playSuccessSound();
      this.onComplete({ score: 100, stars: 3, mistakes: this.mistakes });
      return;
    }
    if (this.playerHp <= 0 || this.currentIndex >= this.exceptionWords.length) {
      clearInterval(this.timerInterval);
      const stars = this.bossHp <= 50 ? 2 : 1;
      this.onComplete({ score: this.score, stars, mistakes: this.mistakes });
      return;
    }

    const current = this.exceptionWords[this.currentIndex];
    const correctSound = current.spelling === 'said' ? '/sed/' : (current.spelling === 'have' ? '/hæv/' : '/ɡɪv/');
    const wrongSound = current.spelling === 'said' ? '/seɪd/' : (current.spelling === 'have' ? '/heɪv/' : '/ɡaɪv/');

    const attacks = [
      { ipa: correctSound, isCorrect: true },
      { ipa: wrongSound, isCorrect: false }
    ].sort(() => Math.random() - 0.5);

    this.container.innerHTML = `
      <div class="minigame-wrap boss-battle-wrap">
        <div class="boss-header">
          <h3>👹 Boss Exception Slayer: Irregular Words!</h3>
          <p>Defeat the Exception Monster by identifying irregular pronunciations!</p>
        </div>

        <div class="health-bars">
          <div class="hp-box">
            <span>👹 Boss HP</span>
            <div class="hp-bar-outer"><div class="hp-bar-inner boss-hp" style="width: ${this.bossHp}%"></div></div>
          </div>
          <div class="hp-box">
            <span>🛡️ Player HP</span>
            <div class="hp-bar-outer"><div class="hp-bar-inner player-hp" style="width: ${this.playerHp}%"></div></div>
          </div>
        </div>

        <div class="timer-badge">⏳ Time Left: <strong id="boss-timer">10</strong>s</div>

        <div class="boss-card">
          <div class="boss-monster-icon">👾</div>
          <div class="boss-word">${current.spelling.toUpperCase()}</div>
          <p class="boss-tip">${current.exception_tip || 'Watch out for irregular spelling traps!'}</p>
        </div>

        <div class="attack-buttons">
          ${attacks.map(att => `
            <button class="attack-btn" data-correct="${att.isCorrect}">
              ⚔️ Attack with ${att.ipa}
            </button>
          `).join('')}
        </div>
      </div>
    `;

    this.startTimer();

    const attackBtns = this.container.querySelectorAll('.attack-btn');
    attackBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        clearInterval(this.timerInterval);
        const isCorrect = btn.getAttribute('data-correct') === 'true';

        if (isCorrect) {
          this.bossHp -= 50;
          this.score += 50;
          window.audioEngine.playBossHitSound();
        } else {
          this.playerHp -= 50;
          window.audioEngine.playErrorSound();
          this.mistakes.push({ wordId: current.id, nodeId: current.node_id });
          window.progressTracker.logWeakness(current.id, current.node_id);
        }

        this.currentIndex++;
        setTimeout(() => this.render(), 500);
      });
    });
  }

  startTimer() {
    clearInterval(this.timerInterval);
    this.timer = 10;
    const timerEl = document.getElementById('boss-timer');

    this.timerInterval = setInterval(() => {
      this.timer--;
      if (timerEl) timerEl.textContent = this.timer;

      if (this.timer <= 0) {
        clearInterval(this.timerInterval);
        this.playerHp -= 50;
        window.audioEngine.playErrorSound();
        const current = this.exceptionWords[this.currentIndex];
        this.mistakes.push({ wordId: current.id, nodeId: current.node_id });
        window.progressTracker.logWeakness(current.id, current.node_id);

        this.currentIndex++;
        setTimeout(() => this.render(), 500);
      }
    }, 1000);
  }
}

window.MinigameBossBattle = MinigameBossBattle;
