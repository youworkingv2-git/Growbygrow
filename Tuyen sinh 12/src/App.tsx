import React, { useState, useEffect } from 'react';
import { MOCK_EXAMS } from './data/mockExams';
import { Exam, Question, UserExamResult, MistakeItem } from './types/exam';
import { MobileContainer } from './components/MobileContainer';
import { BottomNav, TabType } from './components/BottomNav';
import { HomeTab } from './components/HomeTab';
import { ExamsTab } from './components/ExamsTab';
import { ExamTakingScreen } from './components/ExamTakingScreen';
import { ExamResultScreen } from './components/ExamResultScreen';
import { MistakesTab } from './components/MistakesTab';
import { FormulaTab } from './components/FormulaTab';
import { AnalyticsTab } from './components/AnalyticsTab';

export function App() {
  const [activeTab, setActiveTab] = useState<TabType>('home');
  const [currentView, setCurrentView] = useState<'tab' | 'taking' | 'result'>('tab');
  const [selectedExam, setSelectedExam] = useState<Exam | null>(null);
  const [examMode, setExamMode] = useState<'practice' | 'exam'>('practice');
  const [lastExamResult, setLastExamResult] = useState<UserExamResult | null>(null);
  const [isDarkMode, setIsDarkMode] = useState(true);

  // LocalStorage state
  const [mistakes, setMistakes] = useState<MistakeItem[]>(() => {
    try {
      const saved = localStorage.getItem('tuyen_sinh_mistakes');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  const [examResultsHistory, setExamResultsHistory] = useState<UserExamResult[]>(() => {
    try {
      const saved = localStorage.getItem('tuyen_sinh_history');
      return saved ? JSON.parse(saved) : [];
    } catch {
      return [];
    }
  });

  const [streakCount, setStreakCount] = useState<number>(() => {
    try {
      const saved = localStorage.getItem('tuyen_sinh_streak');
      return saved ? Number(saved) : 7;
    } catch {
      return 7;
    }
  });

  // Sync state to local storage
  useEffect(() => {
    localStorage.setItem('tuyen_sinh_mistakes', JSON.stringify(mistakes));
  }, [mistakes]);

  useEffect(() => {
    localStorage.setItem('tuyen_sinh_history', JSON.stringify(examResultsHistory));
  }, [examResultsHistory]);

  const handleSelectExam = (exam: Exam, mode: 'practice' | 'exam') => {
    setSelectedExam(exam);
    setExamMode(mode);
    setCurrentView('taking');
  };

  const handleFinishExam = (
    result: UserExamResult,
    wrongQuestions: { question: Question; userAnswer: any }[]
  ) => {
    setLastExamResult(result);
    setExamResultsHistory((prev) => [result, ...prev]);

    // Save wrong questions to mistake vault automatically
    if (wrongQuestions.length > 0 && selectedExam) {
      setMistakes((prev) => {
        const existingIds = new Set(prev.map((m) => m.question.id));
        const newMistakes: MistakeItem[] = wrongQuestions
          .filter((w) => !existingIds.has(w.question.id))
          .map((w) => ({
            question: w.question,
            examId: selectedExam.id,
            examTitle: selectedExam.title,
            userAnswer: w.userAnswer,
            savedAt: new Date().toLocaleDateString('vi-VN'),
            reviewed: false,
          }));
        return [...newMistakes, ...prev];
      });
    }

    setCurrentView('result');
  };

  const handleRemoveMistake = (questionId: string) => {
    setMistakes((prev) => prev.filter((m) => m.question.id !== questionId));
  };

  const handleClearAllMistakes = () => {
    setMistakes([]);
  };

  const completedExamIds = Array.from(new Set(examResultsHistory.map((r) => r.examId)));

  return (
    <MobileContainer isDarkMode={isDarkMode}>
      {/* Main Container Router */}
      {currentView === 'tab' && (
        <>
          {activeTab === 'home' && (
            <HomeTab
              exams={MOCK_EXAMS}
              onSelectExam={handleSelectExam}
              streakCount={streakCount}
              completedExamsCount={completedExamIds.length}
              mistakeCount={mistakes.length}
              isDarkMode={isDarkMode}
              setIsDarkMode={setIsDarkMode}
              onOpenExams={() => setActiveTab('exams')}
              onOpenFormulas={() => setActiveTab('formulas')}
              onOpenMistakes={() => setActiveTab('mistakes')}
              onOpenAnalytics={() => setActiveTab('analytics')}
            />
          )}

          {activeTab === 'exams' && (
            <ExamsTab
              exams={MOCK_EXAMS}
              onSelectExam={handleSelectExam}
              completedExamIds={completedExamIds}
            />
          )}

          {activeTab === 'mistakes' && (
            <MistakesTab
              mistakes={mistakes}
              onRemoveMistake={handleRemoveMistake}
              onClearAllMistakes={handleClearAllMistakes}
            />
          )}

          {activeTab === 'formulas' && <FormulaTab />}

          {activeTab === 'analytics' && (
            <AnalyticsTab examResults={examResultsHistory} streakCount={streakCount} />
          )}

          <BottomNav
            activeTab={activeTab}
            setActiveTab={setActiveTab}
            mistakeCount={mistakes.length}
          />
        </>
      )}

      {currentView === 'taking' && selectedExam && (
        <ExamTakingScreen
          exam={selectedExam}
          mode={examMode}
          onFinishExam={handleFinishExam}
          onBack={() => setCurrentView('tab')}
        />
      )}

      {currentView === 'result' && lastExamResult && selectedExam && (
        <ExamResultScreen
          result={lastExamResult}
          exam={selectedExam}
          onReviewMistakes={() => {
            setCurrentView('tab');
            setActiveTab('mistakes');
          }}
          onGoHome={() => {
            setCurrentView('tab');
            setActiveTab('home');
          }}
          onRetakeExam={() => {
            setCurrentView('taking');
          }}
        />
      )}
    </MobileContainer>
  );
}

export default App;
