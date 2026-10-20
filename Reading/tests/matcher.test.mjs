import {
  tokenizeSentence,
  normalizeWord,
  normalizeTranscript,
  wordsFromTranscript,
  matchAccumulating,
  applyTranscript,
  transcriptMatchesWord,
  isSentenceComplete,
} from '../js/matcher.js';
import { wordsMatch } from '../js/numberWords.js';
import { formatTextForTts } from '../js/tts.js';
import { needsPronunciationHelp, MISREAD_PRACTICE_THRESHOLD } from '../js/ipa.js';
import {
  setPronunciationAccuracy,
  similarityPercent,
} from '../js/pronunciationAccuracy.js';

function assert(cond, msg) {
  if (!cond) throw new Error(msg);
}

// normalize
assert(normalizeWord("six.") === 'six', 'strip trailing punct');
assert(normalizeWord("'clock") === "'clock", 'keep apostrophe word');
assert(normalizeWord("i'm") === "i'm", 'keep contraction apostrophe');
assert(normalizeWord("i'm.") === "i'm", 'period does not change i\'m');
assert(normalizeWord("i'm,") === "i'm", 'comma does not change i\'m');
assert(normalizeWord("I'm.") === "i'm", 'capitalized i\'m. normalizes');
assert(wordsMatch("i'm", "i'm."), "i'm matches i'm.");
assert(wordsMatch("i'm,", "i'm"), "i'm, matches i'm");
assert(wordsMatch("hello,", "hello."), 'comma and period are ignored');
assert(wordsMatch("what?", "what"), 'question mark is ignored');
assert(wordsMatch("wow!", "wow"), 'exclamation is ignored');
assert(wordsMatch("wait...", "wait"), 'ellipsis is ignored');
assert(wordsMatch("really?!", "really"), 'mixed punctuation is ignored');
assert(normalizeWord("Hello?") === 'hello', 'normalize drops ?');
assert(normalizeWord("Stop!") === 'stop', 'normalize drops !');
assert(normalizeWord("Wait...") === 'wait', 'normalize drops ...');
assert(normalizeWord("won't.") === "won't", 'normalize won\'t.');
assert(normalizeWord("won't,") === "won't", 'normalize won\'t,');
assert(normalizeWord("won't!") === "won't", 'normalize won\'t!');
assert(normalizeWord("won't?") === "won't", 'normalize won\'t?');
assert(normalizeWord("won’t.") === "won't", 'normalize won’t. with curly apostrophe');
assert(normalizeWord("won’t!") === "won't", 'normalize won’t! with curly apostrophe');
assert(wordsMatch("won't.", "won't"), "won't. matches won't");
assert(wordsMatch("won't,", "won't"), "won't, matches won't");
assert(wordsMatch("won't!", "won't"), "won't! matches won't");
assert(wordsMatch("won't?", "won't"), "won't? matches won't");
assert(wordsMatch("won't.", "won't,"), "won't. matches won't,");
assert(wordsMatch("won't!", "won't."), "won't! matches won't.");
assert(wordsMatch("won’t.", "won't"), "won’t. matches won't");
assert(wordsMatch("won’t", "won't!"), "won’t matches won't!");

// Museums. vs Museum's, its vs it's, thats vs that's
assert(wordsMatch("Museums.", "Museum's"), "Museums. matches Museum's");
assert(wordsMatch("Museums", "Museum's"), "Museums matches Museum's");
assert(wordsMatch("museums", "museum's"), "museums matches museum's");
assert(wordsMatch("its", "it's"), "its matches it's");
assert(wordsMatch("it's", "its"), "it's matches its");
assert(wordsMatch("that's", "thats"), "that's matches thats");
assert(wordsMatch("teachers", "teacher's"), "teachers matches teacher's");
assert(wordsMatch("students", "students'"), "students matches students'");
assert(wordsMatch("company's", "companys"), "company's matches companys");

const tQ = tokenizeSentence("Are you ready?");
const mQ = new Set();
matchAccumulating(wordsFromTranscript("are you ready"), tQ, mQ);
assert(isSentenceComplete(mQ, tQ.length), 'spoken without ? matches sentence with ?');

