import React, { useState } from 'react';
import { Smartphone, Monitor } from 'lucide-react';

interface MobileContainerProps {
  children: React.ReactNode;
  isDarkMode: boolean;
}

export const MobileContainer: React.FC<MobileContainerProps> = ({ children, isDarkMode }) => {
  const [isPhoneFrame, setIsPhoneFrame] = useState(true);

  return (
    <div className={`mobile-app-wrapper ${isDarkMode ? '' : 'light-theme'}`}>
      {/* Desktop Mode Toggle Button */}
      <button
        onClick={() => setIsPhoneFrame(!isPhoneFrame)}
        className="fixed top-4 right-4 hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[var(--bg-card)] border border-[var(--border-color)] text-xs text-[var(--text-main)] hover:bg-[var(--bg-card-hover)] transition-all z-50 shadow-lg"
      >
        {isPhoneFrame ? <Monitor size={14} /> : <Smartphone size={14} />}
        <span>{isPhoneFrame ? 'Chế độ Tràn Màn Hình' : 'Chế độ Khung Điện Thoại'}</span>
      </button>

      <div className={`phone-container ${!isPhoneFrame ? '!max-w-none !h-screen !rounded-none !border-none' : ''}`}>
        {children}
      </div>
    </div>
  );
};
