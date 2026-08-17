import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { ArrowLeft, Volume2 } from 'lucide-react'
import { popTargets, type ScreenId } from '../data/mindmaps'

interface Props {
  onBack: () => void
  onNavigate: (screen: ScreenId) => void
}

function speak(text: string) {
  if (typeof window === 'undefined' || !window.speechSynthesis) return
  window.speechSynthesis.cancel()
  const u = new SpeechSynthesisUtterance(text)
  u.lang = 'en-US'
  u.rate = 0.88
  window.speechSynthesis.speak(u)
}

export function PopGameScreen({ onBack, onNavigate }: Props) {
  const [target, setTarget] = useState(popTargets[0])
  const [nodes, setNodes] = useState(popTargets)
  const [score, setScore] = useState(0)
  const [timeLeft, setTimeLeft] = useState(30)
  const [flash, setFlash] = useState<'ok' | 'miss' | null>(null)
  const [ended, setEnded] = useState(false)

  useEffect(() => {
    speak(target.word)
  }, [target])

  useEffect(() => {
    if (ended) return
    const t = setInterval(() => {
      setTimeLeft((s) => {
        if (s <= 1) {
          clearInterval(t)
          setEnded(true)
          return 0
        }
        return s - 1
      })
    }, 1000)
    return () => clearInterval(t)
  }, [ended])

  const hit = (id: string) => {
    if (ended) return
    if (id === target.id) {
      setScore((s) => s + 1)
      setFlash('ok')
      const next = popTargets[Math.floor(Math.random() * popTargets.length)]
      setTarget(next)
      setNodes([...popTargets].sort(() => Math.random() - 0.5))
    } else {
      setFlash('miss')
    }
    setTimeout(() => setFlash(null), 280)
  }

  return (
    <div className="relative h-full overflow-hidden bg-gradient-to-b from-[#ffd4c4] via-[#ffe9b8] to-[#e8f7d9] pb-8">
      <header className="flex items-center gap-2 px-4 pt-12">
        <button
          type="button"
          onClick={onBack}
          className="flex h-10 w-10 items-center justify-center rounded-full bg-white shadow-sm"
        >
          <ArrowLeft size={18} />
        </button>
        <div className="flex-1">
          <h1 className="font-display text-xl">Pop the Node</h1>
          <p className="text-xs text-[var(--ink-soft)]">Hear the word · tap the picture</p>
        </div>
      </header>

      <div className="mx-4 mt-3 flex items-center justify-between rounded-2xl bg-white/85 px-4 py-2 shadow-sm">
        <span className="font-display text-sm">Score {score}</span>
        <span className="font-display text-sm text-[var(--coral)]">{timeLeft}s</span>
        <button
          type="button"
          onClick={() => speak(target.word)}
          className="flex items-center gap-1 rounded-full bg-[var(--ocean)] px-3 py-1.5 text-xs font-bold text-white"
        >
          <Volume2 size={14} /> Replay
        </button>
      </div>

      <div className="mx-4 mt-4 rounded-3xl bg-[var(--ink)] px-4 py-3 text-center text-white shadow-lg">
        <p className="text-xs uppercase tracking-wider text-white/70">Listen</p>
        <p className="font-display text-2xl">{ended ? 'Time!' : target.word}</p>
      </div>

      <div className="mt-5 grid grid-cols-3 gap-3 px-5">
        {nodes.map((n, i) => (
          <motion.button
            key={`${n.id}-${i}`}
            type="button"
            whileTap={{ scale: 0.88 }}
            animate={
              flash === 'ok' && n.id === target.id
                ? { scale: [1, 1.15, 1], rotate: [0, -8, 8, 0] }
                : {}
            }
            onClick={() => hit(n.id)}
            className="flex aspect-square flex-col items-center justify-center rounded-[1.4rem] bg-white shadow-[0_8px_20px_rgba(20,53,63,0.12)]"
          >
            <span className="text-4xl">{n.emoji}</span>
            <span className="mt-1 font-display text-xs text-[var(--ink-soft)]">{n.word}</span>
          </motion.button>
        ))}
      </div>

      {ended && (
        <div className="absolute inset-x-4 bottom-10 rounded-3xl bg-white p-5 text-center shadow-2xl">
          <p className="text-4xl">🔨</p>
          <h2 className="font-display text-2xl">You popped {score}!</h2>
          <p className="text-sm text-[var(--ink-soft)]">Great ears — keep the streak going</p>
          <div className="mt-3 flex gap-2">
            <button
              type="button"
              onClick={() => {
                setScore(0)
                setTimeLeft(30)
                setEnded(false)
                setTarget(popTargets[0])
              }}
              className="flex-1 rounded-2xl bg-[var(--coral)] py-3 font-display text-white"
            >
              Play again
            </button>
            <button
              type="button"
              onClick={() => onNavigate('pet')}
              className="flex-1 rounded-2xl bg-[var(--leaf)] py-3 font-display text-white"
            >
              Claim treat
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