const tExclaim = tokenizeSentence("Look out");
const mExclaim = new Set();
matchAccumulating(wordsFromTranscript("look out!"), tExclaim, mExclaim);
assert(isSentenceComplete(mExclaim, tExclaim.length), 'spoken with ! matches sentence without');

const tEllipsis = tokenizeSentence('Wait ... go.');
assert(tEllipsis.every((tok) => tok.normalized), 'punctuation-only tokens skipped');
assert(tEllipsis.map((tok) => tok.normalized).join(' ') === 'wait go', 'ellipsis token ignored');

const goodbyeVariants = [
  'goodbye,please',
  'goodbye, please!',
  'goodbye,please',
  'Goodbye, please',
  'goodbye please',
];
const goodbyeNormalized = goodbyeVariants.map((s) =>
  tokenizeSentence(s).map((tok) => tok.normalized).join(' '),
);
assert(
  goodbyeNormalized.every((s) => s === 'goodbye please'),
  'goodbye comma/space/exclamation variants tokenize the same',
);
for (const spoken of goodbyeVariants) {
  const t = tokenizeSentence('Goodbye, please!');
  const m = new Set();
  matchAccumulating(wordsFromTranscript(spoken), t, m);
  assert(isSentenceComplete(m, t.length), `spoken "${spoken}" matches goodbye, please!`);
}

const tPlease = tokenizeSentence('goodbye,please');
assert(tPlease.length === 2, 'goodbye,please splits into two words');
assert(tPlease[0].display === 'goodbye,', 'comma stays on first display token');
assert(tPlease[0].hasSpaceAfter === false, 'no space after comma when glued');

const tIm = tokenizeSentence("I'm happy.");
assert(tIm[0].normalized === "i'm", 'token i\'m. drops period');
const mIm = new Set();
matchAccumulating(wordsFromTranscript("i'm happy"), tIm, mIm);
assert(isSentenceComplete(mIm, tIm.length), "spoken i'm matches sentence i'm.");

const tImSpokenPeriod = tokenizeSentence("I'm happy");
const mImSpokenPeriod = new Set();
matchAccumulating(wordsFromTranscript("i'm. happy,"), tImSpokenPeriod, mImSpokenPeriod);
assert(isSentenceComplete(mImSpokenPeriod, tImSpokenPeriod.length), "spoken i'm. matches sentence i'm");

const tWont = tokenizeSentence("No, I won't.");
assert(tWont.length === 3, 'three tokens in No, I won\'t.');
assert(tWont[2].normalized === "won't", 'won\'t. normalized to won\'t');
const mWont1 = new Set();
matchAccumulating(wordsFromTranscript("no i won't"), tWont, mWont1);
assert(isSentenceComplete(mWont1, tWont.length), "spoken without punct matches sentence No, I won't.");

const mWont2 = new Set();
matchAccumulating(wordsFromTranscript("no! i, won't!"), tWont, mWont2);
assert(isSentenceComplete(mWont2, tWont.length), "spoken with ! and , matches sentence No, I won't.");

const tWontCurly = tokenizeSentence("No, I won’t!");
assert(tWontCurly[2].normalized === "won't", 'curly won’t! normalized to won\'t');
const mWontCurly = new Set();
matchAccumulating(wordsFromTranscript("no i won't"), tWontCurly, mWontCurly);
assert(isSentenceComplete(mWontCurly, tWontCurly.length), "spoken won't matches curly won’t!");

// normalizeTranscript ASR mishearings
assert(normalizeTranscript("ISS A/C.") === 'Issac', 'ISS A/C. normalizes to Issac');
assert(normalizeTranscript("ISS A/C") === 'Issac', 'ISS A/C normalizes to Issac');
assert(normalizeTranscript("ISS AC") === 'Issac', 'ISS AC normalizes to Issac');
assert(normalizeTranscript("iss a/c") === 'Issac', 'iss a/c normalizes to Issac');
assert(
  normalizeTranscript("I saw ISS A/C. doing it this morning.") ===
    'I saw Issac doing it this morning.',
  'full sentence ISS A/C. normalizes to Issac',
);

