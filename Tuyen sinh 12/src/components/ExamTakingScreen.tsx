import React, { useState, useEffect } from 'react';
import { Exam, Question, UserExamResult, TrueFalseStatement } from '../types/exam';
import { Clock, ArrowLeft, ArrowRight, Grid, Bookmark, Check, X, HelpCircle, AlertCircle, Send } from 'lucide-react';
import { KaTeXMath } from './KaTeXMath';

interface ExamTakingScreenProps {
  exam: Exam;
  mode: 'practice' | 'exam';
  onFinishExam: (result: UserExamResult, wrongQuestions: { question: Question; userAnswer: any }[]) => void;
  onBack: () => void;
}

export const ExamTakingScreen: React.FC<ExamTakingScreenProps> = ({
  exam,
  mode,
  onFinishExam,
  onBack,
}) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [userAnswers, setUserAnswers] = useState<Record<string, any>>({});
  const [bookmarkedIds, setBookmarkedIds] = useState<string[]>([]);
  const [showPalette, setShowPalette] = useState(false);
  const [secondsRemaining, setSecondsRemaining] = useState(exam.durationMinutes * 60);
  const [showInstantFeedback, setShowInstantFeedback] = useState<Record<string, boolean>>({});

  const currentQuestion = exam.questions[currentIndex];

  // Timer effect for exam mode
  useEffect(() => {
    if (mode !== 'exam') return;

    const timer = setInterval(() => {
      setSecondsRemaining((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          handleSubmitExam();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [mode]);

  const formatTime = (totalSec: number) => {
    const mins = Math.floor(totalSec / 60);
    const secs = totalSec % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleSelectSingleChoice = (optionIndex: number) => {
    setUserAnswers((prev) => ({
      ...prev,
      [currentQuestion.id]: optionIndex,
    }));
  };

  const handleTrueFalseToggle = (statementId: string, val: boolean) => {
    const prevTF = userAnswers[currentQuestion.id] || {};
    setUserAnswers((prev) => ({
      ...prev,
      [currentQuestion.id]: {
        ...prevTF,
        [statementId]: val,
      },
    }));
  };

  const handleShortAnswerChange = (val: string) => {
    setUserAnswers((prev) => ({
      ...prev,
      [currentQuestion.id]: val,
    }));
  };

  const toggleBookmark = () => {
    setBookmarkedIds((prev) =>
      prev.includes(currentQuestion.id)
        ? prev.filter((id) => id !== currentQuestion.id)
        : [...prev, currentQuestion.id]
    );
  };

  const toggleCheckAnswer = () => {
    setShowInstantFeedback((prev) => ({
      ...prev,
      [currentQuestion.id]: !prev[currentQuestion.id],
    }));
  };

  const handleSubmitExam = () => {
    // Calculate score
    let correctCount = 0;
    let wrongCount = 0;
    const wrongQuestionsList: { question: Question; userAnswer: any }[] = [];

    exam.questions.forEach((q) => {
      const ans = userAnswers[q.id];
      let isCorrect = false;

      if (q.type === 'single-choice' || q.type === 'passage-comprehension') {
        if (ans !== undefined && ans === q.correctAnswer) {
          isCorrect = true;
        }
      } else if (q.type === 'short-answer') {
        if (ans !== undefined && String(ans).trim().toLowerCase() === String(q.correctAnswer).trim().toLowerCase()) {
          isCorrect = true;
        }
      } else if (q.type === 'true-false') {
        // All 4 TF statements must match for 100% point or proportional
        if (ans && q.tfStatements) {
          const allMatch = q.tfStatements.every(
            (st) => ans[st.id] !== undefined && ans[st.id] === st.isTrue
          );
          if (allMatch) isCorrect = true;
        }
      }

      if (isCorrect) {
        correctCount++;
      } else {
        wrongCount++;
        wrongQuestionsList.push({ question: q, userAnswer: ans });
      }
    });

    const maxScore = 10;
    const rawScore = Number(((correctCount / exam.questions.length) * maxScore).toFixed(1));
    const timeSpent = exam.durationMinutes * 60 - secondsRemaining;

    const result: UserExamResult = {
      id: `result-${Date.now()}`,
      examId: exam.id,
      examTitle: exam.title,
      category: exam.category,
      subject: exam.subject,
      completedAt: new Date().toLocaleDateString('vi-VN'),
      score: rawScore,
      maxScore: 10,
      timeSpentSeconds: timeSpent > 0 ? timeSpent : 30,
      userAnswers,
      correctCount,
      wrongCount,
      totalQuestions: exam.questions.length,
    };

    onFinishExam(result, wrongQuestionsList);
  };

  return (
    <div className="flex-1 flex flex-col h-full bg-[var(--bg-primary)] z-50 animate-fade-in relative overflow-hidden">
      {/* Top Header */}
      <div className="h-14 bg-[var(--bg-card)] border-b border-[var(--border-color)] px-4 flex items-center justify-between">
        <button
          onClick={onBack}
          className="p-2 rounded-lg text-[var(--text-muted)] hover:text-[var(--text-main)] hover:bg-[var(--bg-card-hover)] transition-colors"
        >
          <ArrowLeft size={20} />
        </button>

        <div className="text-center">
          <span className="text-xs font-bold text-[var(--accent-primary)] uppercase tracking-wider block">
            {mode === 'practice' ? 'Chế Độ Luyện Tập' : 'Thi Thử Tính Giờ'}
          </span>
          <span className="text-xs text-[var(--text-muted)] truncate max-w-[180px] inline-block">
            {exam.title}
          </span>
        </div>

        <div className="flex items-center space-x-2">
          {mode === 'exam' && (
            <div className="flex items-center space-x-1.5 bg-rose-500/15 border border-rose-500/30 text-rose-400 font-extrabold text-xs px-2.5 py-1 rounded-full">
              <Clock size={14} className="animate-pulse" />
              <span>{formatTime(secondsRemaining)}</span>
            </div>
          )}
          <button
            onClick={() => setShowPalette(!showPalette)}
            className="p-2 rounded-lg text-[var(--text-main)] bg-[var(--bg-primary)] border border-[var(--border-color)]"
            title="Danh sách câu hỏi"
          >
            <Grid size={18} />
          </button>
        </div>
      </div>

      {/* Main Question Body */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 pb-28">
        {/* Progress Bar & Question Meta */}
        <div className="flex justify-between items-center text-xs text-[var(--text-muted)]">
          <span className="font-semibold text-[var(--text-main)]">
            Câu {currentIndex + 1} / {exam.questions.length}
          </span>
          <div className="flex items-center space-x-2">
            <span className="bg-indigo-500/15 text-indigo-400 px-2 py-0.5 rounded text-[11px] font-semibold border border-indigo-500/30">
              {currentQuestion.subject} - {currentQuestion.topic}
            </span>
            <button
              onClick={toggleBookmark}
              className={`p-1.5 rounded transition-colors ${
                bookmarkedIds.includes(currentQuestion.id)
                  ? 'text-amber-400 bg-amber-400/20'
                  : 'text-[var(--text-muted)] hover:text-amber-400'
              }`}
            >
              <Bookmark size={16} fill={bookmarkedIds.includes(currentQuestion.id) ? 'currentColor' : 'none'} />
            </button>
          </div>
        </div>

        {/* Question Reading Passage if any (ĐGNL) */}
        {currentQuestion.passage && (
          <div className="bg-[var(--bg-card)] border border-[var(--border-color)] p-3.5 rounded-xl text-xs leading-relaxed text-[var(--text-main)] bg-indigo-950/20">
            <span className="text-[11px] font-bold text-cyan-400 block mb-1 uppercase tracking-wider">
              📖 Đọc hiểu văn bản:
            </span>
            {currentQuestion.passage}
          </div>
        )}

        {/* Question Content */}
        <div className="bg-[var(--bg-card)] border border-[var(--border-color)] p-4 rounded-xl shadow-sm text-sm text-[var(--text-main)] leading-relaxed">
          <KaTeXMath content={currentQuestion.content} />
        </div>

        {/* Options / Inputs based on Question Type */}
        <div className="space-y-2.5">
          {/* SINGLE CHOICE / PASSAGE COMPREHENSION */}
          {(currentQuestion.type === 'single-choice' || currentQuestion.type === 'passage-comprehension') &&
            currentQuestion.options?.map((opt, idx) => {
              const letters = ['A', 'B', 'C', 'D'];
              const isSelected = userAnswers[currentQuestion.id] === idx;
              const isFeedback = showInstantFeedback[currentQuestion.id];
              const isCorrectOpt = currentQuestion.correctAnswer === idx;

              let btnStyle = 'bg-[var(--bg-card)] border-[var(--border-color)] text-[var(--text-main)] hover:border-indigo-500/40';
              let badgeStyle = 'bg-[var(--bg-primary)] border-[var(--border-color)] text-[var(--text-muted)]';

              if (isSelected) {
                btnStyle = 'bg-gradient-to-r from-indigo-500/30 to-indigo-600/20 border-indigo-500 text-white font-bold ring-2 ring-indigo-500/50 shadow-md shadow-indigo-500/20 scale-[1.01]';
                badgeStyle = 'bg-indigo-500 text-white border-indigo-400 font-extrabold shadow-md shadow-indigo-500/50 scale-110';
              }

              if (isFeedback) {
                if (isCorrectOpt) {
                  btnStyle = 'bg-emerald-500/25 border-emerald-500 text-emerald-200 font-bold ring-2 ring-emerald-500/50';
                  badgeStyle = 'bg-emerald-500 text-white border-emerald-400 font-extrabold';
                } else if (isSelected && !isCorrectOpt) {
                  btnStyle = 'bg-rose-500/25 border-rose-500 text-rose-500 font-bold ring-2 ring-rose-500/50';
                  badgeStyle = 'bg-rose-500 text-white border-rose-400 font-extrabold';
                }
              }

              return (
                <button
                  key={idx}
                  onClick={() => handleSelectSingleChoice(idx)}
                  className={`w-full text-left p-3.5 rounded-xl border flex items-center justify-between space-x-3 transition-all ${btnStyle}`}
                >
                  <div className="flex items-start space-x-3 min-w-0 flex-1">
                    <span className={`w-7 h-7 rounded-full border text-xs flex items-center justify-center font-bold shrink-0 transition-transform ${badgeStyle}`}>
                      {letters[idx]}
                    </span>
                    <div className="flex-1 text-xs pt-1">
                      <KaTeXMath content={opt} />
                    </div>
                  </div>
                  {isSelected && !isFeedback && (
                    <span className="w-5 h-5 rounded-full bg-indigo-500 text-white flex items-center justify-center text-[10px] font-black shrink-0 shadow-sm animate-fade-in">
                      ✓
                    </span>
                  )}
                </button>
              );
            })}

          {/* TRUE / FALSE (4 STATEMENTS) */}
          {currentQuestion.type === 'true-false' && currentQuestion.tfStatements && (
            <div className="space-y-3">
              <span className="text-xs text-[var(--text-muted)] font-medium">
                Chọn Đúng hoặc Sai cho mỗi ý a), b), c), d):
              </span>
              {currentQuestion.tfStatements.map((st) => {
                const currentVal = userAnswers[currentQuestion.id]?.[st.id];
                const isAnswered = currentVal !== undefined;

                return (
                  <div
                    key={st.id}
                    className={`bg-[var(--bg-card)] border p-3 rounded-xl flex flex-col space-y-2 transition-all ${
                      isAnswered ? 'border-indigo-500/50 bg-indigo-500/5' : 'border-[var(--border-color)]'
                    }`}
                  >
                    <div className="text-xs text-[var(--text-main)]">
                      <KaTeXMath content={st.statement} />
                    </div>
                    <div className="flex gap-2 justify-end">
                      <button
                        onClick={() => handleTrueFalseToggle(st.id, true)}
                        className={`px-4 py-1.5 rounded-lg text-xs font-bold transition-all flex items-center gap-1 ${
                          currentVal === true
                            ? 'bg-emerald-500 text-white shadow-md ring-2 ring-emerald-400/50 font-extrabold scale-105'
                            : 'bg-[var(--bg-primary)] border border-[var(--border-color)] text-[var(--text-muted)] hover:text-emerald-400'
                        }`}
                      >
                        {currentVal === true && <span>✓</span>}
                        ĐÚNG
                      </button>
                      <button
                        onClick={() => handleTrueFalseToggle(st.id, false)}
                        className={`px-4 py-1.5 rounded-lg text-xs font-bold transition-all flex items-center gap-1 ${
                          currentVal === false
                            ? 'bg-rose-500 text-white shadow-md ring-2 ring-rose-400/50 font-extrabold scale-105'
                            : 'bg-[var(--bg-primary)] border border-[var(--border-color)] text-[var(--text-muted)] hover:text-rose-400'
                        }`}
                      >
                        {currentVal === false && <span>✓</span>}
                        SAI
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          {/* SHORT ANSWER */}
          {currentQuestion.type === 'short-answer' && (
            <div className={`bg-[var(--bg-card)] border p-4 rounded-xl space-y-2 transition-all ${
              userAnswers[currentQuestion.id] ? 'border-indigo-500 bg-indigo-500/5 ring-1 ring-indigo-500/30' : 'border-[var(--border-color)]'
            }`}>
              <div className="flex justify-between items-center">
                <label className="text-xs font-semibold text-[var(--text-main)] block">
                  Điền đáp án số hoặc kết quả ngắn:
                </label>
                {userAnswers[currentQuestion.id] && (
                  <span className="text-[10px] font-bold text-emerald-400 bg-emerald-500/15 border border-emerald-500/30 px-2 py-0.5 rounded-full flex items-center gap-1">
                    ✓ Đã chọn đáp án
                  </span>
                )}
              </div>
              <input
                type="text"
                value={userAnswers[currentQuestion.id] || ''}
                onChange={(e) => handleShortAnswerChange(e.target.value)}
                placeholder="Nhập giá trị (ví dụ: 4 hoặc 10)..."
                className="w-full bg-[var(--bg-primary)] border border-[var(--border-color)] text-[var(--text-main)] font-bold text-sm rounded-lg p-3 focus:outline-none focus:border-indigo-500 transition-colors"
              />
            </div>
          )}
        </div>

        {/* Practice Mode Instant Feedback Toggle & Explanation */}
        {mode === 'practice' && (
          <div className="mt-4 pt-2">
            <button
              onClick={toggleCheckAnswer}
              className="w-full py-2.5 rounded-xl border border-indigo-500/40 bg-indigo-500/10 text-indigo-400 text-xs font-bold flex items-center justify-center gap-1.5 hover:bg-indigo-500/20 transition-colors"
            >
              <HelpCircle size={16} />
              {showInstantFeedback[currentQuestion.id] ? 'Ẩn Lời Giải Chi Tiết' : 'Xem Lời Giải & Đáp Án Ngay'}
            </button>

            {showInstantFeedback[currentQuestion.id] && (
              <div className="mt-3 bg-emerald-950/20 border border-emerald-500/30 p-3.5 rounded-xl space-y-2 animate-fade-in">
                <span className="text-xs font-bold text-emerald-400 block">
                  ✅ Lời giải chi tiết:
                </span>
                <div className="text-xs text-[var(--text-main)] leading-relaxed">
                  <KaTeXMath content={currentQuestion.explanation} />
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Question Palette Drawer Sheet */}
      {showPalette && (
        <div className="absolute inset-0 bg-black/60 backdrop-blur-sm z-50 flex flex-col justify-end animate-fade-in">
          <div className="bg-[var(--bg-card)] border-t border-[var(--border-color)] rounded-t-3xl p-4 max-h-[70vh] flex flex-col space-y-3">
            <div className="flex justify-between items-center pb-2 border-b border-[var(--border-color)]">
              <h4 className="font-bold text-sm text-[var(--text-main)]">Danh Sách Câu Hỏi</h4>
              <button
                onClick={() => setShowPalette(false)}
                className="text-[var(--text-muted)] p-1 hover:text-[var(--text-main)]"
              >
                <X size={20} />
              </button>
            </div>

            <div className="grid grid-cols-5 gap-2.5 overflow-y-auto p-1">
              {exam.questions.map((q, idx) => {
                const isAnswered = userAnswers[q.id] !== undefined;
                const isCurrent = idx === currentIndex;
                const isBookmarked = bookmarkedIds.includes(q.id);

                return (
                  <button
                    key={q.id}
                    onClick={() => {
                      setCurrentIndex(idx);
                      setShowPalette(false);
                    }}
                    className={`h-11 rounded-xl font-bold text-xs flex flex-col items-center justify-center relative border transition-all ${
                      isCurrent
                        ? 'border-[var(--accent-primary)] ring-2 ring-[var(--accent-primary)] text-indigo-400 bg-indigo-500/20'
                        : isAnswered
                        ? 'bg-emerald-500/20 text-emerald-300 border-emerald-500/40'
                        : 'bg-[var(--bg-primary)] border-[var(--border-color)] text-[var(--text-muted)]'
                    }`}
                  >
                    <span>{idx + 1}</span>
                    {isBookmarked && (
                      <span className="w-1.5 h-1.5 bg-amber-400 rounded-full absolute top-1 right-1"></span>
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* Bottom Bar Controls */}
      <div className="absolute bottom-0 left-0 right-0 h-16 bg-[var(--bg-card)] border-t border-[var(--border-color)] px-4 flex items-center justify-between z-40">
        <button
          disabled={currentIndex === 0}
          onClick={() => setCurrentIndex((prev) => prev - 1)}
          className="px-4 py-2 rounded-xl text-xs font-semibold bg-[var(--bg-primary)] border border-[var(--border-color)] text-[var(--text-main)] disabled:opacity-40 flex items-center gap-1"
        >
          <ArrowLeft size={16} /> Câu Trước
        </button>

        <button
          onClick={handleSubmitExam}
          className="px-4 py-2 rounded-xl text-xs font-extrabold bg-gradient-to-r from-emerald-500 to-teal-600 text-white shadow-lg shadow-emerald-500/20 flex items-center gap-1.5"
        >
          <Send size={15} /> Nộp Bài
        </button>

        <button
          disabled={currentIndex === exam.questions.length - 1}
          onClick={() => setCurrentIndex((prev) => prev + 1)}
          className="px-4 py-2 rounded-xl text-xs font-semibold bg-[var(--accent-primary)] text-white disabled:opacity-40 flex items-center gap-1"
        >
          Câu Tiếp <ArrowRight size={16} />
        </button>
      </div>
    </div>
  );
};
