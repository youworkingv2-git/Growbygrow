/**
 * PatternCompletion.js - Minigame B: Pattern Assembly
 * Displays incomplete word (e.g. w _ _ t) and plays sound /weɪt/.
 * Offers multiple spelling options (ai, ay, a_e).
 * On wrong selection: Display quick rule tip (e.g., "ai is usually in the middle").
 */
class MinigamePatternCompletion {
  constructor(containerEl, stageNode, allWords, onComplete) {
    this.container = containerEl;
    this.node = stageNode;
    this.allWords = allWords;
    this.onComplete = onComplete;

    this.score = 0;
    this.mistakes = [];
    this.targetWords = this.allWords.filter(w => w.node_id === stageNode.id);
    this.currentIndex = 0;

    this.render();
  }

  render() {
    if (this.currentIndex >= this.targetWords.length) {
      const accuracy = Math.round((this.score / (this.targetWords.length * 10)) * 100);
      const stars = accuracy >= 90 ? 3 : (accuracy >= 60 ? 2 : 1);
      this.onComplete({ score: this.score, stars, mistakes: this.mistakes });
      return;
    }

    const current = this.targetWords[this.currentIndex];
    const displayPattern = current.pattern;
    const incompleteWord = current.spelling.replace(displayPattern.replace('_', ''), '_ _');

    const options = [displayPattern, 'ea', 'ay', 'a_e', 'ai', 'ee'].filter((v, i, a) => a.indexOf(v) === i).slice(0, 3);
    if (!options.includes(displayPattern)) options[0] = displayPattern;
    options.sort(() => Math.random() - 0.5);

    this.container.innerHTML = `
      <div class="minigame-wrap pattern-assembly-wrap">
        <div class="minigame-header">
          <h3>🧩 Pattern Assembly: ${this.node.title}</h3>
          <p>Listen to the sound and assemble the correct spelling pattern!</p>
          <button class="audio-btn" id="play-sound-btn">🔊 Play Sound (/${this.node.ipa_symbol}/)</button>
        </div>

        <div class="puzzle-card">
          <div class="incomplete-word">${incompleteWord}</div>
          <div class="tip-box hidden" id="rule-tip-box"></div>
        </div>

        <div class="options-grid">
          ${options.map(opt => `<button class="opt-btn" data-pattern="${opt}">${opt}</button>`).join('')}
        </div>
      </div>
    `;

    const playBtn = document.getElementById('play-sound-btn');
    playBtn.addEventListener('click', () => {
      window.audioEngine.speakWord(current.spelling);
    });

    // Auto-play sound
    window.audioEngine.speakWord(current.spelling);

    const optionBtns = this.container.querySelectorAll('.opt-btn');
    optionBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        const selected = btn.getAttribute('data-pattern');
        const tipBox = document.getElementById('rule-tip-box');

        if (selected === displayPattern) {
          btn.classList.add('correct');
          this.score += 10;
          window.audioEngine.playSuccessSound();
          setTimeout(() => {
            this.currentIndex++;
            this.render();
          }, 600);
        } else {
          btn.classList.add('wrong');
          window.audioEngine.playErrorSound();
          this.mistakes.push({ wordId: current.id, nodeId: current.node_id });
          window.progressTracker.logWeakness(current.id, current.node_id);

          const tipText = current.exception_tip || `Quick Rule Tip: "${displayPattern}" is the target pattern for "${current.spelling}".`;
          tipBox.innerHTML = `💡 ${tipText}`;
          tipBox.classList.remove('hidden');
        }
      });
    });
  }
}

window.MinigamePatternCompletion = MinigamePatternCompletion;
