import React, { useState } from 'react';
import { UserExamResult, Exam } from '../types/exam';
import { Award, Clock, CheckCircle2, XCircle, AlertCircle, RotateCcw, Home, ChevronDown, ChevronUp } from 'lucide-react';
import { KaTeXMath } from './KaTeXMath';

interface ExamResultScreenProps {
  result: UserExamResult;
  exam: Exam;
  onReviewMistakes: () => void;
  onGoHome: () => void;
  onRetakeExam: () => void;
}

export const ExamResultScreen: React.FC<ExamResultScreenProps> = ({
  result,
  exam,
  onReviewMistakes,
  onGoHome,
  onRetakeExam,
}) => {
  const [expandedIndex, setExpandedIndex] = useState<number | null>(null);

  const formatTime = (totalSec: number) => {
    const mins = Math.floor(totalSec / 60);
    const secs = totalSec % 60;
    return `${mins} phút ${secs} giây`;
  };

  const getGradeEvaluation = (score: number) => {
    if (score >= 9) return { title: 'Xuất Sắc! 🌟', subtitle: 'Khả năng đạt Thủ Khoa / Nguyện vọng 1 rất cao!', color: 'text-amber-400' };
    if (score >= 8) return { title: 'Giỏi! 🚀', subtitle: 'Phong độ tốt, duy trì để đỗ Top Trường Đại học!', color: 'text-emerald-400' };
    if (score >= 6.5) return { title: 'Khá! 💪', subtitle: 'Cần ôn thêm các câu Vận Dụng Cao trong Sổ Tay.', color: 'text-cyan-400' };
    return { title: 'Cố Gắng Lên! 📚', subtitle: 'Hãy ôn lại lý thuyết và làm lại các câu sai nhé!', color: 'text-rose-400' };
  };

  const evalInfo = getGradeEvaluation(result.score);

  return (
    <div className="flex-1 overflow-y-auto p-4 space-y-4 pb-24 animate-fade-in bg-[var(--bg-primary)]">
      {/* Result Hero Banner */}
      <div className="bg-[var(--bg-card)] border border-[var(--border-color)] p-5 rounded-2xl text-center space-y-3 relative overflow-hidden shadow-lg">
        <div className="w-20 h-20 mx-auto rounded-full bg-gradient-to-tr from-indigo-500 to-cyan-400 flex items-center justify-center text-white shadow-xl shadow-indigo-500/30">
          <span className="text-3xl font-black">{result.score}</span>
        </div>

        <div>
          <h2 className={`text-xl font-extrabold ${evalInfo.color}`}>{evalInfo.title}</h2>
          <p className="text-xs text-[var(--text-muted)] mt-0.5">{evalInfo.subtitle}</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-3 gap-2 pt-3 border-t border-[var(--border-color)] text-center">
          <div className="bg-[var(--bg-primary)] p-2 rounded-xl border border-[var(--border-color)]">
            <span className="text-xs text-[var(--text-muted)] block">Thời gian</span>
            <span className="text-xs font-bold text-[var(--text-main)] flex items-center justify-center gap-1 mt-0.5">
              <Clock size={12} /> {formatTime(result.timeSpentSeconds)}
            </span>
          </div>

          <div className="bg-emerald-500/10 border border-emerald-500/30 p-2 rounded-xl">
            <span className="text-xs text-emerald-400 block">Đúng</span>
            <span className="text-sm font-extrabold text-emerald-400">
              {result.correctCount} / {result.totalQuestions}
            </span>
          </div>

          <div className="bg-rose-500/10 border border-rose-500/30 p-2 rounded-xl">
            <span className="text-xs text-rose-400 block">Sai / Bỏ qua</span>
            <span className="text-sm font-extrabold text-rose-400">
              {result.wrongCount}
            </span>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="grid grid-cols-2 gap-2.5">
        <button
          onClick={onReviewMistakes}
          className="py-3 px-4 rounded-xl bg-amber-500/15 border border-amber-500/30 text-amber-400 font-bold text-xs flex items-center justify-center gap-1.5 hover:bg-amber-500/25 transition-colors"
        >
          <AlertCircle size={16} /> Luyện Sổ Câu Sai ({result.wrongCount})
        </button>

        <button
          onClick={onRetakeExam}
          className="py-3 px-4 rounded-xl bg-[var(--bg-card)] border border-[var(--border-color)] text-[var(--text-main)] font-bold text-xs flex items-center justify-center gap-1.5 hover:bg-[var(--bg-card-hover)] transition-colors"
        >
          <RotateCcw size={16} /> Làm Lại Đề Thi
        </button>
      </div>

      {/* Detailed Question Review List */}
      <div>
        <h3 className="font-bold text-sm text-[var(--text-main)] mb-2 flex items-center justify-between">
          <span>Chi Tiết Từng Câu Hỏi</span>
          <span className="text-xs font-normal text-[var(--text-muted)]">Bấm vào câu để xem đáp án</span>
        </h3>

        <div className="space-y-2">
          {exam.questions.map((q, idx) => {
            const userAns = result.userAnswers[q.id];
            const isExpanded = expandedIndex === idx;

            let isCorrect = false;
            if (q.type === 'single-choice' || q.type === 'passage-comprehension') {
              isCorrect = userAns === q.correctAnswer;
            } else if (q.type === 'short-answer') {
              isCorrect = String(userAns || '').trim().toLowerCase() === String(q.correctAnswer || '').trim().toLowerCase();
            } else if (q.type === 'true-false' && q.tfStatements) {
              isCorrect = q.tfStatements.every((st) => userAns && userAns[st.id] === st.isTrue);
            }

            return (
              <div
                key={q.id}
                className={`bg-[var(--bg-card)] border rounded-xl overflow-hidden transition-all ${
                  isCorrect ? 'border-emerald-500/30' : 'border-rose-500/30'
                }`}
              >
                <button
                  onClick={() => setExpandedIndex(isExpanded ? null : idx)}
                  className="w-full p-3 flex items-center justify-between text-left"
                >
                  <div className="flex items-center space-x-2.5 pr-2">
                    {isCorrect ? (
                      <CheckCircle2 size={18} className="text-emerald-400 flex-shrink-0" />
                    ) : (
                      <XCircle size={18} className="text-rose-400 flex-shrink-0" />
                    )}
                    <span className="text-xs font-semibold text-[var(--text-main)]">
                      Câu {idx + 1}: <span className="text-[var(--text-muted)] font-normal line-clamp-1">{q.content.replace(/\$|\$\$/g, '')}</span>
                    </span>
                  </div>

                  {isExpanded ? <ChevronUp size={16} className="text-[var(--text-muted)]" /> : <ChevronDown size={16} className="text-[var(--text-muted)]" />}
                </button>

                {isExpanded && (
                  <div className="p-3.5 pt-2.5 border-t border-[var(--border-color)] bg-[var(--bg-primary)] space-y-2 text-xs animate-fade-in">
                    <div className="p-2.5 rounded-lg bg-[var(--bg-card)] border border-[var(--border-color)] space-y-1">
                      <div className="flex justify-between items-center">
                        <span className="text-[var(--text-muted)]">Đáp án của bạn:</span>
                        <span className={isCorrect ? 'text-emerald-400 font-bold' : 'text-rose-400 font-bold'}>
                          {userAns !== undefined ? (typeof userAns === 'object' ? 'Đã điền ý Đúng/Sai' : String(userAns)) : 'Chưa trả lời'}
                        </span>
                      </div>
                      {!isCorrect && (
                        <div className="flex justify-between items-center pt-1 border-t border-[var(--border-color)]/50">
                          <span className="text-[var(--text-muted)]">Đáp án chuẩn:</span>
                          <span className="text-emerald-400 font-bold">
                            {q.type === 'single-choice' && q.options ? ['A', 'B', 'C', 'D'][Number(q.correctAnswer)] : String(q.correctAnswer || 'Xem hướng dẫn')}
                          </span>
                        </div>
                      )}
                    </div>

                    <div className="p-3 rounded-lg bg-emerald-950/20 border border-emerald-500/30 text-emerald-200 leading-relaxed">
                      <span className="font-bold text-emerald-400 block mb-1">📘 Hướng dẫn giải:</span>
                      <KaTeXMath content={q.explanation} />
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      <button
        onClick={onGoHome}
        className="w-full py-3.5 rounded-xl bg-[var(--accent-primary)] text-white font-extrabold text-xs shadow-lg shadow-indigo-500/20 flex items-center justify-center gap-1.5"
      >
        <Home size={16} /> Trở Về Trang Chủ
      </button>
    </div>
  );
};
