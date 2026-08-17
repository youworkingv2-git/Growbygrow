import { useMemo, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import {
  ArrowLeft,
  BookOpen,
  Layers,
  RefreshCw,
  X,
} from 'lucide-react'
import {
  kindMeta,
  type ContextBranch,
  type ContextLeaf,
  type ContextMapResult,
} from '../data/contextMap'

interface Props {
  map: ContextMapResult
  onBack: () => void
  onReview: () => void
  onRegenerate: () => void
}

export function ContextMindmapScreen({ map, onBack, onReview, onRegenerate }: Props) {
  const [openBranch, setOpenBranch] = useState<string | null>('vocab')
  const [activeLeaf, setActiveLeaf] = useState<{
    branch: ContextBranch
    leaf: ContextLeaf
  } | null>(null)

  const branchById = useMemo(
    () => Object.fromEntries(map.branches.map((b) => [b.id, b])),
    [map.branches],
  )

  const visibleLeaves = openBranch ? branchById[openBranch]?.leaves ?? [] : []

  return (
    <div className="relative h-full overflow-hidden bg-gradient-to-b from-[#0c3d4a] via-[#145566] to-[#eef6f2] pb-24">
      <header className="relative z-20 flex items-start gap-2 px-4 pt-12 text-white">
        <button
          type="button"
          onClick={onBack}
          className="mt-0.5 flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-white/15"
        >
          <ArrowLeft size={18} />
        </button>
        <div className="min-w-0 flex-1">
          <p className="text-[10px] font-bold uppercase tracking-wider text-[#ffc94a]">
            ③ Mindmap ngữ cảnh · {map.cefr}
          </p>
          <h1 className="truncate font-display text-xl leading-tight">{map.root.title}</h1>
          <p className="line-clamp-2 text-xs text-white/70">{map.mainIdea}</p>
        </div>
        <button
          type="button"
          onClick={onRegenerate}
          className="mt-0.5 flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-white/15"
        >
          <RefreshCw size={16} />
        </button>
      </header>

      {/* 4-branch legend */}
      <div className="relative z-20 mx-3 mt-2 flex gap-1 overflow-x-auto phone-scroll pb-1">
        {[
          { id: 'idea', emoji: '🎯', label: 'Main Idea' },
          { id: 'vocab', emoji: '💎', label: 'Keywords' },
          { id: 'grammar', emoji: '📐', label: 'Grammar' },
          { id: 'idiom', emoji: '🪄', label: 'Idioms' },
        ].map((b) => (
          <button
            key={b.id}
            type="button"
            onClick={() => setOpenBranch(b.id)}
            className={`flex shrink-0 items-center gap-1 rounded-full px-2.5 py-1 text-[10px] font-bold ${
              openBranch === b.id
                ? 'bg-[#ffc94a] text-[var(--ink)]'
                : 'bg-white/15 text-white'
            }`}
          >
            <span>{b.emoji}</span>
            {b.label}
          </button>
        ))}
      </div>

      {/* Mindmap canvas */}
      <div className="relative mx-3 mt-3 h-[42%] overflow-hidden rounded-[1.5rem] border border-white/20 bg-white/10 shadow-inner backdrop-blur-sm">
        <svg className="absolute inset-0 h-full w-full" aria-hidden>
          {map.branches
            .filter((b) => b.kind !== 'idea')
            .map((b) => (
              <line
                key={b.id}
                x1="50%"
                y1="22%"
                x2={`${b.x}%`}
                y2={`${b.y}%`}
                stroke={b.color}
                strokeWidth="2.5"
                strokeLinecap="round"
                opacity={openBranch === b.id ? 0.95 : 0.45}
                className="dotted-path"
              />
            ))}
        </svg>

        {/* Root */}
        <button
          type="button"
          onClick={() => {
            const idea = map.branches.find((b) => b.kind === 'idea')
            if (idea?.leaves[0]) setActiveLeaf({ branch: idea, leaf: idea.leaves[0] })
            setOpenBranch('idea')
          }}
          className="absolute left-1/2 top-[18%] z-10 flex w-[130px] -translate-x-1/2 -translate-y-1/2 flex-col items-center"
        >
          <div
            className="flex h-[68px] w-[68px] items-center justify-center rounded-full text-2xl shadow-lg ring-4 ring-white/30"
            style={{ background: map.root.color }}
          >
            🎯
          </div>
          <span className="mt-1 rounded-full bg-white/90 px-2 py-0.5 text-center font-display text-[11px] text-[var(--ink)]">
            Main Idea
          </span>
        </button>

        {map.branches
          .filter((b) => b.kind !== 'idea')
          .map((b) => {
            const on = openBranch === b.id
            return (
              <motion.button
                key={b.id}
                type="button"
                onClick={() => setOpenBranch(on ? null : b.id)}
                className="absolute z-10 flex -translate-x-1/2 -translate-y-1/2 flex-col items-center"
                style={{ left: `${b.x}%`, top: `${b.y}%` }}
                animate={{ scale: on ? 1.08 : 1 }}
              >
                <div
                  className={`flex h-14 w-14 items-center justify-center rounded-2xl text-xl shadow-md ${
                    on ? 'ring-2 ring-white' : ''
                  }`}
                  style={{ background: b.color }}
                >
                  {b.icon}
                </div>
                <span className="mt-1 max-w-[86px] rounded-full bg-white/90 px-1.5 py-0.5 text-center font-display text-[10px] text-[var(--ink)]">
                  {b.title}
                </span>
                <span className="mt-0.5 rounded-full bg-black/35 px-1.5 text-[9px] font-bold text-white">
                  {b.leaves.length}
                </span>
              </motion.button>
            )
          })}
      </div>

      {/* Branch detail list */}
      <div className="relative z-10 mx-3 mt-3 max-h-[28%] overflow-y-auto phone-scroll rounded-[1.3rem] bg-white/95 p-3 shadow-lg">
        <div className="mb-2 flex items-center justify-between">
          <h2 className="font-display text-base text-[var(--ink)]">
            {openBranch ? kindMeta[branchById[openBranch]?.kind ?? 'vocab'].label : 'Pick a branch'}
          </h2>
          <span className="text-[10px] font-bold text-[var(--ink-soft)]">
            Tap node → expand
          </span>
        </div>
        <div className="space-y-2">
          {visibleLeaves.map((leaf) => (
            <button
              key={leaf.id}
              type="button"
              onClick={() =>
                openBranch &&
                setActiveLeaf({ branch: branchById[openBranch], leaf })
              }
              className="flex w-full items-start gap-2 rounded-2xl bg-[var(--ground)] px-3 py-2.5 text-left transition active:scale-[0.99]"
            >
              <Layers size={14} className="mt-0.5 shrink-0 text-[var(--ink-soft)]" />
              <div className="min-w-0 flex-1">
                <p className="font-display text-sm text-[var(--ink)]">{leaf.term}</p>
                <p className="truncate text-xs text-[var(--ink-soft)]">{leaf.detail}</p>
              </div>
              {leaf.level && (
                <span className="rounded-full bg-[#0f4c5c]/10 px-1.5 py-0.5 text-[9px] font-bold text-[#0f4c5c]">
                  {leaf.level}
                </span>
              )}
            </button>
          ))}
          {!visibleLeaves.length && (
            <p className="py-4 text-center text-xs text-[var(--ink-soft)]">
              Tap Keywords, Grammar, or Idioms on the map
            </p>
          )}
        </div>
      </div>

      <div className="absolute inset-x-4 bottom-24 z-20">
        <button
          type="button"
          onClick={onReview}
          className="flex w-full items-center justify-center gap-2 rounded-2xl bg-[#ffc94a] py-3.5 font-display text-[var(--ink)] shadow-[0_10px_24px_rgba(255,201,74,0.4)]"
        >
          <BookOpen size={18} />
          ④ Spaced Review · Again / Got it
        </button>
      </div>

      <AnimatePresence>
        {activeLeaf && (
          <motion.div
            className="absolute inset-0 z-40 flex items-end bg-black/40 px-3 pb-28"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setActiveLeaf(null)}
          >
            <motion.div
              className="w-full rounded-3xl bg-white p-4 shadow-2xl"
              initial={{ y: 50 }}
              animate={{ y: 0 }}
              exit={{ y: 40 }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="mb-2 flex items-start justify-between">
                <div>
                  <p className="text-[10px] font-bold uppercase tracking-wider text-[var(--ink-soft)]">
                    {kindMeta[activeLeaf.branch.kind].label}
                  </p>
                  <h3 className="font-display text-xl text-[var(--ink)]">
                    {activeLeaf.leaf.term}
                  </h3>
                </div>
                <button
                  type="button"
                  onClick={() => setActiveLeaf(null)}
                  className="flex h-8 w-8 items-center justify-center rounded-full bg-[var(--ink)]/8"
                >
                  <X size={14} />
                </button>
              </div>
              <p className="text-sm text-[var(--ink)]">{activeLeaf.leaf.detail}</p>
              {activeLeaf.leaf.example && (
                <p className="mt-2 rounded-2xl bg-[var(--ground)] px-3 py-2 text-xs italic text-[var(--ink-soft)]">
                  “{activeLeaf.leaf.example}”
                </p>
              )}
              <div className="mt-2 flex flex-wrap gap-2 text-xs">
                {activeLeaf.leaf.synonym && (
                  <span className="rounded-full bg-[#2f9e6b]/15 px-2.5 py-1 font-bold text-[#2f9e6b]">
                    ≈ {activeLeaf.leaf.synonym}
                  </span>
                )}
                {activeLeaf.leaf.antonym && (
                  <span className="rounded-full bg-[#e07a3d]/15 px-2.5 py-1 font-bold text-[#e07a3d]">
                    ≠ {activeLeaf.leaf.antonym}
                  </span>
                )}
                {activeLeaf.leaf.level && (
                  <span className="rounded-full bg-[#0f4c5c]/10 px-2.5 py-1 font-bold text-[#0f4c5c]">
                    {activeLeaf.leaf.level}
                  </span>
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
