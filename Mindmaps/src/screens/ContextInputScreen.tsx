import { useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import {
  FileText,
  Link2,
  Sparkles,
  Play,
  Mail,
  Music2,
  Target,
  Gem,
  Ruler,
  Wand2,
} from 'lucide-react'
import {
  SAMPLE_ARTICLE,
  SAMPLE_YOUTUBE,
  generateContextMap,
  type ContextMapResult,
} from '../data/contextMap'

interface Props {
  onGenerate: (result: ContextMapResult) => void
}

type SourceType = ContextMapResult['sourceType']

const sources: { id: SourceType; label: string; icon: typeof FileText }[] = [
  { id: 'article', label: 'Article', icon: FileText },
  { id: 'youtube', label: 'YouTube', icon: Play },
  { id: 'tiktok', label: 'TikTok', icon: Music2 },
  { id: 'email', label: 'Email', icon: Mail },
]

const pipeline = [
  { icon: '①', label: 'Paste' },
  { icon: '②', label: 'Generate' },
  { icon: '③', label: 'Mindmap' },
  { icon: '④', label: 'Review' },
]

const analyzeSteps = [
  { key: 'idea', label: 'Main Idea', emoji: '🎯', color: '#0f4c5c' },
  { key: 'vocab', label: 'Keywords', emoji: '💎', color: '#e07a3d' },
  { key: 'grammar', label: 'Grammar', emoji: '📐', color: '#2f9e6b' },
  { key: 'idiom', label: 'Idioms / Phrasals', emoji: '🪄', color: '#7a5af8' },
]

export function ContextInputScreen({ onGenerate }: Props) {
  const [source, setSource] = useState<SourceType>('article')
  const [text, setText] = useState(SAMPLE_ARTICLE)
  const [url, setUrl] = useState('')
  const [busy, setBusy] = useState(false)
  const [step, setStep] = useState(0)

  const runGenerate = async () => {
    if (!text.trim() || busy) return
    setBusy(true)
    setStep(0)
    for (let i = 0; i < analyzeSteps.length; i++) {
      setStep(i)
      await new Promise((r) => setTimeout(r, 480))
    }
    await new Promise((r) => setTimeout(r, 350))
    const result = generateContextMap(text, source)
    if (url.trim()) result.sourceLabel = url.trim()
    setBusy(false)
    onGenerate(result)
  }

  return (
    <div className="phone-scroll relative h-full overflow-y-auto bg-gradient-to-b from-[#0f4c5c] via-[#1a6b7a] to-[#e8f4f0] pb-28">
      <header className="px-5 pt-12 text-white">
        <span className="rounded-full bg-white/15 px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider">
          B2–C1 · IELTS / TOEIC / Work
        </span>
        <h1 className="mt-2 font-display text-[32px] leading-none">
          ContextMap
          <span className="text-[#ffc94a]"> AI</span>
        </h1>
        <p className="mt-2 text-sm text-white/75">
          Contextual learning — any English content → lesson mindmap
        </p>
      </header>

      {/* Flow checklist */}
      <div className="mx-4 mt-4 flex gap-1">
        {pipeline.map((p, i) => (
          <div
            key={p.label}
            className={`flex flex-1 flex-col items-center rounded-2xl px-1 py-2 ${
              i === 0 ? 'bg-[#ffc94a] text-[var(--ink)]' : 'bg-white/10 text-white/80'
            }`}
          >
            <span className="font-display text-xs">{p.icon}</span>
            <span className="text-[9px] font-bold">{p.label}</span>
          </div>
        ))}
      </div>

      <section className="mx-4 mt-4 rounded-[1.6rem] bg-white/95 p-4 shadow-[0_16px_40px_rgba(15,76,92,0.25)]">
        <p className="mb-1 font-display text-sm text-[var(--ink)]">
          ① Paste bài báo / email / transcript
        </p>
        <p className="mb-3 text-[11px] text-[var(--ink-soft)]">
          YouTube · TikTok (+ URL tùy chọn)
        </p>

        <div className="mb-3 flex gap-1.5">
          {sources.map(({ id, label, icon: Icon }) => {
            const on = source === id
            return (
              <button
                key={id}
                type="button"
                onClick={() => {
                  setSource(id)
                  if (id === 'youtube' || id === 'tiktok') setText(SAMPLE_YOUTUBE)
                  if (id === 'article' || id === 'email') setText(SAMPLE_ARTICLE)
                }}
                className={`flex flex-1 flex-col items-center gap-1 rounded-2xl py-2.5 text-[10px] font-bold ${
                  on
                    ? 'bg-[#0f4c5c] text-white'
                    : 'bg-[var(--ink)]/5 text-[var(--ink-soft)]'
                }`}
              >
                <Icon size={16} />
                {label}
              </button>
            )
          })}
        </div>

        <label className="mb-1 flex items-center gap-1.5 text-xs font-bold text-[var(--ink-soft)]">
          <Link2 size={12} /> URL (optional)
        </label>
        <input
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          placeholder="https://youtube.com/… or article link"
          className="mb-3 w-full rounded-2xl border border-[var(--ink)]/10 bg-[var(--ground)] px-3 py-2.5 text-sm outline-none focus:border-[#0f4c5c]"
        />

        <label className="mb-1 flex items-center gap-1.5 text-xs font-bold text-[var(--ink-soft)]">
          <FileText size={12} /> Text / transcript
        </label>
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          rows={7}
          className="w-full resize-none rounded-2xl border border-[var(--ink)]/10 bg-[var(--ground)] px-3 py-3 text-[13px] leading-relaxed text-[var(--ink)] outline-none focus:border-[#0f4c5c]"
        />

        <div className="mt-2 flex gap-2">
          <button
            type="button"
            onClick={() => {
              setSource('article')
              setText(SAMPLE_ARTICLE)
            }}
            className="rounded-xl bg-[var(--ink)]/5 px-3 py-1.5 text-[11px] font-bold text-[var(--ink-soft)]"
          >
            Demo article
          </button>
          <button
            type="button"
            onClick={() => {
              setSource('youtube')
              setText(SAMPLE_YOUTUBE)
            }}
            className="rounded-xl bg-[var(--ink)]/5 px-3 py-1.5 text-[11px] font-bold text-[var(--ink-soft)]"
          >
            Demo transcript
          </button>
        </div>

        <button
          type="button"
          disabled={busy || !text.trim()}
          onClick={runGenerate}
          className="mt-4 flex w-full items-center justify-center gap-2 rounded-2xl bg-gradient-to-r from-[#0f4c5c] to-[#1b8a6b] py-3.5 font-display text-white shadow-[0_12px_28px_rgba(15,76,92,0.35)] disabled:opacity-60"
        >
          <Sparkles size={18} />
          ② Generate (~2s) → AI phân tích
        </button>
      </section>

      {/* What AI extracts */}
      <div className="mx-4 mt-3 grid grid-cols-2 gap-2">
        {[
          { Icon: Target, label: '🎯 Main Idea', sub: 'Ý chính bài viết' },
          { Icon: Gem, label: '💎 Keywords', sub: 'Synonym / Antonym' },
          { Icon: Ruler, label: '📐 Grammar', sub: 'Cấu trúc ăn điểm' },
          { Icon: Wand2, label: '🪄 Idioms', sub: 'Phrasal verbs' },
        ].map(({ label, sub }) => (
          <div
            key={label}
            className="rounded-2xl bg-white/15 px-3 py-2.5 text-white backdrop-blur-sm"
          >
            <p className="font-display text-xs">{label}</p>
            <p className="text-[10px] text-white/65">{sub}</p>
          </div>
        ))}
      </div>

      <p className="mx-6 mt-3 pb-2 text-center text-[11px] text-white/75">
        ④ Spaced Review — flashcard sơ đồ + đường cong quên (Again / Got it)
      </p>

      {/* Full-screen generate overlay */}
      <AnimatePresence>
        {busy && (
          <motion.div
            className="absolute inset-0 z-50 flex flex-col items-center justify-center bg-[#0f4c5c]/92 px-6 backdrop-blur-md"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <motion.div
              className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-[#ffc94a] text-3xl"
              animate={{ rotate: 360, scale: [1, 1.08, 1] }}
              transition={{ rotate: { duration: 2, repeat: Infinity, ease: 'linear' }, scale: { duration: 1.2, repeat: Infinity } }}
            >
              ✨
            </motion.div>
            <p className="font-display text-xl text-white">AI đang phân tích…</p>
            <p className="mt-1 text-sm text-white/65">~2 giây · Contextual mindmap</p>

            <div className="mt-8 w-full max-w-xs space-y-2">
              {analyzeSteps.map((s, i) => {
                const done = i < step
                const active = i === step
                return (
                  <motion.div
                    key={s.key}
                    className={`flex items-center gap-3 rounded-2xl px-3 py-2.5 ${
                      active ? 'bg-white text-[var(--ink)]' : done ? 'bg-white/20 text-white' : 'bg-white/5 text-white/40'
                    }`}
                    animate={{ opacity: i <= step ? 1 : 0.35, x: active ? 4 : 0 }}
                  >
                    <span className="text-lg">{s.emoji}</span>
                    <span className="flex-1 font-display text-sm">{s.label}</span>
                    {done && <span className="text-xs font-bold text-[#3ecf9a]">✓</span>}
                    {active && (
                      <span className="h-2 w-2 animate-pulse rounded-full" style={{ background: s.color }} />
                    )}
                  </motion.div>
                )
              })}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
