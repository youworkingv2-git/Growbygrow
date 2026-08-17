import { motion } from 'framer-motion'
import type { VocabNode } from '../data/mindmaps'

interface MindmapNodeProps {
  node: VocabNode
  expanded: boolean
  discovered: boolean
  isRoot?: boolean
  onTap: (node: VocabNode) => void
  onHold: (node: VocabNode) => void
}

export function MindmapNodeView({
  node,
  expanded,
  discovered,
  isRoot,
  onTap,
  onHold,
}: MindmapNodeProps) {
  let holdTimer: ReturnType<typeof setTimeout> | null = null

  return (
    <motion.button
      type="button"
      layout
      initial={{ scale: 0, opacity: 0 }}
      animate={{
        scale: discovered ? 1 : 0.85,
        opacity: 1,
        y: expanded ? [0, -4, 0] : 0,
      }}
      transition={{ type: 'spring', stiffness: 380, damping: 22 }}
      className={`absolute z-10 flex -translate-x-1/2 -translate-y-1/2 flex-col items-center ${
        discovered ? '' : 'opacity-70'
      }`}
      style={{ left: `${node.x}%`, top: `${node.y}%` }}
      onClick={() => onTap(node)}
      onPointerDown={() => {
        holdTimer = setTimeout(() => onHold(node), 520)
      }}
      onPointerUp={() => {
        if (holdTimer) clearTimeout(holdTimer)
      }}
      onPointerLeave={() => {
        if (holdTimer) clearTimeout(holdTimer)
      }}
    >
      <div
        className={`relative flex items-center justify-center rounded-full shadow-[0_8px_20px_rgba(20,53,63,0.18)] ${
          isRoot ? 'h-[78px] w-[78px]' : 'h-[58px] w-[58px]'
        } ${expanded ? 'pulse-ring animate-wiggle' : ''}`}
        style={{
          background: `linear-gradient(145deg, ${node.color}, ${node.color}cc)`,
          color: node.color,
          boxShadow: discovered
            ? `0 0 0 3px white, 0 8px 18px ${node.color}55`
            : undefined,
        }}
      >
        <span className={isRoot ? 'text-4xl' : 'text-[28px]'}>{node.emoji}</span>
      </div>
      <span
        className={`mt-1.5 max-w-[88px] rounded-full px-2 py-0.5 text-center font-display leading-tight ${
          isRoot ? 'bg-white/90 text-[13px] text-[var(--ink)]' : 'bg-white/80 text-[11px] text-[var(--ink)]'
        }`}
      >
        {node.word}
      </span>
    </motion.button>
  )
}
