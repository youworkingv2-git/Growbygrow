import React, { useState } from 'react';
import { MistakeItem } from '../types/exam';
import { AlertTriangle, CheckCircle2, Trash2, RotateCcw, HelpCircle, BookOpen, Sparkles } from 'lucide-react';
import { KaTeXMath } from './KaTeXMath';

interface MistakesTabProps {
  mistakes: MistakeItem[];
  onRemoveMistake: (questionId: string) => void;
  onClearAllMistakes: () => void;
}

export const MistakesTab: React.FC<MistakesTabProps> = ({ mistakes, onRemoveMistake, onClearAllMistakes }) => {
  const [selectedSubject, setSelectedSubject] = useState<string>('ALL');
  const [revealedIds, setRevealedIds] = useState<Record<string, boolean>>({});

  const subjects = ['ALL', ...Array.from(new Set(mistakes.map((m) => m.question.subject)))];

  const filteredMistakes = mistakes.filter(
    (m) => selectedSubject === 'ALL' || m.question.subject === selectedSubject
  );

  const toggleReveal = (id: string) => {
    setRevealedIds((prev) => ({ ...prev, [id]: !prev[id] }));
  };

  return (
    <div className="flex-1 overflow-y-auto pb-24 px-4 pt-4 space-y-4 animate-fade-in">
      <div className="flex justify-between items-start">
        <div>
          <h2 className="text-xl font-bold text-[var(--text-main)] flex items-center gap-2">
            Sổ Tay Câu Sai <AlertTriangle size={20} className="text-amber-400" />
          </h2>
          <p className="text-xs text-[var(--text-muted)]">Tự động lưu các câu làm sai để ôn lại đến khi thành thạo</p>
        </div>

        {mistakes.length > 0 && (
          <button
            onClick={onClearAllMistakes}
            className="text-xs text-rose-400 hover:underline flex items-center gap-1 pt-1"
          >
            <Trash2 size={13} /> Xóa tất cả
          </button>
        )}
      </div>

      {/* Subject filter */}
      {mistakes.length > 0 && (
        <div className="flex gap-2 overflow-x-auto no-scrollbar">
          {subjects.map((sub) => (
            <button
              key={sub}
              onClick={() => setSelectedSubject(sub)}
              className={`px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap transition-colors ${
                selectedSubject === sub
                  ? 'bg-amber-500/20 text-amber-400 border border-amber-500/40'
                  : 'bg-[var(--bg-card)] border border-[var(--border-color)] text-[var(--text-muted)]'
              }`}
            >
              {sub === 'ALL' ? `Tất cả (${mistakes.length})` : sub}
            </button>
          ))}
        </div>
      )}

      {/* Mistake Items list */}
      {filteredMistakes.length === 0 ? (
        <div className="text-center py-16 bg-[var(--bg-card)] border border-[var(--border-color)] rounded-2xl">
          <CheckCircle2 size={48} className="mx-auto text-emerald-400 mb-2 opacity-80 animate-pulse" />
          <h3 className="text-base font-bold text-[var(--text-main)]">Sổ tay sạch bóng!</h3>
          <p className="text-xs text-[var(--text-muted)] mt-1 px-6">
            Bạn chưa có câu làm sai nào trong danh mục này. Hãy tiếp tục làm bài thi để rèn luyện nhé!
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {filteredMistakes.map((item, idx) => {
            const q = item.question;
            const isRevealed = revealedIds[q.id];

            return (
              <div
                key={q.id}
                className="bg-[var(--bg-card)] border border-amber-500/30 p-4 rounded-xl space-y-3 shadow-sm relative"
              >
                <div className="flex justify-between items-start">
                  <div className="flex items-center space-x-2">
                    <span className="text-[10px] font-extrabold bg-amber-500/20 text-amber-400 px-2 py-0.5 rounded border border-amber-500/30">
                      {q.subject}
                    </span>
                    <span className="text-xs text-[var(--text-muted)] truncate max-w-[160px]">
                      {item.examTitle}
                    </span>
                  </div>

                  <button
                    onClick={() => onRemoveMistake(q.id)}
                    className="p-1 text-[var(--text-muted)] hover:text-emerald-400 transition-colors"
                    title="Đã hiểu - Xóa khỏi sổ tay"
                  >
                    <CheckCircle2 size={18} />
                  </button>
                </div>

                <div className="text-xs text-[var(--text-main)] leading-relaxed bg-[var(--bg-primary)] p-3 rounded-lg border border-[var(--border-color)]">
                  <KaTeXMath content={q.content} />
                </div>

                <div className="flex justify-between items-center pt-1">
                  <button
                    onClick={() => toggleReveal(q.id)}
                    className="text-xs font-bold text-[var(--accent-primary)] hover:underline flex items-center gap-1"
                  >
                    <HelpCircle size={14} />
                    {isRevealed ? 'Ẩn Lời Giải' : 'Hiện Lời Giải & Đáp Án'}
                  </button>

                  <button
                    onClick={() => onRemoveMistake(q.id)}
                    className="px-3 py-1 rounded-lg bg-emerald-500/15 text-emerald-400 text-xs font-semibold hover:bg-emerald-500/25 border border-emerald-500/30"
                  >
                    Đã Thuộc ✅
                  </button>
                </div>

                {isRevealed && (
                  <div className="mt-2 bg-emerald-950/20 border border-emerald-500/30 p-3 rounded-lg text-xs text-emerald-200 leading-relaxed animate-fade-in">
                    <span className="font-bold text-emerald-400 block mb-1">📘 Lời giải chi tiết:</span>
                    <KaTeXMath content={q.explanation} />
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};