const tIssac = tokenizeSentence("I saw Issac doing it this morning.");
const mIssac = new Set();
matchAccumulating(
  wordsFromTranscript("I saw ISS A/C. doing it this morning."),
  tIssac,
  mIssac,
);
assert(
  isSentenceComplete(mIssac, tIssac.length),
  'spoken ISS A/C. matches sentence with Issac',
);

// Contraction expansion sentence tests
// 1. Spoken "that is" matches sentence token "That's"
const tThats = tokenizeSentence("That's great.");
const mThats1 = new Set();
matchAccumulating(wordsFromTranscript("that is great"), tThats, mThats1);
assert(isSentenceComplete(mThats1, tThats.length), 'spoken "that is" matches sentence "That\'s"');

// 2. Spoken "that's" matches sentence tokens "That is"
const tThatIs = tokenizeSentence("That is great.");
const mThatIs1 = new Set();
matchAccumulating(wordsFromTranscript("that's great"), tThatIs, mThatIs1);
assert(isSentenceComplete(mThatIs1, tThatIs.length), 'spoken "that\'s" matches sentence "That is"');

// 3. Spoken "it is" matches sentence token "It's"
const tIts = tokenizeSentence("It's awesome.");
const mIts1 = new Set();
matchAccumulating(wordsFromTranscript("it is awesome"), tIts, mIts1);
assert(isSentenceComplete(mIts1, tIts.length), 'spoken "it is" matches sentence "It\'s"');

// 4. Spoken "its" matches sentence token "It's"
const mIts2 = new Set();
matchAccumulating(wordsFromTranscript("its awesome"), tIts, mIts2);
assert(isSentenceComplete(mIts2, tIts.length), 'spoken "its" matches sentence "It\'s"');

// 5. Spoken "the museums history" matches sentence "The museum's history."
const tMuseum = tokenizeSentence("The museum's history is rich.");
const mMuseum = new Set();
matchAccumulating(wordsFromTranscript("the museums history is rich"), tMuseum, mMuseum);
assert(isSentenceComplete(mMuseum, tMuseum.length), 'spoken "museums" matches sentence "museum\'s"');

// 6. Spoken "do not worry" matches sentence "Don't worry."
const tDont = tokenizeSentence("Don't worry.");
const mDont = new Set();
matchAccumulating(wordsFromTranscript("do not worry"), tDont, mDont);
assert(isSentenceComplete(mDont, tDont.length), 'spoken "do not" matches sentence "Don\'t"');

// 7. Spoken "don't worry" matches sentence "Do not worry."
const tDoNot = tokenizeSentence("Do not worry.");
const mDoNot = new Set();
matchAccumulating(wordsFromTranscript("don't worry"), tDoNot, mDoNot);
assert(isSentenceComplete(mDoNot, tDoNot.length), 'spoken "don\'t" matches sentence "Do not"');

// tokenize
const tokens = tokenizeSentence("I wake up at six.");
assert(tokens.length === 5, 'five tokens');
assert(tokens[0].normalized === 'i', 'first word');

// accumulate out of order
const matched = new Set();
const spoken1 = wordsFromTranscript('wake I up');
matchAccumulating(spoken1, tokens, matched);
assert(matched.size === 3, 'three words matched out of order');
assert(!matched.has(3), 'at not yet');

const spoken2 = wordsFromTranscript('at six');
matchAccumulating(spoken2, tokens, matched);
assert(isSentenceComplete(matched, tokens.length), 'sentence complete');

// ignore wrong words
const t2 = tokenizeSentence('hello world');
const m2 = new Set();
matchAccumulating(wordsFromTranscript('foo hello bar world baz'), t2, m2);
assert(m2.size === 2, 'only correct words matched');

// each slot once
const t3 = tokenizeSentence('I I wake');
const m3 = new Set();
matchAccumulating(wordsFromTranscript('I I I wake'), t3, m3);
assert(m3.size === 3, 'two I slots + wake');

