import { useState, type MouseEvent } from 'react'
import { ArrowLeft, Eraser, Sticker } from 'lucide-react'
import type { ScreenId } from '../data/mindmaps'

interface Props {
  onBack: () => void
  onNavigate: (screen: ScreenId) => void
}

const palette = ['#ff6b4a', '#ffc94a', '#3ecf9a', '#4db8e8', '#e86a8a', '#c08a5a', '#7c6af0']
const stickers = ['⭐', '❤️', '🌈', '🦋', '🌸', '✨']

export function ColorModeScreen({ onBack }: Props) {
  const [branchColors, setBranchColors] = useState(['#ff9f43', '#c08a5a', '#ff7a59'])
  const [paint, setPaint] = useState(palette[0])
  const [placed, setPlaced] = useState<{ id: number; emoji: string; x: number; y: number }[]>([])
  const [sticker, setSticker] = useState(stickers[0])

  const paintBranch = (index: number) => {
    setBranchColors((prev) => prev.map((c, i) => (i === index ? paint : c)))
  }

  const addSticker = (e: MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect()
    const x = ((e.clientX - rect.left) / rect.width) * 100
    const y = ((e.clientY - rect.top) / rect.height) * 100
    setPlaced((p) => [...p, { id: Date.now(), emoji: sticker, x, y }])
  }

  return (
    <div className="relative h-full overflow-hidden bg-gradient-to-b from-[#ffe9b8] to-[#e8f7d9] pb-8">
      <header className="flex items-center gap-2 px-4 pt-12">
        <button
          type="button"
          onClick={onBack}
          className="flex h-10 w-10 items-center justify-center rounded-full bg-white shadow-sm"
        >
          <ArrowLeft size={18} />
        </button>
        <div>
          <h1 className="font-display text-xl">Color Mindmap</h1>
          <p className="text-xs text-[var(--ink-soft)]">Paint branches · stick stickers</p>
        </div>
      </header>

      <div
        className="relative mx-4 mt-3 h-[48%] overflow-hidden rounded-[1.6rem] border-2 border-dashed border-white/80 bg-white/50"
        onClick={addSticker}
      >
        <svg className="absolute inset-0 h-full w-full" viewBox="0 0 100 100" preserveAspectRatio="none">
          <line x1="50" y1="22" x2="22" y2="48" stroke={branchColors[1]} strokeWidth="2.5" />
          <line x1="50" y1="22" x2="78" y2="48" stroke={branchColors[2]} strokeWidth="2.5" />
        </svg>
        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation()
            paintBranch(0)
          }}
          className="absolute left-1/2 top-[18%] flex h-14 w-14 -translate-x-1/2 items-center justify-center rounded-full text-2xl shadow-md"
          style={{ background: branchColors[0] }}
        >
          🏠
        </button>
        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation()
            paintBranch(1)
          }}
          className="absolute left-[18%] top-[42%] flex h-12 w-12 items-center justify-center rounded-full text-xl shadow-md"
          style={{ background: branchColors[1] }}
        >
          👴
        </button>
        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation()
            paintBranch(2)
          }}
          className="absolute right-[18%] top-[42%] flex h-12 w-12 items-center justify-center rounded-full text-xl shadow-md"
          style={{ background: branchColors[2] }}
        >
          👨‍👩‍👧
        </button>
        {placed.map((s) => (
          <span
            key={s.id}
            className="pointer-events-none absolute -translate-x-1/2 -translate-y-1/2 text-2xl"
            style={{ left: `${s.x}%`, top: `${s.y}%` }}
          >
            {s.emoji}
          </span>
        ))}
      </div>

      <div className="mt-4 px-5">
        <p className="mb-2 font-display text-sm">Paint</p>
        <div className="flex gap-2">
          {palette.map((c) => (
            <button
              key={c}
              type="button"
              onClick={() => setPaint(c)}
              className={`h-9 w-9 rounded-full ${paint === c ? 'ring-2 ring-[var(--ink)] ring-offset-2' : ''}`}
              style={{ background: c }}
            />
          ))}
          <button
            type="button"
            onClick={() => setBranchColors(['#ff9f43', '#c08a5a', '#ff7a59'])}
            className="flex h-9 w-9 items-center justify-center rounded-full bg-white shadow-sm"
          >
            <Eraser size={14} />
          </button>
        </div>

        <p className="mb-2 mt-4 flex items-center gap-1 font-display text-sm">
          <Sticker size={14} /> Stickers
        </p>
        <div className="flex gap-2">
          {stickers.map((s) => (
            <button
              key={s}
              type="button"
              onClick={() => setSticker(s)}
              className={`flex h-11 w-11 items-center justify-center rounded-2xl bg-white text-xl shadow-sm ${
                sticker === s ? 'ring-2 ring-[var(--leaf)]' : ''
              }`}
            >
              {s}
            </button>
          ))}
        </div>
        <p className="mt-3 text-center text-xs text-[var(--ink-soft)]">
          Tap a branch to paint · tap canvas to place sticker
        </p>
      </div>
    </div>
  )
}
