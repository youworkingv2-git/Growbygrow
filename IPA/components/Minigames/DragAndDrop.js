/**
 * DragAndDrop.js - Minigame A: Branch Sorting
 * Spawns 2-3 target baskets representing mindmap branches (e.g. /eɪ/ vs /æ/).
 * Drops word bubbles with audio playback.
 * Checks drag collision:
 * - Correct: Explosion particles + play success audio + Score +10
 * - Incorrect: Play error audio + Log word to WeaknessQueue
 */
class MinigameDragAndDrop {
  constructor(containerEl, stageNode, allWords, onComplete) {
    this.container = containerEl;
    this.node = stageNode;
    this.allWords = allWords;
    this.onComplete = onComplete;

    this.score = 0;
    this.mistakes = [];
    this.targetWords = this.allWords.filter(w => w.node_id === stageNode.id);
    this.distractorWords = this.allWords.filter(w => w.node_id !== stageNode.id).slice(0, 3);
    this.pool = [...this.targetWords, ...this.distractorWords].sort(() => Math.random() - 0.5);

    this.currentIndex = 0;
    this.render();
  }

  render() {
    this.container.innerHTML = `
      <div class="minigame-wrap drag-sorting-wrap">
        <div class="minigame-header">
          <h3>🎯 Branch Sorting: ${this.node.title}</h3>
          <p>Drag the word bubble into the correct IPA Branch Basket!</p>
          <div class="score-badge">Score: ${this.score}</div>
        </div>

        <div class="baskets-row">
          <div class="basket target-basket" data-ipa="${this.node.ipa_symbol}">
            <div class="basket-icon">🧺</div>
            <div class="basket-label">${this.node.ipa_symbol}</div>
            <small>Correct Branch</small>
          </div>
          <div class="basket other-basket" data-ipa="other">
            <div class="basket-icon">🗑️</div>
            <div class="basket-label">Other Sound</div>
            <small>Different Sound</small>
          </div>
        </div>

        <div class="bubble-area" id="bubble-area"></div>
      </div>
    `;

    this.spawnNextBubble();
  }

  spawnNextBubble() {
    const area = document.getElementById('bubble-area');
    if (!area) return;

    if (this.currentIndex >= this.pool.length) {
      const accuracy = Math.round((this.score / (this.pool.length * 10)) * 100);
      const stars = accuracy >= 90 ? 3 : (accuracy >= 60 ? 2 : 1);
      this.onComplete({ score: this.score, stars, mistakes: this.mistakes });
      return;
    }

    const currentWord = this.pool[this.currentIndex];
    area.innerHTML = `
      <div class="word-bubble" draggable="true" id="current-bubble">
        <span>🔊 ${currentWord.spelling}</span>
      </div>
    `;

    const bubble = document.getElementById('current-bubble');
    bubble.addEventListener('click', () => {
      window.audioEngine.speakWord(currentWord.spelling);
    });

    bubble.addEventListener('dragstart', (e) => {
      e.dataTransfer.setData('text/plain', currentWord.id);
      window.audioEngine.speakWord(currentWord.spelling);
    });

    // Basket Drop Handlers
    const baskets = this.container.querySelectorAll('.basket');
    baskets.forEach(basket => {
      basket.addEventListener('dragover', (e) => e.preventDefault());
      basket.addEventListener('drop', (e) => {
        e.preventDefault();
        const wordId = e.dataTransfer.getData('text/plain');
        if (wordId !== currentWord.id) return;

        const isTargetBasket = basket.classList.contains('target-basket');
        const isCorrectWord = currentWord.node_id === this.node.id;

        if ((isTargetBasket && isCorrectWord) || (!isTargetBasket && !isCorrectWord)) {
          // Correct Drop
          this.score += 10;
          window.audioEngine.playExplosionSound();
          window.audioEngine.playSuccessSound();
          this.triggerParticles(basket);
        } else {
          // Incorrect Drop
          window.audioEngine.playErrorSound();
          this.mistakes.push({ wordId: currentWord.id, nodeId: currentWord.node_id });
          window.progressTracker.logWeakness(currentWord.id, currentWord.node_id);
        }

        this.currentIndex++;
        setTimeout(() => this.spawnNextBubble(), 400);
      });
    });
  }

  triggerParticles(element) {
    const rect = element.getBoundingClientRect();
    for (let i = 0; i < 12; i++) {
      const p = document.createElement('div');
      p.className = 'explosion-particle';
      p.style.left = (rect.left + rect.width / 2) + 'px';
      p.style.top = (rect.top + rect.height / 2) + 'px';
      p.style.setProperty('--dx', (Math.random() - 0.5) * 120 + 'px');
      p.style.setProperty('--dy', (Math.random() - 0.5) * 120 + 'px');
      document.body.appendChild(p);
      setTimeout(() => p.remove(), 600);
    }
  }
}

window.MinigameDragAndDrop = MinigameDragAndDrop;
