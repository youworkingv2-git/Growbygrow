import { motion, AnimatePresence } from 'framer-motion'
import { Mic, Volume2, X, Sparkles } from 'lucide-react'
import type { VocabNode } from '../data/mindmaps'

interface PopCardProps {
  node: VocabNode | null
  sentence?: string
  onClose: () => void
  onSpeak: () => void
  onRecord: () => void
}

export function PopCard({ node, sentence, onClose, onSpeak, onRecord }: PopCardProps) {
  return (
    <AnimatePresence>
      {node && (
        <motion.div
          className="absolute inset-x-3 bottom-24 z-30"
          initial={{ y: 80, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 40, opacity: 0 }}
          transition={{ type: 'spring', stiffness: 320, damping: 26 }}
        >
          <div className="relative overflow-hidden rounded-3xl border border-white/70 bg-white/95 p-4 shadow-[0_16px_40px_rgba(20,53,63,0.2)] backdrop-blur-md">
            <div
              className="absolute -right-6 -top-6 h-24 w-24 rounded-full opacity-30"
              style={{ background: node.color }}
            />
            <button
              type="button"
              onClick={onClose}
              className="absolute right-3 top-3 flex h-8 w-8 items-center justify-center rounded-full bg-[var(--ink)]/8 text-[var(--ink-soft)]"
            >
              <X size={16} />
            </button>

            <div className="flex items-center gap-3">
              <motion.div
                className="flex h-16 w-16 items-center justify-center rounded-2xl text-4xl shadow-inner"
                style={{ background: `${node.color}33` }}
                animate={{ rotate: [0, -8, 8, 0], scale: [1, 1.08, 1] }}
                transition={{ duration: 0.7, repeat: Infinity, repeatDelay: 1.8 }}
              >
                {node.emoji}
              </motion.div>
              <div>
                <p className="font-display text-2xl text-[var(--ink)]">{node.word}</p>
                {node.soundHint && (
                  <p className="text-sm text-[var(--ink-soft)]">{node.soundHint}</p>
                )}
              </div>
            </div>

            {sentence && (
              <div className="mt-3 flex items-center gap-2 rounded-2xl bg-[var(--ground)] px-3 py-2">
                <Sparkles size={16} className="text-[var(--sun-deep)]" />
                <p className="font-display text-sm text-[var(--ink)]">
                  Sentence: <span className="text-[var(--leaf)]">{sentence}</span>
                </p>
              </div>
            )}

            <div className="mt-3 flex gap-2">
              <button
                type="button"
                onClick={onSpeak}
                className="flex flex-1 items-center justify-center gap-2 rounded-2xl bg-[var(--ocean)] py-3 font-display text-white shadow-[0_8px_18px_rgba(42,159,216,0.35)]"
              >
                <Volume2 size={18} /> Hear
              </button>
              <button
                type="button"
                onClick={onRecord}
                className="flex flex-1 items-center justify-center gap-2 rounded-2xl bg-[var(--coral)] py-3 font-display text-white shadow-[0_8px_18px_rgba(255,107,74,0.35)]"
              >
                <Mic size={18} /> Magic Voice
              </button>
            </div>
            <p className="mt-2 text-center text-[11px] text-[var(--ink-soft)]">
              Hold any node to record · Image ↔ English ↔ Sound
            </p>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
