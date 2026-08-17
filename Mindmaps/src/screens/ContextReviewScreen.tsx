import { useMemo, useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ArrowLeft, Brain, Check, RotateCcw, X } from 'lucide-react'
import {
  kindMeta,
  mapToSpacedCards,
  type ContextMapResult,
  type SpacedCard,
} from '../data/contextMap'

interface Props {
  map: ContextMapResult
  onBack: () => void
  onDone: () => void
}

const curvePoints = [
  { day: 0, retain: 100 },
  { day: 1, retain: 58 },
  { day: 3, retain: 36 },
  { day: 7, retain: 25 },
  { day: 14, retain: 18 },
  { day: 30, retain: 12 },
]

export function ContextReviewScreen({ map, onBack, onDone }: Props) {
  const allCards = useMemo(() => mapToSpacedCards(map), [map])
  const [queue, setQueue] = useState<SpacedCard[]>(allCards)
  const [flipped, setFlipped] = useState(false)
  const [reviewed, setReviewed] = useState(0)
  const [showCurve, setShowCurve] = useState(false)

  const current = queue[0]
  const done = !current

  const rate = (knew: boolean) => {
    if (!current) return
    setFlipped(false)
    setReviewed((r) => r + 1)
    setQueue((q) => {
      const rest = q.slice(1)
      if (!knew) {
        // requeue later — spaced fail
        return [...rest, { ...current, dueLabel: 'Again · 10 min', intervalDays: 0 }]
      }
      return rest
    })
  }

  return (
    <div className="relative h-full overflow-hidden bg-gradient-to-b from-[#1a2744] via-[#243556] to-[#eef2f8] pb-8">
      <header className="flex items-center gap-2 px-4 pt-12 text-white">
        <button
          type="button"
          onClick={onBack}
          className="flex h-10 w-10 items-center justify-center rounded-full bg-white/15"
        >
          <ArrowLeft size={18} />
        </button>
        <div className="flex-1">
          <h1 className="font-display text-xl">④ Spaced Review</h1>
          <p className="text-xs text-white/65">
            Flashcard sơ đồ · đường cong quên · Again / Got it
          </p>
        </div>
        <button
          type="button"
          onClick={() => setShowCurve((s) => !s)}
          className="flex h-10 w-10 items-center justify-center rounded-full bg-white/15"
        >
          <Brain size={16} />
        </button>
      </header>

      <div className="mx-4 mt-3 flex items-center justify-between rounded-2xl bg-white/10 px-3 py-2 text-white">
        <span className="text-xs font-bold">{reviewed} reviewed</span>
        <span className="text-xs text-white/70">{queue.length} left in queue</span>
        <span className="rounded-full bg-[#ffc94a]/20 px-2 py-0.5 text-[10px] font-bold text-[#ffc94a]">
          SRS
        </span>
      </div>

      <AnimatePresence mode="wait">
        {showCurve ? (
          <motion.div
            key="curve"
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0 }}
            className="mx-4 mt-4 rounded-3xl bg-white p-4 shadow-xl"
          >
            <h2 className="font-display text-lg text-[var(--ink)]">Ebbinghaus curve</h2>
            <p className="mb-3 text-xs text-[var(--ink-soft)]">
              Without review, recall drops fast. ContextMap schedules cards along this curve.
            </p>
            <svg viewBox="0 0 280 120" className="w-full">
              <path
                d="M10 15 C 40 20, 50 55, 80 70 C 120 90, 160 95, 270 105"
                fill="none"
                stroke="#e07a3d"
                strokeWidth="3"
                strokeLinecap="round"
              />
              <path
                d="M10 15 C 40 18, 55 35, 90 42 C 140 52, 180 48, 270 55"
                fill="none"
                stroke="#2f9e6b"
                strokeWidth="3"
                strokeLinecap="round"
                strokeDasharray="6 6"
              />
              {curvePoints.map((p) => (
                <circle
                  key={p.day}
                  cx={10 + (p.day / 30) * 260}
                  cy={15 + (100 - p.retain) * 0.9}
                  r="3.5"
                  fill="#0f4c5c"
                />
              ))}
            </svg>
            <div className="mt-1 flex justify-between text-[10px] font-bold text-[var(--ink-soft)]">
              <span>Day 0</span>
              <span className="text-[#e07a3d]">No review</span>
              <span className="text-[#2f9e6b]">With SRS</span>
              <span>Day 30</span>
            </div>
            <button
              type="button"
              onClick={() => setShowCurve(false)}
              className="mt-3 w-full rounded-2xl bg-[#0f4c5c] py-2.5 font-display text-white"
            >
              Back to cards
            </button>
          </motion.div>
        ) : done ? (
          <motion.div
            key="done"
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            className="mx-4 mt-10 rounded-3xl bg-white p-6 text-center shadow-xl"
          >
            <p className="text-5xl">🧠</p>
            <h2 className="mt-2 font-display text-2xl text-[var(--ink)]">Queue clear</h2>
            <p className="text-sm text-[var(--ink-soft)]">
              Next wave lands on the forgetting-curve schedule from this map.
            </p>
            <button
              type="button"
              onClick={onDone}
              className="mt-4 w-full rounded-2xl bg-[#0f4c5c] py-3 font-display text-white"
            >
              Back to ContextMap
            </button>
          </motion.div>
        ) : (
          <motion.div
            key={current.id + String(flipped)}
            initial={{ opacity: 0, rotateY: -12 }}
            animate={{ opacity: 1, rotateY: 0 }}
            exit={{ opacity: 0 }}
            className="mx-4 mt-5"
          >
            <button
              type="button"
              onClick={() => setFlipped((f) => !f)}
              className="relative w-full overflow-hidden rounded-[1.6rem] bg-white p-5 text-left shadow-[0_16px_36px_rgba(26,39,68,0.25)]"
            >
              <div className="mb-3 flex items-center justify-between">
                <span
                  className="rounded-full px-2.5 py-0.5 text-[10px] font-bold text-white"
                  style={{
                    background:
                      current.kind === 'vocab'
                        ? '#e07a3d'
                        : current.kind === 'grammar'
                          ? '#2f9e6b'
                          : '#7a5af8',
                  }}
                >
                  {kindMeta[current.kind].short}
                </span>
                <span className="text-[10px] font-bold text-[var(--ink-soft)]">
                  Due {current.dueLabel}
                </span>
              </div>

              {!flipped ? (
                <>
                  <p className="font-display text-2xl text-[var(--ink)]">{current.front}</p>
                  <p className="mt-6 text-center text-xs text-[var(--ink-soft)]">
                    Tap to reveal · mindmap flashcard
                  </p>
                </>
              ) : (
                <>
                  <p className="text-sm leading-relaxed text-[var(--ink)]">{current.back}</p>
                  {current.example && (
                    <p className="mt-3 rounded-2xl bg-[var(--ground)] px-3 py-2 text-xs italic text-[var(--ink-soft)]">
                      {current.example}
                    </p>
                  )}
                  {/* mini map diagram */}
                  <div className="mt-4 flex items-center justify-center gap-2">
                    <span className="rounded-xl bg-[#0f4c5c] px-2 py-1 text-[10px] font-bold text-white">
                      {map.root.title}
                    </span>
                    <span className="text-[var(--ink-soft)]">→</span>
                    <span
                      className="rounded-xl px-2 py-1 text-[10px] font-bold text-white"
                      style={{
                        background:
                          current.kind === 'vocab'
                            ? '#e07a3d'
                            : current.kind === 'grammar'
                              ? '#2f9e6b'
                              : '#7a5af8',
                      }}
                    >
                      {kindMeta[current.kind].short}
                    </span>
                    <span className="text-[var(--ink-soft)]">→</span>
                    <span className="max-w-[100px] truncate rounded-xl bg-[var(--ink)]/8 px-2 py-1 text-[10px] font-bold text-[var(--ink)]">
                      {current.front}
                    </span>
                  </div>
                </>
              )}
            </button>

            {flipped && (
              <div className="mt-4 grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => rate(false)}
                  className="flex items-center justify-center gap-2 rounded-2xl bg-[#e07a3d] py-3.5 font-display text-white shadow-lg"
                >
                  <X size={18} /> Again
                </button>
                <button
                  type="button"
                  onClick={() => rate(true)}
                  className="flex items-center justify-center gap-2 rounded-2xl bg-[#2f9e6b] py-3.5 font-display text-white shadow-lg"
                >
                  <Check size={18} /> Got it
                </button>
              </div>
            )}

            {!flipped && (
              <button
                type="button"
                onClick={() => setFlipped(true)}
                className="mt-4 flex w-full items-center justify-center gap-2 rounded-2xl bg-white/15 py-3 font-display text-white"
              >
                <RotateCcw size={16} /> Flip card
              </button>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
