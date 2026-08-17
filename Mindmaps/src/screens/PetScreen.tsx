import { useState } from 'react'
import { motion } from 'framer-motion'
import { Shirt, Cookie, Sparkles } from 'lucide-react'

const outfits = [
  { id: 'scarf', emoji: '🧣', label: 'Scarf', owned: true },
  { id: 'hat', emoji: '🎩', label: 'Hat', owned: true },
  { id: 'glasses', emoji: '👓', label: 'Glasses', owned: false },
  { id: 'cape', emoji: '🦸', label: 'Cape', owned: false },
]

export function PetScreen() {
  const [hunger, setHunger] = useState(68)
  const [outfit, setOutfit] = useState('scarf')
  const [fed, setFed] = useState(false)

  const feed = () => {
    setHunger((h) => Math.min(100, h + 18))
    setFed(true)
    setTimeout(() => setFed(false), 1200)
  }

  return (
    <div className="relative h-full overflow-hidden bg-gradient-to-b from-[#b8ebe0] via-[#e8f7d9] to-[#ffe9b8] pb-24">
      <header className="px-5 pt-12">
        <p className="font-display text-xs uppercase tracking-widest text-[var(--leaf)]">
          Companion
        </p>
        <h1 className="font-display text-3xl text-[var(--ink)]">Mindy the Fox</h1>
        <p className="text-sm text-[var(--ink-soft)]">
          Finish mindmaps to earn food & outfits
        </p>
      </header>

      <div className="relative mt-4 flex flex-col items-center">
        <div className="absolute h-40 w-56 rounded-full bg-white/50 blur-xl" />
        <motion.div
          className="relative z-10 text-[110px] leading-none"
          animate={fed ? { scale: [1, 1.15, 1], y: [0, -12, 0] } : { y: [0, -8, 0] }}
          transition={{ duration: fed ? 0.6 : 3, repeat: fed ? 0 : Infinity }}
        >
          🦊
        </motion.div>
        {outfit === 'scarf' && (
          <span className="absolute bottom-[42px] z-20 text-3xl">🧣</span>
        )}
        {outfit === 'hat' && (
          <span className="absolute top-2 z-20 text-4xl">🎩</span>
        )}
        {fed && (
          <motion.div
            className="absolute -top-1 right-16 z-20 font-display text-lg text-[var(--coral)]"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: -20 }}
          >
            Yum! +18
          </motion.div>
        )}
      </div>

      <div className="mx-5 mt-2 rounded-3xl bg-white/90 p-4 shadow-lg">
        <div className="mb-1 flex items-center justify-between">
          <span className="font-display text-sm">Energy</span>
          <span className="text-xs font-bold text-[var(--ink-soft)]">{hunger}%</span>
        </div>
        <div className="h-3 overflow-hidden rounded-full bg-[var(--ink)]/8">
          <motion.div
            className="h-full rounded-full bg-gradient-to-r from-[var(--leaf)] to-[var(--sun)]"
            animate={{ width: `${hunger}%` }}
          />
        </div>

        <button
          type="button"
          onClick={feed}
          className="mt-4 flex w-full items-center justify-center gap-2 rounded-2xl bg-[var(--coral)] py-3.5 font-display text-white shadow-[0_10px_22px_rgba(255,107,74,0.35)]"
        >
          <Cookie size={18} /> Feed treat
        </button>
      </div>

      <section className="mt-4 px-5">
        <div className="mb-2 flex items-center gap-2">
          <Shirt size={16} className="text-[var(--ocean)]" />
          <h2 className="font-display text-lg">Wardrobe</h2>
        </div>
        <div className="grid grid-cols-4 gap-2">
          {outfits.map((o) => (
            <button
              key={o.id}
              type="button"
              disabled={!o.owned}
              onClick={() => o.owned && setOutfit(o.id)}
              className={`rounded-2xl bg-white/90 p-2 text-center shadow-sm ${
                outfit === o.id ? 'ring-2 ring-[var(--leaf)]' : ''
              } ${!o.owned ? 'opacity-45' : ''}`}
            >
              <span className="text-2xl">{o.owned ? o.emoji : '🔒'}</span>
              <p className="mt-1 text-[10px] font-bold">{o.label}</p>
            </button>
          ))}
        </div>
        <p className="mt-3 flex items-center gap-1 text-xs text-[var(--ink-soft)]">
          <Sparkles size={12} className="text-[var(--sun-deep)]" />
          Complete Fruits mindmap to unlock Glasses
        </p>
      </section>
    </div>
  )
}
