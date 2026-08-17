import { Home, Map, PawPrint, Sparkles } from 'lucide-react'
import type { ScreenId } from '../data/mindmaps'

interface BottomNavProps {
  active: ScreenId
  onNavigate: (screen: ScreenId) => void
}

const tabs: { id: ScreenId; label: string; icon: typeof Home }[] = [
  { id: 'home', label: 'World', icon: Home },
  { id: 'mindmap', label: 'Map', icon: Map },
  { id: 'context', label: 'Context', icon: Sparkles },
  { id: 'pet', label: 'Pet', icon: PawPrint },
]

export function BottomNav({ active, onNavigate }: BottomNavProps) {
  const contextScreens: ScreenId[] = ['context', 'context-map', 'context-review']
  const mapScreens: ScreenId[] = ['mindmap', 'color', 'voice', 'connect', 'pop']

  const isRelated =
    tabs.some((t) => t.id === active) ||
    contextScreens.includes(active) ||
    mapScreens.includes(active) ||
    active === 'parent'

  if (!isRelated) return null
  // hide nav on immersive review/games optionally — keep for context-map
  if (['connect', 'pop', 'context-review'].includes(active)) return null

  const current: ScreenId = contextScreens.includes(active)
    ? 'context'
    : mapScreens.includes(active)
      ? 'mindmap'
      : active === 'parent'
        ? 'home'
        : active

  return (
    <nav className="absolute inset-x-0 bottom-0 z-40 border-t border-white/40 bg-white/85 px-3 pb-5 pt-2 backdrop-blur-md">
      <div className="flex items-center justify-around">
        {tabs.map(({ id, label, icon: Icon }) => {
          const selected = current === id
          return (
            <button
              key={id}
              type="button"
              onClick={() => onNavigate(id)}
              className={`flex min-w-[64px] flex-col items-center gap-0.5 rounded-2xl px-3 py-1.5 transition-all ${
                selected
                  ? id === 'context'
                    ? 'bg-[#0f4c5c] text-white shadow-[0_6px_16px_rgba(15,76,92,0.4)]'
                    : 'bg-[var(--leaf)] text-white shadow-[0_6px_16px_rgba(27,138,107,0.35)]'
                  : 'text-[var(--ink-soft)]'
              }`}
            >
              <Icon size={20} strokeWidth={selected ? 2.5 : 2} />
              <span className="font-display text-[11px]">{label}</span>
            </button>
          )
        })}
      </div>
    </nav>
  )
}
