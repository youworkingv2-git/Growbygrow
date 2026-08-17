import React from 'react';
import { Exam, ExamCategory } from '../types/exam';
import {
  Flame,
  Zap,
  BookOpen,
  Sparkles,
  Moon,
  Sun,
  BookMarked,
  BarChart3,
  ChevronRight,
  Clock
} from 'lucide-react';

interface HomeTabProps {
  exams: Exam[];
  onSelectExam: (exam: Exam, mode: 'practice' | 'exam') => void;
  streakCount: number;
  completedExamsCount: number;
  mistakeCount: number;
  isDarkMode: boolean;
  setIsDarkMode: (val: boolean | ((prev: boolean) => boolean)) => void;
  onOpenExams: () => void;
  onOpenFormulas: () => void;
  onOpenMistakes: () => void;
  onOpenAnalytics: () => void;
}

export const HomeTab: React.FC<HomeTabProps> = ({
  exams,
  onSelectExam,
  streakCount,
  completedExamsCount,
  mistakeCount,
  isDarkMode,
  setIsDarkMode,
  onOpenExams,
  onOpenFormulas,
  onOpenMistakes,
  onOpenAnalytics,
}) => {
  const categories: { id: ExamCategory; name: string; icon: string; color: string }[] = [
    { id: 'THPT_QG_2025', name: 'THPT QG 2025', icon: '🏛️', color: 'from-indigo-500/20 to-indigo-600/10 text-indigo-400 border-indigo-500/30' },
    { id: 'DGNL_HCM', name: 'ĐGNL TP.HCM', icon: '🔷', color: 'from-cyan-500/20 to-cyan-600/10 text-cyan-400 border-cyan-500/30' },
    { id: 'HSA_HN', name: 'HSA Hà Nội', icon: '🔶', color: 'from-amber-500/20 to-amber-600/10 text-amber-400 border-amber-500/30' },
    { id: 'TSA_HUST', name: 'TSA Bách Khoa', icon: '🔴', color: 'from-rose-500/20 to-rose-600/10 text-rose-400 border-rose-500/30' },
  ];

  return (
    <div className="flex-1 overflow-y-auto pb-24 px-3.5 pt-3.5 space-y-4 animate-fade-in">
      {/* Top Profile Header */}
      <div className="flex items-center justify-between gap-2">
        <div className="flex items-center space-x-2.5 min-w-0">
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-indigo-500 to-cyan-400 flex items-center justify-center font-bold text-white shadow-md shadow-indigo-500/25 text-xs shrink-0">
            2K7
          </div>
          <div className="min-w-0 flex-1">
            <h2 className="text-base font-bold tracking-tight text-[var(--text-main)] truncate">
              Chào Sĩ Tử!
            </h2>
            <div className="flex items-center gap-1.5 text-[11px] text-amber-400 font-semibold">
              <Flame size={13} className="fill-amber-400 stroke-amber-400" />
              <span>{streakCount} ngày liên tục</span>
            </div>
          </div>
        </div>

        <button
          onClick={() => setIsDarkMode((prev) => !prev)}
          className="w-9 h-9 rounded-xl bg-[var(--bg-card)] border border-[var(--border-color)] flex items-center justify-center text-[var(--text-main)] hover:bg-[var(--bg-card-hover)] transition-colors shrink-0"
          title="Đổi giao diện"
        >
          {isDarkMode ? <Sun size={17} className="text-amber-400" /> : <Moon size={17} className="text-indigo-600" />}
        </button>
      </div>

      {/* Main Feature Grid (2x2) */}
      <div>
        <div className="flex justify-between items-center mb-2 px-0.5">
          <span className="text-xs font-bold text-[var(--text-muted)] uppercase tracking-wider">Mục Chính</span>
        </div>
        <div className="grid grid-cols-2 gap-2.5">
          {/* Card 1: Kho Đề Thi */}
          <button
            onClick={onOpenExams}
            className="bg-[var(--bg-card)] border border-[var(--border-color)] hover:border-indigo-500/50 p-3.5 rounded-2xl flex flex-col justify-between items-start text-left group transition-all relative overflow-hidden shadow-sm"
          >
            <div className="w-10 h-10 rounded-xl bg-indigo-500/15 text-indigo-400 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
              <BookOpen size={20} />
            </div>
            <div>
              <div className="flex items-center gap-1">
                <span className="text-xs font-bold text-[var(--text-main)]">Kho Đề Thi</span>
                <ChevronRight size={13} className="text-[var(--text-muted)] group-hover:translate-x-0.5 transition-transform" />
              </div>
              <span className="text-[10px] text-[var(--text-muted)] block mt-0.5">Tất cả môn & đề</span>
            </div>
          </button>

          {/* Card 2: Sổ Câu Sai */}
          <button
            onClick={onOpenMistakes}
            className="bg-[var(--bg-card)] border border-[var(--border-color)] hover:border-amber-500/50 p-3.5 rounded-2xl flex flex-col justify-between items-start text-left group transition-all relative overflow-hidden shadow-sm"
          >
            <div className="w-10 h-10 rounded-xl bg-amber-500/15 text-amber-400 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform relative">
              <Zap size={20} />
              {mistakeCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-amber-500 text-black text-[9px] font-black px-1.5 rounded-full">
                  {mistakeCount}
                </span>
              )}
            </div>
            <div>
              <div className="flex items-center gap-1">
                <span className="text-xs font-bold text-[var(--text-main)]">Sổ Câu Sai</span>
                <ChevronRight size={13} className="text-[var(--text-muted)] group-hover:translate-x-0.5 transition-transform" />
              </div>
              <span className="text-[10px] text-amber-400 font-medium block mt-0.5">{mistakeCount} câu cần ôn</span>
            </div>
          </button>

          {/* Card 3: Tra Công Thức */}
          <button
            onClick={onOpenFormulas}
            className="bg-[var(--bg-card)] border border-[var(--border-color)] hover:border-cyan-500/50 p-3.5 rounded-2xl flex flex-col justify-between items-start text-left group transition-all relative overflow-hidden shadow-sm"
          >
            <div className="w-10 h-10 rounded-xl bg-cyan-500/15 text-cyan-400 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
              <BookMarked size={20} />
            </div>
            <div>
              <div className="flex items-center gap-1">
                <span className="text-xs font-bold text-[var(--text-main)]">Tra Công Thức</span>
                <ChevronRight size={13} className="text-[var(--text-muted)] group-hover:translate-x-0.5 transition-transform" />
              </div>
              <span className="text-[10px] text-[var(--text-muted)] block mt-0.5">Toán, Lý, Hóa, Anh</span>
            </div>
          </button>

          {/* Card 4: Thống Kê */}
          <button
            onClick={onOpenAnalytics}
            className="bg-[var(--bg-card)] border border-[var(--border-color)] hover:border-emerald-500/50 p-3.5 rounded-2xl flex flex-col justify-between items-start text-left group transition-all relative overflow-hidden shadow-sm"
          >
            <div className="w-10 h-10 rounded-xl bg-emerald-500/15 text-emerald-400 flex items-center justify-center mb-3 group-hover:scale-110 transition-transform">
              <BarChart3 size={20} />
            </div>
            <div>
              <div className="flex items-center gap-1">
                <span className="text-xs font-bold text-[var(--text-main)]">Thống Kê Tiến Độ</span>
                <ChevronRight size={13} className="text-[var(--text-muted)] group-hover:translate-x-0.5 transition-transform" />
              </div>
              <span className="text-[10px] text-emerald-400 font-medium block mt-0.5">Đã giải {completedExamsCount} đề</span>
            </div>
          </button>
        </div>
      </div>

      {/* Exam Categories Grid (2x2) */}
      <div>
        <div className="flex justify-between items-center mb-2 px-0.5">
          <span className="text-xs font-bold text-[var(--text-muted)] uppercase tracking-wider">Danh Mục Kỳ Thi</span>
          <button onClick={onOpenExams} className="text-[11px] text-[var(--accent-primary)] font-medium hover:underline">
            Xem tất cả
          </button>
        </div>

        <div className="grid grid-cols-2 gap-2">
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={onOpenExams}
              className={`bg-gradient-to-r ${cat.color} border p-3 rounded-xl flex items-center justify-between group hover:scale-[1.02] transition-all`}
            >
              <div className="flex items-center space-x-2 min-w-0">
                <span className="text-base">{cat.icon}</span>
                <span className="text-xs font-bold truncate">{cat.name}</span>
              </div>
              <ChevronRight size={14} className="opacity-60 group-hover:opacity-100 group-hover:translate-x-0.5 transition-all shrink-0" />
            </button>
          ))}
        </div>
      </div>

      {/* Featured Quick Exam Start */}
      {exams.length > 0 && (
        <div>
          <div className="flex justify-between items-center mb-2 px-0.5">
            <span className="text-xs font-bold text-[var(--text-muted)] uppercase tracking-wider flex items-center gap-1">
              <Sparkles size={13} className="text-amber-400" /> Đề Thi Mới Nhất
            </span>
          </div>

          <div className="bg-[var(--bg-card)] border border-[var(--border-color)] p-3.5 rounded-2xl flex items-center justify-between gap-3 shadow-sm">
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-1.5 mb-1">
                <span className="text-[10px] font-bold text-cyan-400 bg-cyan-500/10 px-2 py-0.5 rounded-full border border-cyan-500/20">
                  {exams[0].subject}
                </span>
                <span className="text-[10px] text-[var(--text-muted)] flex items-center gap-0.5">
                  <Clock size={11} /> {exams[0].durationMinutes} phút
                </span>
              </div>
              <h4 className="font-bold text-xs text-[var(--text-main)] truncate">
                {exams[0].title}
              </h4>
            </div>

            <div className="flex gap-1.5 shrink-0">
              <button
                onClick={() => onSelectExam(exams[0], 'practice')}
                className="px-2.5 py-1.5 rounded-xl text-xs font-semibold bg-emerald-500/15 text-emerald-400 hover:bg-emerald-500/25 border border-emerald-500/30 transition-colors"
              >
                Luyện Tập
              </button>
              <button
                onClick={() => onSelectExam(exams[0], 'exam')}
                className="px-2.5 py-1.5 rounded-xl text-xs font-semibold bg-[var(--accent-primary)] text-white hover:opacity-90 transition-opacity shadow-md shadow-indigo-500/20"
              >
                Thi Thử
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
