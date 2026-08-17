import { motion } from 'framer-motion'
import { Clock, Flame, Star } from 'lucide-react'
import type { MindmapTopic, ScreenId } from '../data/mindmaps'

interface HomeScreenProps {
  topics: MindmapTopic[]
  onOpenTopic: (id: string) => void
  onNavigate: (screen: ScreenId) => void
  streak: number
}

export function HomeScreen({ topics, onOpenTopic, onNavigate, streak }: HomeScreenProps) {
  return (
    <div className="treemap-bg phone-scroll relative h-full overflow-y-auto pb-24">
      {/* Decorative clouds / hills */}
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute -left-8 top-16 h-20 w-36 rounded-full bg-white/45 blur-[1px]" />
        <div className="absolute right-2 top-24 h-14 w-28 rounded-full bg-white/40" />
        <svg
          className="absolute bottom-20 left-0 w-full opacity-80"
          viewBox="0 0 390 120"
          fill="none"
        >
          <path
            d="M0 80 C60 40 90 90 150 70 C210 50 240 95 300 65 C340 48 370 70 390 60 L390 120 L0 120 Z"
            fill="#7bcf6a"
            opacity="0.55"
          />
          <path
            d="M0 95 C80 70 120 105 180 85 C250 60 300 100 390 80 L390 120 L0 120 Z"
            fill="#4fb86a"
            opacity="0.7"
          />
        </svg>
      </div>

      <header className="relative z-10 px-5 pt-12">
        <div className="flex items-start justify-between">
          <div>
            <p className="font-display text-xs uppercase tracking-widest text-[var(--leaf)]">
              Welcome explorer
            </p>
            <h1 className="font-display text-[34px] leading-none text-[var(--ink)]">
              MindWord
              <span className="block text-[var(--coral)]">World</span>
            </h1>
            <p className="mt-1 max-w-[220px] text-sm text-[var(--ink-soft)]">
              Touch · Pop · Speak — learn English through living mindmaps
            </p>
          </div>
          <motion.div
            className="animate-float flex h-16 w-16 items-center justify-center rounded-3xl bg-white/80 text-4xl shadow-lg"
            animate={{ rotate: [0, 6, -6, 0] }}
            transition={{ duration: 4, repeat: Infinity }}
          >
            🦊
          </motion.div>
        </div>

        <div className="mt-4 flex gap-2">
          <div className="flex items-center gap-1.5 rounded-2xl bg-white/75 px-3 py-2 shadow-sm">
            <Flame size={16} className="text-[var(--coral)]" />
            <span className="font-display text-sm">{streak} day streak</span>
          </div>
          <div className="flex items-center gap-1.5 rounded-2xl bg-white/75 px-3 py-2 shadow-sm">
            <Clock size={16} className="text-[var(--ocean)]" />
            <span className="font-display text-sm">18 min left</span>
          </div>
        </div>
      </header>

      <section className="relative z-10 mt-4 px-5">
        <button
          type="button"
          onClick={() => onNavigate('context')}
          className="w-full overflow-hidden rounded-[1.4rem] bg-gradient-to-r from-[#0f4c5c] to-[#1b8a6b] p-4 text-left text-white shadow-[0_12px_28px_rgba(15,76,92,0.3)]"
        >
          <div className="flex items-start justify-between gap-2">
            <div>
              <p className="text-[10px] font-bold uppercase tracking-wider text-[#ffc94a]">
                Intermediate · Advanced
              </p>
              <p className="font-display text-xl leading-tight">ContextMap AI</p>
              <p className="mt-1 text-xs text-white/75">
                Paste article / YouTube → auto mindmap · SRS review
              </p>
            </div>
            <span className="text-3xl">✨</span>
          </div>
        </button>
      </section>

      <section className="relative z-10 mt-4 px-5">
        <div className="mb-3 flex items-end justify-between">
          <h2 className="font-display text-xl text-[var(--ink)]">Treasure islands</h2>
          <button
            type="button"
            onClick={() => onNavigate('pet')}
            className="text-xs font-bold text-[var(--leaf)]"
          >
            Feed pet →
          </button>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {topics.map((topic, i) => (
            <motion.button
              key={topic.id}
              type="button"
              initial={{ opacity: 0, y: 24 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.08 }}
              disabled={!topic.unlocked}
              onClick={() => topic.unlocked && onOpenTopic(topic.id)}
              className={`relative overflow-hidden rounded-[1.4rem] p-3 text-left shadow-[0_10px_24px_rgba(20,53,63,0.12)] ${
                topic.unlocked ? 'bg-white/90' : 'bg-white/50 opacity-60'
              }`}
            >
              <div
                className="absolute -right-4 -top-4 h-16 w-16 rounded-full opacity-25"
                style={{ background: topic.accent }}
              />
              <div
                className="mb-2 flex h-12 w-12 items-center justify-center rounded-2xl text-2xl"
                style={{ background: `${topic.accent}28` }}
              >
                {topic.emoji}
              </div>
              <p className="font-display text-base leading-tight text-[var(--ink)]">
                {topic.title}
              </p>
              <p className="text-[11px] text-[var(--ink-soft)]">{topic.subtitle}</p>
              {topic.unlocked ? (
                <div className="mt-2">
                  <div className="h-1.5 overflow-hidden rounded-full bg-[var(--ink)]/8">
                    <div
                      className="h-full rounded-full"
                      style={{
                        width: `${topic.progress}%`,
                        background: topic.accent,
                      }}
                    />
                  </div>
                  <p className="mt-1 flex items-center gap-1 text-[10px] font-bold text-[var(--ink-soft)]">
                    <Star size={10} className="text-[var(--sun-deep)]" />
                    {topic.progress}% explored
                  </p>
                </div>
              ) : (
                <p className="mt-2 text-[11px] font-bold text-[var(--ink-soft)]">🔒 Locked</p>
              )}
            </motion.button>
          ))}
        </div>
      </section>

      <section className="relative z-10 mt-4 px-5">
        <h2 className="mb-2 font-display text-lg text-[var(--ink)]">Quick play</h2>
        <div className="flex gap-2 overflow-x-auto pb-1">
          {[
            { id: 'connect' as const, title: 'Mind-Connect', emoji: '🪢', color: '#3ecf9a' },
            { id: 'pop' as const, title: 'Pop the Node', emoji: '🔨', color: '#ff6b4a' },
            { id: 'color' as const, title: 'Color Map', emoji: '🎨', color: '#ffc94a' },
          ].map((game) => (
            <button
              key={game.id}
              type="button"
              onClick={() => onNavigate(game.id)}
              className="flex min-w-[128px] items-center gap-2 rounded-2xl bg-white/85 px-3 py-2.5 shadow-sm"
            >
              <span
                className="flex h-9 w-9 items-center justify-center rounded-xl text-lg"
                style={{ background: `${game.color}33` }}
              >
                {game.emoji}
              </span>
              <span className="font-display text-sm">{game.title}</span>
            </button>
          ))}
        </div>
      </section>
    </div>
  )
}
