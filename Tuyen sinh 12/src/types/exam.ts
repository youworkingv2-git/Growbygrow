export type ExamCategory = 'THPT_QG_2025' | 'DGNL_HCM' | 'HSA_HN' | 'TSA_HUST';

export type QuestionType = 'single-choice' | 'true-false' | 'short-answer' | 'passage-comprehension';

export type Difficulty = 'Dễ' | 'Trung bình' | 'Vận dụng' | 'Vận dụng cao';

export interface TrueFalseStatement {
  id: string;
  statement: string;
  isTrue: boolean;
  explanation?: string;
}

export interface Question {
  id: string;
  type: QuestionType;
  content: string; // Markdown / KaTeX format
  image?: string;
  passage?: string; // Đoạn văn cho ĐGNL
  options?: string[]; // Cho single-choice (A, B, C, D)
  correctAnswer?: number | string; // Index 0-3 cho single choice, hoặc string/number cho short answer
  tfStatements?: TrueFalseStatement[]; // Cho true-false 4 ý
  explanation: string;
  subject: string;
  topic: string;
  difficulty: Difficulty;
}

export interface Exam {
  id: string;
  title: string;
  category: ExamCategory;
  subject: string;
  year: number;
  durationMinutes: number;
  totalQuestions: number;
  questions: Question[];
  description: string;
  tags: string[];
}

export interface UserExamResult {
  id: string;
  examId: string;
  examTitle: string;
  category: ExamCategory;
  subject: string;
  completedAt: string;
  score: number;
  maxScore: number;
  timeSpentSeconds: number;
  userAnswers: Record<string, any>;
  correctCount: number;
  wrongCount: number;
  totalQuestions: number;
}

export interface MistakeItem {
  question: Question;
  examId: string;
  examTitle: string;
  userAnswer: any;
  savedAt: string;
  reviewed: boolean;
}

export interface FormulaTopic {
  id: string;
  subject: 'Toán' | 'Vật Lý' | 'Hóa Học' | 'Tiếng Anh';
  category: string;
  title: string;
  latex?: string;
  description: string;
  examples?: string[];
  keyNotes?: string[];
}