// number words: ASR often returns digits, "6.", or "6:00"
assert(wordsMatch('20', 'twenty'), 'twenty matches 20');
assert(wordsMatch('6', 'six'), 'six matches 6');
assert(wordsMatch('6.', 'six'), 'six matches 6.');
assert(wordsMatch('6:00', 'six'), 'six matches 6:00');
assert(wordsMatch('six', '6:00'), '6:00 matches six');
assert(wordsMatch('06:00', 'six'), 'six matches 06:00');
assert(!wordsMatch('6:30', 'six'), '6:30 does not match six');
const t4 = tokenizeSentence('I am twenty years old.');
const m4 = new Set();
matchAccumulating(wordsFromTranscript('I am 20 years old'), t4, m4);
assert(m4.size === 5, 'digit 20 matches word twenty');

const tSixDot = tokenizeSentence('I wake up at six.');
const mSixDot = new Set();
matchAccumulating(wordsFromTranscript('I wake up at 6.'), tSixDot, mSixDot);
assert(isSentenceComplete(mSixDot, tSixDot.length), '6. matches six');

const tClock = tokenizeSentence("I wake up at six o'clock.");
const mClock = new Set();
matchAccumulating(wordsFromTranscript('I wake up at 6:00'), tClock, mClock);
assert(isSentenceComplete(mClock, tClock.length), '6:00 matches six o\'clock');

const tSixWord = tokenizeSentence('I invited six friends.');
const mSixWord = new Set();
matchAccumulating(wordsFromTranscript('I invited 6 friends'), tSixWord, mSixWord);
assert(isSentenceComplete(mSixWord, tSixWord.length), '6 matches six in a count');

// hyphenated words: tokenization and matching
const t5 = tokenizeSentence('I learn food-related words.');
assert(t5.length === 5, 'splits food-related into food- and related (5 tokens total)');
assert(t5[2].display === 'food-', 'hyphenated first part display');
assert(t5[2].normalized === 'food', 'hyphenated first part normalized');
assert(t5[2].hasSpaceAfter === false, 'hyphenated first part hasSpaceAfter false');
assert(t5[3].display === 'related', 'hyphenated second part display');
assert(t5[3].normalized === 'related', 'hyphenated second part normalized');
assert(t5[3].hasSpaceAfter === true, 'hyphenated second part hasSpaceAfter true');

const m5 = new Set();
matchAccumulating(wordsFromTranscript('I learn food related words'), t5, m5);
assert(isSentenceComplete(m5, t5.length), 'matches split words');

const m6 = new Set();
matchAccumulating(wordsFromTranscript('I learn food-related words'), t5, m6);
assert(isSentenceComplete(m6, t5.length), 'matches hyphenated spoken words');

const t6 = tokenizeSentence('I learn food related words.');
const m7 = new Set();
matchAccumulating(wordsFromTranscript('I learn food-related words'), t6, m7);
assert(isSentenceComplete(m7, t6.length), 'matches hyphenated spoken words to split sentence tokens');

// spelling variations (US vs UK English)
assert(wordsMatch('travelling', 'traveling'), 'travelling matches traveling');
assert(wordsMatch('cancelled', 'canceled'), 'cancelled matches canceled');
assert(wordsMatch('colour', 'color'), 'colour matches color');
assert(wordsMatch('centre', 'center'), 'centre matches center');
assert(wordsMatch('realise', 'realize'), 'realise matches realize');
assert(wordsMatch('organisation', 'organization'), 'organisation matches organization');
assert(wordsMatch('analyse', 'analyze'), 'analyse matches analyze');
assert(wordsMatch('defence', 'defense'), 'defence matches defense');
assert(wordsMatch('dialogue', 'dialog'), 'dialogue matches dialog');
assert(wordsMatch('issac', 'isaac'), 'issac matches isaac');
assert(wordsMatch('Isaac', 'issac'), 'Isaac matches issac');
assert(wordsMatch('Issac', 'Isaac'), 'Issac matches Isaac');

