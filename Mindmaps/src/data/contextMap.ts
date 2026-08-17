export type ContextBranchKind = 'idea' | 'vocab' | 'grammar' | 'idiom'

export interface ContextLeaf {
  id: string
  term: string
  detail: string
  example?: string
  synonym?: string
  antonym?: string
  level?: 'B1' | 'B2' | 'C1'
}

export interface ContextBranch {
  id: string
  kind: ContextBranchKind
  title: string
  color: string
  icon: string
  x: number
  y: number
  leaves: ContextLeaf[]
}

export interface ContextMapResult {
  id: string
  sourceLabel: string
  sourceType: 'article' | 'email' | 'youtube' | 'tiktok' | 'lyrics'
  mainIdea: string
  summary: string
  cefr: string
  generatedAt: string
  root: {
    title: string
    color: string
  }
  branches: ContextBranch[]
}

export interface SpacedCard {
  id: string
  kind: ContextBranchKind
  front: string
  back: string
  example?: string
  dueLabel: string
  intervalDays: number
  ease: number
}

export const SAMPLE_ARTICLE = `Remote work has become a double-edged sword for modern professionals. While it offers unprecedented flexibility, many employees struggle to draw a line between office hours and personal time. Managers who fail to set clear expectations often end up burning out their teams. On the flip side, companies that embrace asynchronous communication tend to boost productivity and retain talent. Ultimately, the key takeaway is that hybrid models succeed only when trust and accountability go hand in hand.`

export const SAMPLE_YOUTUBE = `[Transcript] So today I want to break down why storytelling beats hard-selling in B2B pitches. If you come across as pushy, buyers switch off. Instead, walk them through a customer journey — the pain point, the turning point, and the outcome. That narrative sticks far longer than a feature list.`

