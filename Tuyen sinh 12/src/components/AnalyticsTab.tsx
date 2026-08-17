import React from 'react';
import { UserExamResult } from '../types/exam';
import { BarChart3, Award, TrendingUp, Zap, HelpCircle, AlertCircle } from 'lucide-react';

interface AnalyticsTabProps {
  examResults: UserExamResult[];
  streakCount: number;
}

interface SubjectTrack {
  name: string;
  keys: string[]; // Match keywords in exam.subject or exam.examTitle
  icon: string;
  color: string;
}

export const AnalyticsTab: React.FC<AnalyticsTabProps> = ({ examResults, streakCount }) => {
  const totalExams = examResults.length;
  const totalCorrect = examResults.reduce((acc, r) => acc + r.correctCount, 0);
  const totalQuestions = examResults.reduce((acc, r) => acc + r.totalQuestions, 0);
  const avgAccuracy = totalQuestions > 0 ? Math.round((totalCorrect / totalQuestions) * 100) : null;

  // List of subject areas to analyze
  const trackedSubjects: SubjectTrack[] = [
    { name: 'Toán Học & Giải Tích', keys: ['toán', 'math'], icon: '📐', color: 'bg-indigo-500' },
    { name: 'Tiếng Anh & Đọc Hiểu', keys: ['tiếng anh', 'anh', 'english'], icon: '🌐', color: 'bg-emerald-500' },
    { name: 'Vật Lý & Khoa Học Tự Nhiên', keys: ['vật lý', 'lý', 'phần 3', 'khtn'], icon: '⚡', color: 'bg-rose-500' },
    { name: 'Tư Duy Logic & Phân Tích Số Liệu', keys: ['đgnl', 'hsa', 'tsa', 'tổng hợp', 'logic'], icon: '🧠', color: 'bg-cyan-500' },
    { name: 'Ngữ Văn & Ngôn Ngữ', keys: ['ngữ văn', 'văn', 'tiếng việt'], icon: '📖', color: 'bg-purple-500' },
    { name: 'Hóa Học & Sinh Học', keys: ['hóa', 'sinh'], icon: '🧪', color: 'bg-amber-500' },
  ];

  // Calculate dynamic skill percentage for each subject
  const skillsData = trackedSubjects.map((sub) => {
    // Find all exam results matching this subject
    const matchingResults = examResults.filter((r) => {
      const subjectLower = r.subject.toLowerCase();
      const titleLower = r.examTitle.toLowerCase();
      return sub.keys.some((k) => subjectLower.includes(k) || titleLower.includes(k));
    });

    const subQuestions = matchingResults.reduce((acc, r) => acc + r.totalQuestions, 0);
    const subCorrect = matchingResults.reduce((acc, r) => acc + r.correctCount, 0);
    const subExamsCount = matchingResults.length;

    const accuracy = subQuestions > 0 ? Math.round((subCorrect / subQuestions) * 100) : null;

    return {
      name: sub.name,
      icon: sub.icon,
      color: sub.color,
      accuracy,
      subQuestions,
      subCorrect,
      subExamsCount,
    };
  });

  // Calculate NV1 prediction dynamically
  const predictedScoreRatio = avgAccuracy !== null ? avgAccuracy : null;
  const estimatedDGNLScore = predictedScoreRatio !== null ? Math.round((predictedScoreRatio / 100) * 1200) : null;
  const estimatedTHPTScore = predictedScoreRatio !== null ? (predictedScoreRatio / 10).toFixed(1) : null;

  return (
    <div className="flex-1 overflow-y-auto pb-24 px-3.5 pt-3.5 space-y-4 animate-fade-in">
      <div>
        <h2 className="text-base font-bold text-[var(--text-main)] flex items-center gap-2">
          Phân Tích Năng Lực Sĩ Tử <BarChart3 size={18} className="text-cyan-400" />
        </h2>
        <p className="text-[11px] text-[var(--text-muted)]">Đánh giá theo đúng kết quả thi thực tế của bạn</p>
      </div>

      {/* Hero Overview Grid */}
      <div className="grid grid-cols-2 gap-2.5">
        <div className="bg-[var(--bg-card)] border border-[var(--border-color)] p-3.5 rounded-2xl space-y-1 shadow-sm">
          <div className="flex justify-between items-center text-[var(--text-muted)] text-[11px]">
            <span>Tỷ Lệ Đúng</span>
            <TrendingUp size={15} className="text-emerald-400" />
          </div>
          <span className="text-2xl font-black text-emerald-400">
            {avgAccuracy !== null ? `${avgAccuracy}%` : '--'}
          </span>
          <p className="text-[10px] text-[var(--text-muted)] truncate">
            {totalQuestions > 0 ? `Dựa trên ${totalQuestions} câu đã giải` : 'Chưa có bài thi nào'}
          </p>
        </div>

        <div className="bg-[var(--bg-card)] border border-[var(--border-color)] p-3.5 rounded-2xl space-y-1 shadow-sm">
          <div className="flex justify-between items-center text-[var(--text-muted)] text-[11px]">
            <span>Số Đề Đã Giải</span>
            <Award size={15} className="text-amber-400" />
          </div>
          <span className="text-2xl font-black text-[var(--text-main)]">{totalExams} Đề</span>
          <p className="text-[10px] text-[var(--text-muted)] truncate">Streak: 🔥 {streakCount} ngày</p>
        </div>
      </div>

      {/* Admission Prediction Banner */}
      <div className="gradient-card-cyan p-3.5 rounded-2xl shadow-md relative overflow-hidden">
        <div className="flex items-center space-x-3">
          <div className="w-11 h-11 rounded-xl bg-white/20 backdrop-blur-md flex items-center justify-center font-black text-base text-white shrink-0">
            {predictedScoreRatio !== null ? `${Math.min(99, Math.max(30, Math.round(predictedScoreRatio * 0.95)))}%` : '--'}
          </div>
          <div className="min-w-0 flex-1">
            <h3 className="font-extrabold text-xs text-white truncate">Dự Đoán Cơ Hội Đỗ NV1</h3>
            <p className="text-[11px] text-cyan-100 mt-0.5 leading-tight">
              {predictedScoreRatio !== null
                ? `Ước tính: ${estimatedTHPTScore}/10 điểm THPT | ${estimatedDGNLScore}/1200 ĐGNL`
                : 'Chưa có dữ liệu. Hãy thi thử ít nhất 1 đề để hệ thống đánh giá cơ hội trúng tuyển.'}
            </p>
          </div>
        </div>
      </div>

      {/* Skill Bar Breakdown */}
      <div className="bg-[var(--bg-card)] border border-[var(--border-color)] p-3.5 rounded-2xl space-y-3 shadow-sm">
        <div className="flex justify-between items-center">
          <h3 className="font-bold text-xs text-[var(--text-main)] flex items-center gap-1.5 uppercase tracking-wider">
            <Zap size={15} className="text-amber-400" /> Phân Tích Kỹ Năng Theo Phân Môn
          </h3>
        </div>

        <div className="space-y-3 pt-1">
          {skillsData.map((item, idx) => (
            <div key={idx} className="space-y-1">
              <div className="flex justify-between items-center text-xs font-semibold text-[var(--text-main)]">
                <span className="flex items-center gap-1.5 text-[11px]">
                  <span>{item.icon}</span>
                  <span>{item.name}</span>
                </span>
                {item.accuracy !== null ? (
                  <span className="text-[11px] font-bold text-emerald-400">{item.accuracy}%</span>
                ) : (
                  <span className="text-[10px] text-[var(--text-muted)] bg-[var(--bg-primary)] px-2 py-0.5 rounded border border-[var(--border-color)]">
                    Chưa có dữ liệu
                  </span>
                )}
              </div>

              {/* Progress Track */}
              <div className="w-full h-2 bg-[var(--bg-primary)] rounded-full overflow-hidden border border-[var(--border-color)]">
                {item.accuracy !== null ? (
                  <div
                    className={`h-full ${item.color} rounded-full transition-all duration-500`}
                    style={{ width: `${item.accuracy}%` }}
                  ></div>
                ) : (
                  <div className="h-full w-0 bg-gray-600/30"></div>
                )}
              </div>

              <div className="text-[9px] text-[var(--text-muted)] flex justify-between pt-0.5">
                {item.accuracy !== null ? (
                  <span>Đã thi {item.subExamsCount} bài ({item.subCorrect}/{item.subQuestions} câu đúng)</span>
                ) : (
                  <span>Chưa làm bài thi nào thuộc phân môn này</span>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Exam History */}
      <div className="bg-[var(--bg-card)] border border-[var(--border-color)] p-3.5 rounded-2xl space-y-3 shadow-sm">
        <h3 className="font-bold text-xs text-[var(--text-main)] uppercase tracking-wider">Lịch Sử Thi Gần Đây</h3>

        {examResults.length === 0 ? (
          <div className="text-center py-6 border border-dashed border-[var(--border-color)] rounded-xl">
            <HelpCircle size={28} className="mx-auto text-[var(--text-muted)] opacity-40 mb-1" />
            <p className="text-xs font-semibold text-[var(--text-main)]">Chưa có bài thi nào</p>
            <p className="text-[10px] text-[var(--text-muted)] mt-0.5">Hãy chọn 1 đề thi thử trong "Kho Đề Thi" để bắt đầu!</p>
          </div>
        ) : (
          <div className="space-y-2">
            {examResults.map((r) => (
              <div key={r.id} className="bg-[var(--bg-primary)] p-2.5 rounded-xl border border-[var(--border-color)] flex justify-between items-center text-xs">
                <div className="min-w-0 flex-1 pr-2">
                  <h4 className="font-bold text-[var(--text-main)] text-[11px] truncate">{r.examTitle}</h4>
                  <span className="text-[10px] text-[var(--text-muted)]">{r.completedAt}</span>
                </div>
                <div className="text-right shrink-0">
                  <span className="text-xs font-black text-emerald-400 block">{r.score} điểm</span>
                  <span className="text-[9px] text-[var(--text-muted)] block">
                    Đúng {r.correctCount}/{r.totalQuestions} câu
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
