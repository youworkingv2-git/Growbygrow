import React, { useState } from 'react';
import { Exam, ExamCategory } from '../types/exam';
import { Search, Filter, Clock, BookOpen, ChevronRight, Sparkles, CheckCircle2 } from 'lucide-react';

interface ExamsTabProps {
  exams: Exam[];
  onSelectExam: (exam: Exam, mode: 'practice' | 'exam') => void;
  completedExamIds: string[];
}

export const ExamsTab: React.FC<ExamsTabProps> = ({ exams, onSelectExam, completedExamIds }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<ExamCategory | 'ALL'>('ALL');
  const [selectedSubject, setSelectedSubject] = useState<string>('ALL');

  const categories: { id: ExamCategory | 'ALL'; name: string }[] = [
    { id: 'ALL', name: 'Tất cả đề' },
    { id: 'THPT_QG_2025', name: 'THPT QG 2025' },
    { id: 'DGNL_HCM', name: 'ĐGNL TP.HCM' },
    { id: 'HSA_HN', name: 'HSA Hà Nội' },
    { id: 'TSA_HUST', name: 'TSA Bách Khoa' },
  ];

  const subjects = ['ALL', 'Toán', 'Tiếng Anh', 'Vật Lý', 'Tổng hợp ĐGNL'];

  const filteredExams = exams.filter((exam) => {
    const matchesSearch =
      exam.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      exam.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
      exam.tags.some((t) => t.toLowerCase().includes(searchTerm.toLowerCase()));

    const matchesCategory = selectedCategory === 'ALL' || exam.category === selectedCategory;
    const matchesSubject = selectedSubject === 'ALL' || exam.subject === selectedSubject;

    return matchesSearch && matchesCategory && matchesSubject;
  });

  return (
    <div className="flex-1 overflow-y-auto pb-24 px-3.5 pt-3.5 space-y-3.5 animate-fade-in">
      <div>
        <h2 className="text-base font-bold text-[var(--text-main)]">Kho Đề Thi Chuẩn 2025+</h2>
        <p className="text-[11px] text-[var(--text-muted)]">Lựa chọn đề thi thử THPT QG hoặc Đánh Giá Năng Lực</p>
      </div>

      {/* Search Input */}
      <div className="relative">
        <Search className="absolute left-3 top-2.5 text-[var(--text-muted)]" size={16} />
        <input
          type="text"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Tìm tên đề, môn học hoặc từ khóa..."
          className="w-full bg-[var(--bg-card)] border border-[var(--border-color)] text-[var(--text-main)] text-xs rounded-xl pl-9 pr-3 py-2 focus:outline-none focus:border-[var(--accent-primary)] transition-colors"
        />
      </div>

      {/* Category Horizontal Filter Pills */}
      <div className="flex gap-1.5 overflow-x-auto no-scrollbar py-0.5">
        {categories.map((cat) => (
          <button
            key={cat.id}
            onClick={() => setSelectedCategory(cat.id)}
            className={`whitespace-nowrap px-3 py-1 rounded-full text-[11px] font-semibold transition-all ${
              selectedCategory === cat.id
                ? 'bg-[var(--accent-primary)] text-white shadow-sm shadow-indigo-500/20 scale-105'
                : 'bg-[var(--bg-card)] border border-[var(--border-color)] text-[var(--text-muted)] hover:text-[var(--text-main)]'
            }`}
          >
            {cat.name}
          </button>
        ))}
      </div>

      {/* Subject Filter Pills */}
      <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar">
        <span className="text-[11px] text-[var(--text-muted)] font-medium shrink-0">Môn:</span>
        {subjects.map((sub) => (
          <button
            key={sub}
            onClick={() => setSelectedSubject(sub)}
            className={`px-2.5 py-0.5 rounded-lg text-[11px] font-medium whitespace-nowrap transition-colors ${
              selectedSubject === sub
                ? 'bg-indigo-500/20 text-indigo-400 border border-indigo-500/40'
                : 'bg-[var(--bg-card)] border border-[var(--border-color)] text-[var(--text-muted)]'
            }`}
          >
            {sub === 'ALL' ? 'Tất cả' : sub}
          </button>
        ))}
      </div>

      {/* Exam List */}
      <div className="space-y-2.5 pt-1">
        {filteredExams.length === 0 ? (
          <div className="text-center py-10 bg-[var(--bg-card)] border border-[var(--border-color)] rounded-xl">
            <BookOpen size={36} className="mx-auto text-[var(--text-muted)] mb-2 opacity-50" />
            <p className="text-xs font-semibold text-[var(--text-main)]">Không tìm thấy đề thi phù hợp</p>
            <p className="text-[11px] text-[var(--text-muted)] mt-1">Thử thay đổi từ khóa hoặc bộ lọc danh mục.</p>
          </div>
        ) : (
          filteredExams.map((exam) => {
            const isCompleted = completedExamIds.includes(exam.id);
            return (
              <div
                key={exam.id}
                className="bg-[var(--bg-card)] border border-[var(--border-color)] hover:border-[var(--accent-primary)] p-3.5 rounded-xl transition-all shadow-sm relative overflow-hidden"
              >
                {isCompleted && (
                  <div className="absolute top-0 right-0 bg-emerald-500 text-white text-[9px] font-bold px-2.5 py-0.5 rounded-bl-lg flex items-center gap-1">
                    <CheckCircle2 size={11} /> Đã làm
                  </div>
                )}

                <div className="flex items-center gap-2 mb-1.5 flex-wrap">
                  <span className="text-[10px] font-bold text-cyan-400 bg-cyan-500/10 border border-cyan-500/30 px-2 py-0.5 rounded-full">
                    {exam.subject}
                  </span>
                  <span className="text-[11px] text-[var(--text-muted)] flex items-center gap-1">
                    <Clock size={12} /> {exam.durationMinutes} phút
                  </span>
                  <span className="text-[11px] text-[var(--text-muted)]">
                    • {exam.totalQuestions} câu
                  </span>
                </div>

                <h3 className="font-bold text-xs sm:text-sm text-[var(--text-main)] mb-1">
                  {exam.title}
                </h3>
                <p className="text-[11px] text-[var(--text-muted)] line-clamp-2 mb-2.5 leading-relaxed">
                  {exam.description}
                </p>

                <div className="flex items-center justify-between pt-2 border-t border-[var(--border-color)] gap-2">
                  <div className="flex gap-1 flex-wrap min-w-0">
                    {exam.tags.map((t, i) => (
                      <span key={i} className="text-[9px] bg-[var(--bg-primary)] px-1.5 py-0.5 rounded text-[var(--text-muted)] truncate">
                        #{t}
                      </span>
                    ))}
                  </div>

                  <div className="flex gap-1.5 shrink-0">
                    <button
                      onClick={() => onSelectExam(exam, 'practice')}
                      className="px-2.5 py-1 rounded-lg text-[11px] font-medium bg-emerald-500/15 text-emerald-400 hover:bg-emerald-500/25 border border-emerald-500/30 transition-colors"
                    >
                      Luyện Tập
                    </button>
                    <button
                      onClick={() => onSelectExam(exam, 'exam')}
                      className="px-2.5 py-1 rounded-lg text-[11px] font-medium bg-[var(--accent-primary)] text-white hover:opacity-90 transition-opacity shadow-sm shadow-indigo-500/20"
                    >
                      Thi Thử
                    </button>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};
