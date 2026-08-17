import { motion } from 'framer-motion'
import { Clock, TreePine, TrendingUp } from 'lucide-react'

const days = [
  { d: 'Mon', m: 16 },
  { d: 'Tue', m: 12 },
  { d: 'Wed', m: 18 },
  { d: 'Thu', m: 8 },
  { d: 'Fri', m: 15 },
  { d: 'Sat', m: 20 },
  { d: 'Sun', m: 10 },
]

export function ParentScreen() {
  return (
    <div className="phone-scroll relative h-full overflow-y-auto bg-gradient-to-b from-[#e8f4f8] to-[#f7f3ea] pb-28">
      <header className="px-5 pt-12">
        <p className="font-display text-xs uppercase tracking-widest text-[var(--ocean)]">
          Parent zone
        </p>
        <h1 className="font-display text-3xl text-[var(--ink)]">Calm progress</h1>
        <p className="text-sm text-[var(--ink-soft)]">
          15–20 min / day · tree chart, not overwhelm
        </p>
      </header>

      <section className="mx-5 mt-4 rounded-3xl bg-white p-4 shadow-md">
        <div className="flex items-center gap-2">
          <Clock size={18} className="text-[var(--coral)]" />
          <h2 className="font-display text-lg">Daily limit</h2>
        </div>
        <div className="mt-3 flex items-end justify-between">
          <div>
            <p className="font-display text-4xl text-[var(--leaf)]">18</p>
            <p className="text-xs text-[var(--ink-soft)]">minutes remaining today</p>
          </div>
          <div className="text-right">
            <p className="font-display text-lg">20 min</p>
            <p className="text-xs text-[var(--ink-soft)]">soft cap</p>
          </div>
        </div>
        <div className="mt-3 h-3 overflow-hidden rounded-full bg-[var(--ink)]/8">
          <div className="h-full w-[10%] rounded-full bg-[var(--coral)]" />
        </div>
        <p className="mt-2 text-[11px] text-[var(--ink-soft)]">
          Auto pause with a friendly “see you tomorrow” screen
        </p>
      </section>

      <section className="mx-5 mt-4 rounded-3xl bg-white p-4 shadow-md">
        <div className="mb-3 flex items-center gap-2">
          <TreePine size={18} className="text-[var(--leaf)]" />
          <h2 className="font-display text-lg">Growth tree</h2>
        </div>
        <div className="flex h-40 items-end justify-between gap-2 px-1">
          {days.map((day, i) => (
            <div key={day.d} className="flex flex-1 flex-col items-center gap-1">
              <motion.div
                className="w-full origin-bottom rounded-t-xl bg-gradient-to-b from-[var(--leaf-light)] to-[var(--leaf)]"
                style={{ height: `${(day.m / 20) * 120}px` }}
                initial={{ scaleY: 0 }}
                animate={{ scaleY: 1 }}
                transition={{ delay: i * 0.05 }}
              />
              <span className="text-[10px] font-bold text-[var(--ink-soft)]">{day.d}</span>
            </div>
          ))}
        </div>
        <p className="mt-2 text-center text-xs text-[var(--ink-soft)]">
          Minutes practiced this week — shaped like growing trunks
        </p>
      </section>

      <section className="mx-5 mt-4 mb-4 rounded-3xl bg-white p-4 shadow-md">
        <div className="mb-2 flex items-center gap-2">
          <TrendingUp size={18} className="text-[var(--sun-deep)]" />
          <h2 className="font-display text-lg">This week</h2>
        </div>
        <ul className="space-y-2 text-sm">
          <li className="flex justify-between rounded-2xl bg-[var(--ground)] px-3 py-2">
            <span>Words discovered</span>
            <span className="font-display">24</span>
          </li>
          <li className="flex justify-between rounded-2xl bg-[var(--ground)] px-3 py-2">
            <span>Magic Voice avg</span>
            <span className="font-display">86%</span>
          </li>
          <li className="flex justify-between rounded-2xl bg-[var(--ground)] px-3 py-2">
            <span>Mini-games won</span>
            <span className="font-display">7</span>
          </li>
        </ul>
      </section>
    </div>
  )
}