// spelling variations edge cases / preservation of numbers and short words
assert(wordsMatch('four', 'four'), 'four matches four');
assert(!wordsMatch('four', 'for'), 'four does not match for');
assert(wordsMatch('four', '4'), 'four matches 4');
assert(wordsMatch('hour', 'hour'), 'hour matches hour');
assert(!wordsMatch('hour', 'hor'), 'hour does not match hor');
assert(wordsMatch('sour', 'sour'), 'sour matches sour');
assert(!wordsMatch('sour', 'sor'), 'sour does not match sor');

// Vietnamese names TTS phonetic formatting
assert(
  formatTextForTts('I am Linh from GreenTech.') === 'I am Lin from GreenTech.',
  'TTS Linh formats as Lin',
);
assert(
  formatTextForTts('Minh and Hoa are here.') === 'Ming and Hwah are here.',
  'TTS Minh and Hoa format as Ming and Hwah',
);
assert(
  formatTextForTts('Mai is my friend.') === 'My is my friend.',
  'TTS Mai formats as My',
);
assert(
  formatTextForTts('Nguyen is travelling.') === 'Nwen is travelling.',
  'TTS Nguyen formats as Nwen',
);

// Vietnamese names wordsMatch
assert(wordsMatch('Linh', 'Lynn'), 'Linh matches Lynn');
assert(wordsMatch('linh', 'lin'), 'linh matches lin');
assert(wordsMatch('Minh', 'Ming'), 'Minh matches Ming');
assert(wordsMatch('Minh', 'Min'), 'Minh matches Min');
assert(wordsMatch('Minh', 'Minn'), 'Minh matches Minn');
assert(wordsMatch('min', 'MINH'), 'min matches MINH');
assert(wordsMatch('Hoa', 'Hua'), 'Hoa matches Hua');
assert(wordsMatch('Nguyen', 'Nwen'), 'Nguyen matches Nwen');

assert(wordsMatch('vietnam', 'vietnam'), 'vietnam matches vietnam');
const tVietSplit = tokenizeSentence("I'm from Viet Nam.");
const mVietOne = new Set();
matchAccumulating(wordsFromTranscript("I'm from Vietnam."), tVietSplit, mVietOne);
assert(mVietOne.has(2) && mVietOne.has(3), 'spoken Vietnam matches Viet Nam');
const tVietOne = tokenizeSentence("I'm from Vietnam.");
const mVietSplit = new Set();
matchAccumulating(wordsFromTranscript("I'm from Viet Nam."), tVietOne, mVietSplit);
assert(mVietSplit.has(2), 'spoken Viet Nam matches Vietnam');

// misread tracking
const misTokens = tokenizeSentence('I like apples.');
const misMatched = new Set();
const okRead = applyTranscript(wordsFromTranscript('I like'), misTokens, misMatched);
assert(okRead.newlyMatched.length === 2, 'partial read matches');
assert(!okRead.misreadFocus, 'partial read is not a misread');

const badRead = applyTranscript(wordsFromTranscript('banana'), misTokens, misMatched);
assert(badRead.newlyMatched.length === 0, 'wrong word does not match');
assert(badRead.misreadFocus, 'wrong word counts as misread focus');

assert(transcriptMatchesWord('please!', 'please'), 'remediation accepts punctuation');
assert(!needsPronunciationHelp(MISREAD_PRACTICE_THRESHOLD - 1), 'below threshold');
assert(needsPronunciationHelp(MISREAD_PRACTICE_THRESHOLD), 'at threshold');

// pronunciation accuracy
setPronunciationAccuracy(100);
assert(!wordsMatch('difficult', 'dificult'), '100% rejects close misspelling');

setPronunciationAccuracy(85);
assert(wordsMatch('difficult', 'dificult'), '85% accepts close misspelling');
assert(!wordsMatch('apples', 'banana'), '85% still rejects unrelated words');
assert(wordsMatch('beautiful', 'beautful'), '85% accepts beautful');

setPronunciationAccuracy(80);
assert(wordsMatch('environment', 'enviroment'), '80% accepts common misspelling');
assert(!wordsMatch('four', 'for'), '80% does not match four/for');

setPronunciationAccuracy(100);
assert(similarityPercent('abc', 'abc') === 100, 'identical strings are 100% similar');

console.log('matcher tests: ok');
