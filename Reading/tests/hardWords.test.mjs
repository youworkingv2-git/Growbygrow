import {
  normalizeHardWordList,
  upsertHardWord,
  removeHardWord,
  setHardWordSelected,
  getSelectedHardWords,
  saveManualHardWord,
} from '../js/hardWords.js';
import { MISREAD_PRACTICE_THRESHOLD } from '../js/ipa.js';

function assert(cond, msg) {
  if (!cond) throw new Error(msg);
}

let words = [];

words = upsertHardWord(words, {
  display: 'difficult',
  normalized: 'difficult',
  misreadCount: 5,
  lessonId: 'a1-test',
  lessonTitle: 'Test',
  sentenceText: 'It is difficult.',
});
assert(words.length === 1, 'adds one word');
assert(words[0].selected === true, 'selected by default');
assert(words[0].misreadCount === MISREAD_PRACTICE_THRESHOLD, 'meets threshold');

words = upsertHardWord(words, {
  display: 'difficult',
  normalized: 'difficult',
  misreadCount: 8,
});
assert(words.length === 1, 'merges duplicate');
assert(words[0].misreadCount === 8, 'keeps max misread count');

words = setHardWordSelected(words, 'difficult', false);
assert(getSelectedHardWords(words).length === 0, 'deselect works');

words = removeHardWord(words, 'difficult');
assert(words.length === 0, 'remove works');

const parsed = normalizeHardWordList([
  { display: 'hello', normalized: 'hello', misreadCount: 3 },
  null,
  { display: 'world', normalized: 'world', misreadCount: 6, selected: false },
]);
assert(parsed.length === 2, 'normalizes list');
assert(parsed[0].misreadCount >= MISREAD_PRACTICE_THRESHOLD, 'raises low counts');
assert(parsed[1].selected === false, 'keeps explicit selection');

const manual = saveManualHardWord([], {
  display: 'beautiful',
  ipa: '/ˈbjuːtɪfəl/',
  sentenceText: 'She is beautiful.',
});
assert(manual.id === 'beautiful', 'manual add works');
assert(manual.words[0].manual === true, 'manual flag set');
assert(manual.words[0].misreadCount === 0, 'manual word has zero misreads');

const edited = saveManualHardWord(manual.words, {
  id: 'beautiful',
  display: 'beautiful',
  ipa: '/ˈbjuːtɪfl/',
});
assert(edited.words[0].ipa === '/ˈbjuːtɪfl/', 'manual edit updates ipa');
assert(edited.words[0].ipaManual === true, 'manual ipa is flagged');

const addedAgain = saveManualHardWord(edited.words, {
  display: 'beautiful',
  ipa: '/new-ipa/',
});
assert(addedAgain.words.length === 1, 'saving existing word updates instead of duplicating');
assert(addedAgain.words[0].ipa === '/new-ipa/', 'manual ipa overwrites previous value');

const renamedId = saveManualHardWord(
  [{ id: 'custom-1', display: 'hello', normalized: 'hello', ipa: null, ipaManual: false }],
  { display: 'hello', ipa: '/həˈləʊ/' },
);
assert(renamedId.words[0].ipa === '/həˈləʊ/', 'updates ipa when stored id differs from word');
assert(renamedId.words[0].ipaManual === true, 'marks ipa as manual on id mismatch update');

console.log('hardWords tests: ok');