/** Mock AI analysis — demo output for the prototype */
export function generateContextMap(
  text: string,
  sourceType: ContextMapResult['sourceType'] = 'article',
): ContextMapResult {
  const trimmed = text.trim()
  const isBiz = /remote|work|hybrid|productivity|manager/i.test(trimmed)
  const isPitch = /storytelling|pitch|buyer|narrative/i.test(trimmed)

  if (isPitch) {
    return {
      id: `cm-${Date.now()}`,
      sourceLabel: 'YouTube / TikTok transcript',
      sourceType: sourceType === 'article' ? 'youtube' : sourceType,
      mainIdea: 'Storytelling outperforms hard-selling in B2B pitches',
      summary:
        'Lead with customer journey (pain → turning point → outcome) instead of feature dumps.',
      cefr: 'B2–C1',
      generatedAt: new Date().toISOString(),
      root: { title: 'B2B Story Pitch', color: '#1b6b8a' },
      branches: [
        {
          id: 'idea',
          kind: 'idea',
          title: 'Main Idea',
          color: '#1b6b8a',
          icon: '🎯',
          x: 50,
          y: 18,
          leaves: [
            {
              id: 'i1',
              term: 'Core claim',
              detail: 'Narrative sticks longer than a feature list',
              example: 'That narrative sticks far longer than a feature list.',
              level: 'B2',
            },
          ],
        },
        {
          id: 'vocab',
          kind: 'vocab',
          title: 'Keywords',
          color: '#e07a3d',
          icon: '💎',
          x: 18,
          y: 48,
          leaves: [
            {
              id: 'v1',
              term: 'hard-selling',
              detail: 'Aggressive sales pressure',
              synonym: 'pushy selling',
              antonym: 'consultative selling',
              level: 'B2',
            },
            {
              id: 'v2',
              term: 'come across as',
              detail: 'Give an impression of being…',
              synonym: 'appear / seem',
              level: 'B2',
            },
            {
              id: 'v3',
              term: 'turning point',
              detail: 'Moment when a situation changes',
              synonym: 'watershed moment',
              level: 'B2',
            },
          ],
        },
        {
          id: 'grammar',
          kind: 'grammar',
          title: 'Grammar',
          color: '#2f9e6b',
          icon: '📐',
          x: 82,
          y: 48,
          leaves: [
            {
              id: 'g1',
              term: 'If + present, buyers…',
              detail: 'Zero/first conditional for business habits',
              example: 'If you come across as pushy, buyers switch off.',
              level: 'B1',
            },
            {
              id: 'g2',
              term: 'Imperative coaching',
              detail: 'Walk them through… — directive soft tone',
              example: 'Walk them through a customer journey.',
              level: 'B2',
            },
          ],
        },
        {
          id: 'idiom',
          kind: 'idiom',
          title: 'Idioms / Phrasals',
          color: '#7a5af8',
          icon: '🪄',
          x: 50,
          y: 78,
          leaves: [
            {
              id: 'p1',
              term: 'break down',
              detail: 'Explain something step by step',
              example: 'I want to break down why storytelling beats hard-selling.',
              level: 'B2',
            },
            {
              id: 'p2',
              term: 'switch off',
              detail: 'Stop paying attention',
              synonym: 'tune out',
              level: 'B2',
            },
          ],
        },
      ],
    }
  }

  // Default: remote work article analysis
  return {
    id: `cm-${Date.now()}`,
    sourceLabel: isBiz ? 'Article / newsletter' : 'Pasted text',
    sourceType,
    mainIdea: 'Hybrid remote work succeeds when trust meets accountability',
    summary:
      'Flexibility is valuable, but blurred boundaries cause burnout; async culture + clear expectations fix it.',
    cefr: 'B2–C1 · IELTS / Business',
    generatedAt: new Date().toISOString(),
    root: { title: 'Remote Work Trap', color: '#0f4c5c' },
    branches: [
      {
        id: 'idea',
        kind: 'idea',
        title: 'Main Idea',
        color: '#0f4c5c',
        icon: '🎯',
        x: 50,
        y: 16,
        leaves: [
          {
            id: 'i1',
            term: 'Thesis',
            detail: 'Hybrid models work only with trust + accountability',
            example: '…succeed only when trust and accountability go hand in hand.',
            level: 'C1',
          },
          {
            id: 'i2',
            term: 'Tension',
            detail: 'Flexibility vs. blurred work–life boundaries',
            level: 'B2',
          },
        ],
      },
      {
        id: 'vocab',
        kind: 'vocab',
        title: 'Keywords',
        color: '#e07a3d',
        icon: '💎',
        x: 16,
        y: 46,
        leaves: [
          {
            id: 'v1',
            term: 'unprecedented',
            detail: 'Never known or experienced before',
            synonym: 'unparalleled',
            antonym: 'ordinary',
            level: 'C1',
            example: 'unprecedented flexibility',
          },
          {
            id: 'v2',
            term: 'burn out',
            detail: 'Exhaust physically/mentally from overwork',
            synonym: 'exhaust',
            antonym: 'recharge',
            level: 'B2',
          },
          {
            id: 'v3',
            term: 'retain talent',
            detail: 'Keep skilled employees from leaving',
            synonym: 'hold on to staff',
            antonym: 'lose talent',
            level: 'B2',
          },
          {
            id: 'v4',
            term: 'key takeaway',
            detail: 'Most important lesson from a text',
            synonym: 'main point',
            level: 'B2',
          },
        ],
      },
      {
        id: 'grammar',
        kind: 'grammar',
        title: 'Grammar',
        color: '#2f9e6b',
        icon: '📐',
        x: 84,
        y: 46,
        leaves: [
          {
            id: 'g1',
            term: 'While + contrast',
            detail: 'Concession clause for balanced IELTS writing',
            example: 'While it offers flexibility, many struggle…',
            level: 'B2',
          },
          {
            id: 'g2',
            term: 'who fail to + V',
            detail: 'Relative clause + infinitive pattern',
            example: 'Managers who fail to set clear expectations…',
            level: 'B2',
          },
          {
            id: 'g3',
            term: 'tend to + V',
            detail: 'Habitual / probable behavior (formal tone)',
            example: '…tend to boost productivity',
            level: 'B1',
          },
        ],
      },
      {
        id: 'idiom',
        kind: 'idiom',
        title: 'Idioms / Phrasals',
        color: '#7a5af8',
        icon: '🪄',
        x: 50,
        y: 78,
        leaves: [
          {
            id: 'p1',
            term: 'a double-edged sword',
            detail: 'Something with both advantages and disadvantages',
            example: 'Remote work has become a double-edged sword…',
            level: 'C1',
          },
          {
            id: 'p2',
            term: 'draw a line between',
            detail: 'Create a clear boundary',
            synonym: 'set boundaries',
            level: 'B2',
          },
          {
            id: 'p3',
            term: 'on the flip side',
            detail: 'Looking at the opposite aspect',
            synonym: 'conversely',
            level: 'B2',
          },
          {
            id: 'p4',
            term: 'go hand in hand',
            detail: 'Occur together; be closely connected',
            example: 'trust and accountability go hand in hand',
            level: 'B2',
          },
        ],
      },
    ],
  }
}

export function mapToSpacedCards(map: ContextMapResult): SpacedCard[] {
  const schedule = ['Today', 'In 1 day', 'In 3 days', 'In 7 days', 'In 14 days']
  const cards: SpacedCard[] = []
  let i = 0
  for (const branch of map.branches) {
    if (branch.kind === 'idea') continue
    for (const leaf of branch.leaves) {
      cards.push({
        id: leaf.id,
        kind: branch.kind,
        front: leaf.term,
        back: leaf.detail,
        example: leaf.example ?? (leaf.synonym ? `≈ ${leaf.synonym}` : undefined),
        dueLabel: schedule[i % schedule.length],
        intervalDays: [0, 1, 3, 7, 14][i % 5],
        ease: 2.5,
      })
      i++
    }
  }
  return cards
}

export const kindMeta: Record<
  ContextBranchKind,
  { label: string; short: string }
> = {
  idea: { label: 'Main Idea', short: 'Idea' },
  vocab: { label: 'Keywords', short: 'Vocab' },
  grammar: { label: 'Grammar', short: 'Grammar' },
  idiom: { label: 'Idioms / Phrasals', short: 'Phrase' },
}
