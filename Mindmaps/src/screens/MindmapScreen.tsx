import { useMemo, useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { ArrowLeft, Gamepad2, Palette, Trophy } from 'lucide-react'
import { MindmapNodeView } from '../components/MindmapNode'
import { PopCard } from '../components/PopCard'
import {
  flattenNodes,
  getEdges,
  type MindmapTopic,
  type ScreenId,
  type VocabNode,
} from '../data/mindmaps'

interface MindmapScreenProps {
  topic: MindmapTopic
  onBack: () => void
  onNavigate: (screen: ScreenId) => void
}

function speak(text: string) {
  if (typeof window === 'undefined' || !window.speechSynthesis) return
  window.speechSynthesis.cancel()
  const u = new SpeechSynthesisUtterance(text)
  u.lang = 'en-US'
  u.rate = 0.9
  window.speechSynthesis.speak(u)
}

export function MindmapScreen({ topic, onBack, onNavigate }: MindmapScreenProps) {
  const [expandedIds, setExpandedIds] = useState<Set<string>>(
    () => new Set([topic.root.id]),
  )
  const [active, setActive] = useState<VocabNode | null>(null)
  const [discovered, setDiscovered] = useState<Set<string>>(
    () => new Set([topic.root.id]),
  )
  const [showReward, setShowReward] = useState(false)

  const visibleNodes = useMemo(() => {
    const result: VocabNode[] = [topic.root]
    const walk = (node: VocabNode) => {
      if (!expandedIds.has(node.id) || !node.children) return
      node.children.forEach((child) => {
        result.push(child)
        walk(child)
      })
    }
    walk(topic.root)
    return result
  }, [expandedIds, topic.root])

  const edges = useMemo(() => {
    const all = getEdges(topic.root)
    const visibleIds = new Set(visibleNodes.map((n) => n.id))
    return all.filter((e) => visibleIds.has(e.from.id) && visibleIds.has(e.to.id))
  }, [topic.root, visibleNodes])

  const sentence = useMemo(() => {
    if (!active) return undefined
    if (active.id === 'cooks') return 'Mother cooks'
    if (active.id === 'smiles') return 'Mother smiles'
    if (active.id === 'kind') return 'Mother is kind'
    if (active.id === 'mother') return 'Mother'
    return undefined
  }, [active])

  const handleTap = (node: VocabNode) => {
    setActive(node)
    setDiscovered((prev) => new Set(prev).add(node.id))
    speak(node.word)

    if (node.children?.length) {
      setExpandedIds((prev) => {
        const next = new Set(prev)
        if (next.has(node.id) && node.id !== topic.root.id) {
          // collapse children only when already expanded and re-tapped root-ish
        }
        next.add(node.id)
        return next
      })
    }

    const totalLeaves = flattenNodes(topic.root).length
    const nextCount = discovered.size + (discovered.has(node.id) ? 0 : 1)
    if (nextCount >= Math.min(totalLeaves, 6) && !showReward) {
      setTimeout(() => setShowReward(true), 600)
    }
  }

  return (
    <div className="relative h-full overflow-hidden pb-24">
      <div
        className="absolute inset-0"
        style={{
          background: `linear-gradient(180deg, ${topic.accent}33 0%, #e8f7d9 42%, #fff8ef 100%)`,
        }}
      />
      {/* soft blobs */}
      <div className="pointer-events-none absolute left-[-20%] top-[30%] h-48 w-48 rounded-full bg-white/40 blur-2xl" />
      <div className="pointer-events-none absolute right-[-10%] top-[55%] h-40 w-40 rounded-full bg-[var(--sun)]/20 blur-2xl" />

      <header className="relative z-20 flex items-center gap-2 px-4 pt-12">
        <button
          type="button"
          onClick={onBack}
          className="flex h-10 w-10 items-center justify-center rounded-full bg-white/90 shadow-sm"
        >
          <ArrowLeft size={18} />
        </button>
        <div className="flex-1">
          <h1 className="font-display text-xl leading-none text-[var(--ink)]">
            {topic.title}
          </h1>
          <p className="text-xs text-[var(--ink-soft)]">Chạm & Nổ · Pop-up Mindmap</p>
        </div>
        <button
          type="button"
          onClick={() => onNavigate('color')}
          className="flex h-10 w-10 items-center justify-center rounded-full bg-white/90 shadow-sm"
        >
          <Palette size={18} className="text-[var(--sun-deep)]" />
        </button>
      </header>

      <div className="relative z-10 mx-4 mt-2 flex gap-2">
        <div className="rounded-full bg-white/80 px-3 py-1 font-display text-xs text-[var(--ink)]">
          {discovered.size} words found
        </div>
        <div className="rounded-full bg-white/80 px-3 py-1 text-xs text-[var(--ink-soft)]">
          Tap image → hear English
        </div>
      </div>

      {/* Canvas */}
      <div className="relative z-10 mx-2 mt-2 h-[58%] overflow-hidden rounded-[1.6rem] border border-white/60 bg-white/35 shadow-inner">
        <svg className="absolute inset-0 h-full w-full" aria-hidden>
          {edges.map(({ from, to }) => (
            <line
              key={`${from.id}-${to.id}`}
              x1={`${from.x}%`}
              y1={`${from.y}%`}
              x2={`${to.x}%`}
              y2={`${to.y}%`}
              stroke={to.color}
              strokeWidth="3"
              strokeLinecap="round"
              className="dotted-path"
              opacity={0.75}
            />
          ))}
        </svg>

        {visibleNodes.map((node) => (
          <MindmapNodeView
            key={node.id}
            node={node}
            isRoot={node.id === topic.root.id}
            expanded={expandedIds.has(node.id) && !!node.children?.length}
            discovered={discovered.has(node.id)}
            onTap={handleTap}
            onHold={(n) => {
              setActive(n)
              onNavigate('voice')
            }}
          />
        ))}
      </div>

      <PopCard
        node={active}
        sentence={sentence}
        onClose={() => setActive(null)}
        onSpeak={() => active && speak(active.word)}
        onRecord={() => onNavigate('voice')}
      />

      <AnimatePresence>
        {showReward && (
          <motion.div
            className="absolute inset-0 z-40 flex items-end justify-center bg-[var(--ink)]/35 px-4 pb-28"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <motion.div
              className="w-full rounded-3xl bg-white p-5 text-center shadow-2xl"
              initial={{ y: 60, scale: 0.9 }}
              animate={{ y: 0, scale: 1 }}
            >
              <div className="mx-auto mb-2 flex h-14 w-14 items-center justify-center rounded-2xl bg-[var(--sun)]/30 text-3xl">
                🎉
              </div>
              <h3 className="font-display text-2xl">Branch complete!</h3>
              <p className="mt-1 text-sm text-[var(--ink-soft)]">
                Play a mini-game or feed your pet companion
              </p>
              <div className="mt-4 grid grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => onNavigate('connect')}
                  className="flex items-center justify-center gap-2 rounded-2xl bg-[var(--leaf)] py-3 font-display text-white"
                >
                  <Gamepad2 size={16} /> Mind-Connect
                </button>
                <button
                  type="button"
                  onClick={() => onNavigate('pop')}
                  className="flex items-center justify-center gap-2 rounded-2xl bg-[var(--coral)] py-3 font-display text-white"
                >
                  <Trophy size={16} /> Pop Node
                </button>
              </div>
              <button
                type="button"
                onClick={() => setShowReward(false)}
                className="mt-3 text-sm font-bold text-[var(--ink-soft)]"
              >
                Keep exploring
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
