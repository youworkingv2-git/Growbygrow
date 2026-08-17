import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { ArrowLeft, Mic, Volume2 } from 'lucide-react'

interface Props {
  word?: string
  emoji?: string
  onBack: () => void
}

const faces = [
  { min: 0, emoji: '😅', label: 'Try again!' },
  { min: 50, emoji: '🙂', label: 'Good!' },
  { min: 75, emoji: '🤩', label: 'Awesome!' },
  { min: 90, emoji: '🥳', label: 'Star voice!' },
]

export function VoiceScreen({ word = 'Mother', emoji = '👩', onBack }: Props) {
  const [recording, setRecording] = useState(false)
  const [score, setScore] = useState<number | null>(null)
  const [progress, setProgress] = useState(0)

  useEffect(() => {
    if (!recording) return
    setScore(null)
    setProgress(0)
    const start = Date.now()
    const iv = setInterval(() => {
      const p = Math.min(100, ((Date.now() - start) / 1600) * 100)
      setProgress(p)
      if (p >= 100) {
        clearInterval(iv)
        setRecording(false)
        setScore(72 + Math.floor(Math.random() * 26))
      }
    }, 50)
    return () => clearInterval(iv)
  }, [recording])

  const face = faces.reduce((acc, f) => (score !== null && score >= f.min ? f : acc), faces[0])

  const speak = () => {
    if (!window.speechSynthesis) return
    const u = new SpeechSynthesisUtterance(word)
    u.lang = 'en-US'
    window.speechSynthesis.speak(u)
  }

  return (
    <div className="relative h-full overflow-hidden bg-gradient-to-b from-[#ffd0e0] via-[#ffe9b8] to-[#d4f5ff] pb-8">
      <header className="flex items-center gap-2 px-4 pt-12">
        <button
          type="button"
          onClick={onBack}
          className="flex h-10 w-10 items-center justify-center rounded-full bg-white shadow-sm"
        >
          <ArrowLeft size={18} />
        </button>
        <div>
          <h1 className="font-display text-xl">Magic Voice</h1>
          <p className="text-xs text-[var(--ink-soft)]">Hold & speak · AI scores with fun faces</p>
        </div>
      </header>

      <div className="mt-8 flex flex-col items-center px-6">
        <motion.div
          className="flex h-28 w-28 items-center justify-center rounded-[2rem] bg-white text-6xl shadow-xl"
          animate={{ rotate: recording ? [0, -4, 4, 0] : 0 }}
          transition={{ repeat: recording ? Infinity : 0, duration: 0.4 }}
        >
          {emoji}
        </motion.div>
        <h2 className="mt-4 font-display text-4xl text-[var(--ink)]">{word}</h2>
        <button
          type="button"
          onClick={speak}
          className="mt-2 flex items-center gap-1 rounded-full bg-[var(--ocean)] px-4 py-2 text-sm font-bold text-white"
        >
          <Volume2 size={16} /> Hear model
        </button>

        <div className="relative mt-10">
          {recording && (
            <div
              className="absolute inset-0 rounded-full border-4 border-[var(--coral)]"
              style={{
                transform: `scale(${1 + progress / 120})`,
                opacity: 1 - progress / 120,
              }}
            />
          )}
          <button
            type="button"
            onPointerDown={() => setRecording(true)}
            onPointerUp={() => setRecording(false)}
            className={`relative z-10 flex h-24 w-24 items-center justify-center rounded-full text-white shadow-[0_14px_30px_rgba(255,107,74,0.45)] ${
              recording ? 'bg-[var(--coral)] scale-110' : 'bg-[var(--coral)]'
            } transition-transform`}
          >
            <Mic size={36} />
          </button>
        </div>
        <p className="mt-3 text-sm text-[var(--ink-soft)]">
          {recording ? 'Listening…' : 'Press & hold to record'}
        </p>

        {score !== null && (
          <motion.div
            className="mt-6 w-full rounded-3xl bg-white p-5 text-center shadow-lg"
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
          >
            <p className="text-5xl">{face.emoji}</p>
            <p className="font-display text-2xl">{face.label}</p>
            <p className="text-sm text-[var(--ink-soft)]">Score {score}/100</p>
            <div className="mt-2 h-2 overflow-hidden rounded-full bg-[var(--ink)]/8">
              <div
                className="h-full rounded-full bg-[var(--leaf)]"
                style={{ width: `${score}%` }}
              />
            </div>
          </motion.div>
        )}
      </div>
    </div>
  )
}
