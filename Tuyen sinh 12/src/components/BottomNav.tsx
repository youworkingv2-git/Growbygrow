import React from 'react';
import { Home, BookOpen, AlertTriangle, BookMarked, BarChart3 } from 'lucide-react';

export type TabType = 'home' | 'exams' | 'mistakes' | 'formulas' | 'analytics';

interface BottomNavProps {
  activeTab: TabType;
  setActiveTab: (tab: TabType) => void;
  mistakeCount: number;
}

export const BottomNav: React.FC<BottomNavProps> = ({ activeTab, setActiveTab, mistakeCount }) => {
  const tabs = [
    { id: 'home' as TabType, label: 'Trang chủ', icon: Home },
    { id: 'exams' as TabType, label: 'Đề thi', icon: BookOpen },
    { id: 'mistakes' as TabType, label: 'Câu sai', icon: AlertTriangle, badge: mistakeCount > 0 ? mistakeCount : undefined },
    { id: 'formulas' as TabType, label: 'Công thức', icon: BookMarked },
    { id: 'analytics' as TabType, label: 'Thống kê', icon: BarChart3 },
  ];

  return (
    <nav className="absolute bottom-0 left-0 right-0 h-16 bg-[var(--bg-card)] border-t border-[var(--border-color)] flex items-center justify-around z-40 px-2 backdrop-blur-md">
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const isActive = activeTab === tab.id;
        return (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex flex-col items-center justify-center flex-1 py-1 relative transition-all duration-200 min-w-0 ${
              isActive ? 'text-[var(--accent-primary)] font-semibold scale-105' : 'text-[var(--text-muted)] hover:text-[var(--text-main)]'
            }`}
          >
            <div className="relative">
              <Icon size={19} className={isActive ? 'stroke-[2.5px]' : 'stroke-[1.8px]'} />
              {tab.badge && (
                <span className="absolute -top-1.5 -right-2.5 bg-rose-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full animate-bounce">
                  {tab.badge > 99 ? '99+' : tab.badge}
                </span>
              )}
            </div>
            <span className="text-[10px] mt-0.5 tracking-tighter truncate max-w-full">{tab.label}</span>
            {isActive && (
              <span className="absolute bottom-0 w-7 h-1 bg-[var(--accent-primary)] rounded-t-full"></span>
            )}
          </button>
        );
      })}
    </nav>
  );
};
