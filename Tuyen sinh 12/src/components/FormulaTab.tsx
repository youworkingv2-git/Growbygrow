import React, { useState } from 'react';
import { FORMULAS_DATA } from '../data/formulas';
import { BookMarked, Search, Sparkles, ChevronRight, Check } from 'lucide-react';
import { KaTeXMath } from './KaTeXMath';

export const FormulaTab: React.FC = () => {
  const [selectedSubject, setSelectedSubject] = useState<string>('Toán');
  const [searchTerm, setSearchTerm] = useState('');

  const subjects = ['Toán', 'Vật Lý', 'Hóa Học', 'Tiếng Anh'];

  const filteredFormulas = FORMULAS_DATA.filter((f) => {
    const matchesSubject = f.subject === selectedSubject;
    const matchesSearch =
      f.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      f.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
      f.description.toLowerCase().includes(searchTerm.toLowerCase());

    return matchesSubject && matchesSearch;
  });

  return (
    <div className="flex-1 overflow-y-auto pb-24 px-4 pt-4 space-y-4 animate-fade-in">
      <div>
        <h2 className="text-xl font-bold text-[var(--text-main)] flex items-center gap-2">
          Sổ Tay Công Thức 12 <BookMarked size={20} className="text-indigo-400" />
        </h2>
        <p className="text-xs text-[var(--text-muted)]">Tổng hợp công thức trọng tâm thi THPT QG & ĐGNL 2025+</p>
      </div>

      {/* Subject Tabs */}
      <div className="grid grid-cols-4 gap-2">
        {subjects.map((sub) => (
          <button
            key={sub}
            onClick={() => setSelectedSubject(sub)}
            className={`py-2 rounded-xl text-xs font-bold transition-all text-center ${
              selectedSubject === sub
                ? 'bg-[var(--accent-primary)] text-white shadow-lg shadow-indigo-500/20 scale-105'
                : 'bg-[var(--bg-card)] border border-[var(--border-color)] text-[var(--text-muted)]'
            }`}
          >
            {sub}
          </button>
        ))}
      </div>

      {/* Search Bar */}
      <div className="relative">
        <Search className="absolute left-3 top-3 text-[var(--text-muted)]" size={16} />
        <input
          type="text"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder={`Tìm công thức môn ${selectedSubject}...`}
          className="w-full bg-[var(--bg-card)] border border-[var(--border-color)] text-[var(--text-main)] text-xs rounded-xl pl-9 pr-4 py-2.5 focus:outline-none focus:border-[var(--accent-primary)]"
        />
      </div>

      {/* Formula Cards */}
      <div className="space-y-3">
        {filteredFormulas.length === 0 ? (
          <div className="text-center py-10 bg-[var(--bg-card)] border border-[var(--border-color)] rounded-xl">
            <p className="text-xs text-[var(--text-muted)]">Không tìm thấy công thức trùng khớp</p>
          </div>
        ) : (
          filteredFormulas.map((formula) => (
            <div
              key={formula.id}
              className="bg-[var(--bg-card)] border border-[var(--border-color)] p-4 rounded-xl space-y-2.5 shadow-sm"
            >
              <div className="flex justify-between items-center">
                <span className="text-[10px] font-extrabold uppercase tracking-wider bg-indigo-500/15 text-indigo-400 px-2.5 py-0.5 rounded border border-indigo-500/30">
                  {formula.category}
                </span>
                <span className="text-xs font-semibold text-[var(--text-muted)]">{formula.subject}</span>
              </div>

              <h3 className="font-bold text-sm text-[var(--text-main)]">{formula.title}</h3>

              {formula.latex && (
                <div className="bg-[var(--bg-primary)] p-3 rounded-lg border border-[var(--border-color)] text-center text-sm font-semibold overflow-x-auto my-1">
                  <KaTeXMath content={`$$${formula.latex}$$`} />
                </div>
              )}

              <p className="text-xs text-[var(--text-muted)] leading-relaxed">{formula.description}</p>

              {formula.keyNotes && formula.keyNotes.length > 0 && (
                <div className="pt-2 border-t border-[var(--border-color)] space-y-1">
                  <span className="text-[11px] font-bold text-amber-400 block">⚡ Ghi nhớ quan trọng:</span>
                  {formula.keyNotes.map((note, nIdx) => (
                    <div key={nIdx} className="text-xs text-[var(--text-main)] flex items-start gap-1.5">
                      <span className="text-emerald-400 font-bold mt-0.5">•</span>
                      <div>
                        <KaTeXMath content={note} />
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ))
        )}
      </div>
    </div>
  );
};
