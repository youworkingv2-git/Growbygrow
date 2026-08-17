import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ArrowLeft, Check } from 'lucide-react'
import { connectItems, type ScreenId } from '../data/mindmaps'

interface Props {
  onBack: () => void
  onNavigate: (screen: ScreenId) => void
}

const branches = [
  { id: 'Fruits', emoji: '🌳', color: '#ff6b4a' },
  { id: 'Pets', emoji: '🏠', color: '#ff8f6b' },
  { id: 'Sea', emoji: '🌊', color: '#4db8e8' },
  { id: 'Wild', emoji: '🌲', color: '#5ecf8a' },
]

export function ConnectGameScreen({ onBack, onNavigate }: Props) {
  const [queue, setQueue] = useState(connectItems)
  const [current, setCurrent] = useState(connectItems[0])
  const [score, setScore] = useState(0)
  const [feedback, setFeedback] = useState<'ok' | 'no' | null>(null)
  const [done, setDone] = useState(false)

  const dropOn = (branchId: string) => {
    if (!current || done) return
    const correct = current.branch === branchId
    setFeedback(correct ? 'ok' : 'no')
    if (correct) {
      const nextScore = score + 1
      setScore(nextScore)
      const rest = queue.slice(1)
      setTimeout(() => {
        setFeedback(null)
        if (rest.length === 0) {
          setDone(true)
          setCurrent(undefined as never)
        } else {
          setQueue(rest)
          setCurrent(rest[0])
        }
      }, 450)
    } else {
      setTimeout(() => setFeedback(null), 450)
    }
  }

  return (
    <div className="relative h-full overflow-hidden bg-gradient-to-b from-[#d4f5ff] via-[#e8f7d9] to-[#fff4d6] pb-8">
      <header className="flex items-center gap-2 px-4 pt-12">
        <button
          type="button"
          onClick={onBack}
          className="flex h-10 w-10 items-center justify-center rounded-full bg-white shadow-sm"
        >
          <ArrowLeft size={18} />
        </button>
        <div className="flex-1">
          <h1 className="font-display text-xl">Mind-Connect</h1>
          <p className="text-xs text-[var(--ink-soft)]">Drag icon → correct branch · 30–60s</p>
        </div>
        <div className="rounded-full bg-white px-3 py-1 font-display text-sm shadow-sm">
          {score}/{connectItems.length}
        </div>
      </header>

      <div className="mt-6 flex justify-center">
        <AnimatePresence mode="wait">
          {!done && current ? (
            <motion.div
              key={current.id}
              drag
              dragSnapToOrigin
              initial={{ scale: 0.6, y: -30, opacity: 0 }}
              animate={{ scale: 1, y: 0, opacity: 1 }}
              exit={{ scale: 0.4, opacity: 0 }}
              className="flex h-28 w-28 cursor-grab flex-col items-center justify-center rounded-[2rem] bg-white shadow-[0_12px_30px_rgba(20,53,63,0.15)] active:cursor-grabbing"
              style={{ border: `3px solid ${current.branchColor}` }}
            >
              <span className="text-5xl">{current.emoji}</span>
              <span className="font-display text-sm">{current.word}</span>
            </motion.div>
          ) : (
            <motion.div
              initial={{ scale: 0.8 }}
              animate={{ scale: 1 }}
              className="rounded-3xl bg-white px-6 py-5 text-center shadow-lg"
            >
              <p className="text-4xl">🏆</p>
              <h2 className="font-display text-2xl">Branch master!</h2>
              <p className="text-sm text-[var(--ink-soft)]">+1 pet treat unlocked</p>
              <button
                type="button"
                onClick={() => onNavigate('pet')}
                className="mt-3 rounded-2xl bg-[var(--leaf)] px-5 py-2.5 font-display text-white"
              >
                Feed my pet
              </button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {feedback && (
        <p
          className={`mt-3 text-center font-display text-lg ${
            feedback === 'ok' ? 'text-[var(--leaf)]' : 'text-[var(--coral)]'
          }`}
        >
          {feedback === 'ok' ? 'Nice match!' : 'Try another branch'}
        </p>
      )}

      <div className="absolute inset-x-4 bottom-10 grid grid-cols-2 gap-3">
        {branches.map((b) => (
          <button
            key={b.id}
            type="button"
            onClick={() => dropOn(b.id)}
            className="flex items-center gap-3 rounded-3xl bg-white/90 p-3 text-left shadow-md transition active:scale-95"
            style={{ boxShadow: `inset 0 0 0 2px ${b.color}55` }}
          >
            <span
              className="flex h-12 w-12 items-center justify-center rounded-2xl text-2xl"
              style={{ background: `${b.color}30` }}
            >
              {b.emoji}
            </span>
            <div>
              <p className="font-display text-base">{b.id}</p>
              <p className="text-[11px] text-[var(--ink-soft)]">Drop here</p>
            </div>
            {done && <Check className="ml-auto text-[var(--leaf)]" size={18} />}
          </button>
        ))}
      </div>
    </div>
  )
}
