export type ScreenId =
  | 'home'
  | 'mindmap'
  | 'connect'
  | 'pop'
  | 'pet'
  | 'color'
  | 'parent'
  | 'voice'
  | 'context'
  | 'context-map'
  | 'context-review'

export interface VocabNode {
  id: string
  word: string
  emoji: string
  color: string
  x: number
  y: number
  soundHint?: string
  children?: VocabNode[]
}

export interface MindmapTopic {
  id: string
  title: string
  emoji: string
  subtitle: string
  progress: number
  unlocked: boolean
  accent: string
  root: VocabNode
}

export const topics: MindmapTopic[] = [
  {
    id: 'family',
    title: 'My Family',
    emoji: '🏠',
    subtitle: 'People I love',
    progress: 62,
    unlocked: true,
    accent: '#ff9f43',
    root: {
      id: 'family-root',
      word: 'My Family',
      emoji: '🏠',
      color: '#ff9f43',
      x: 50,
      y: 18,
      children: [
        {
          id: 'grandparents',
          word: 'Grandparents',
          emoji: '👴',
          color: '#c08a5a',
          x: 22,
          y: 38,
          children: [
            {
              id: 'grandfather',
              word: 'Grandfather',
              emoji: '👴',
              color: '#a67c52',
              x: 10,
              y: 58,
              soundHint: 'Gran-fa-ther',
            },
            {
              id: 'grandmother',
              word: 'Grandmother',
              emoji: '👵',
              color: '#d4a574',
              x: 28,
              y: 62,
              soundHint: 'Gran-mo-ther',
            },
          ],
        },
        {
          id: 'parents',
          word: 'Parents',
          emoji: '👨‍👩‍👧',
          color: '#ff7a59',
          x: 72,
          y: 36,
          children: [
            {
              id: 'father',
              word: 'Father',
              emoji: '👨',
              color: '#4a90d9',
              x: 62,
              y: 56,
              soundHint: 'Fa-ther',
            },
            {
              id: 'mother',
              word: 'Mother',
              emoji: '👩',
              color: '#e86a8a',
              x: 84,
              y: 54,
              soundHint: 'Mo-ther',
              children: [
                {
                  id: 'cooks',
                  word: 'Cooks',
                  emoji: '🍳',
                  color: '#f0a020',
                  x: 74,
                  y: 74,
                  soundHint: 'Cooks',
                },
                {
                  id: 'smiles',
                  word: 'Smiles',
                  emoji: '😊',
                  color: '#ffc94a',
                  x: 92,
                  y: 76,
                  soundHint: 'Smiles',
                },
                {
                  id: 'kind',
                  word: 'Kind',
                  emoji: '💛',
                  color: '#3ecf9a',
                  x: 84,
                  y: 88,
                  soundHint: 'Kind',
                },
              ],
            },
          ],
        },
      ],
    },
  },
  {
    id: 'animals',
    title: 'Animals',
    emoji: '🐾',
    subtitle: 'Pets · Wild · Sea',
    progress: 28,
    unlocked: true,
    accent: '#3ecf9a',
    root: {
      id: 'animals-root',
      word: 'Animals',
      emoji: '🌍',
      color: '#1b8a6b',
      x: 50,
      y: 20,
      children: [
        {
          id: 'pets',
          word: 'Pets',
          emoji: '🐕',
          color: '#ff8f6b',
          x: 20,
          y: 42,
          children: [
            {
              id: 'dog',
              word: 'Dog',
              emoji: '🐶',
              color: '#ff8f6b',
              x: 10,
              y: 64,
              soundHint: 'Dog · Woof!',
            },
            {
              id: 'cat',
              word: 'Cat',
              emoji: '🐱',
              color: '#ffa07a',
              x: 28,
              y: 70,
              soundHint: 'Cat · Meow!',
            },
          ],
        },
        {
          id: 'wild',
          word: 'Wild',
          emoji: '🦁',
          color: '#5ecf8a',
          x: 50,
          y: 48,
          children: [
            {
              id: 'elephant',
              word: 'Elephant',
              emoji: '🐘',
              color: '#7ab8a0',
              x: 42,
              y: 72,
              soundHint: 'El-e-phant',
            },
            {
              id: 'lion',
              word: 'Lion',
              emoji: '🦁',
              color: '#e8b84a',
              x: 58,
              y: 68,
              soundHint: 'Li-on',
            },
          ],
        },
        {
          id: 'sea',
          word: 'Sea',
          emoji: '🐠',
          color: '#4db8e8',
          x: 80,
          y: 42,
          children: [
            {
              id: 'fish',
              word: 'Fish',
              emoji: '🐟',
              color: '#4db8e8',
              x: 74,
              y: 66,
              soundHint: 'Fish',
            },
            {
              id: 'whale',
              word: 'Whale',
              emoji: '🐋',
              color: '#2a9fd8',
              x: 90,
              y: 64,
              soundHint: 'Whale',
            },
          ],
        },
      ],
    },
  },
  {
    id: 'fruits',
    title: 'Fruits',
    emoji: '🍎',
    subtitle: 'Sweet & juicy',
    progress: 0,
    unlocked: true,
    accent: '#ff6b4a',
    root: {
      id: 'fruits-root',
      word: 'Fruits',
      emoji: '🌳',
      color: '#1b8a6b',
      x: 50,
      y: 22,
      children: [
        {
          id: 'apple',
          word: 'Apple',
          emoji: '🍎',
          color: '#ff6b4a',
          x: 25,
          y: 55,
          soundHint: 'Ap-ple',
        },
        {
          id: 'banana',
          word: 'Banana',
          emoji: '🍌',
          color: '#ffc94a',
          x: 50,
          y: 62,
          soundHint: 'Ba-na-na',
        },
        {
          id: 'orange',
          word: 'Orange',
          emoji: '🍊',
          color: '#ff9f43',
          x: 75,
          y: 55,
          soundHint: 'Or-ange',
        },
      ],
    },
  },
  {
    id: 'colors',
    title: 'Colors',
    emoji: '🎨',
    subtitle: 'Paint the world',
    progress: 0,
    unlocked: false,
    accent: '#a78bfa',
    root: {
      id: 'colors-root',
      word: 'Colors',
      emoji: '🎨',
      color: '#2a9fd8',
      x: 50,
      y: 40,
    },
  },
]

export const connectItems = [
  { id: 'c1', emoji: '🍎', word: 'Apple', branch: 'Fruits', branchColor: '#ff6b4a' },
  { id: 'c2', emoji: '🐶', word: 'Dog', branch: 'Pets', branchColor: '#ff8f6b' },
  { id: 'c3', emoji: '🐟', word: 'Fish', branch: 'Sea', branchColor: '#4db8e8' },
  { id: 'c4', emoji: '🦁', word: 'Lion', branch: 'Wild', branchColor: '#5ecf8a' },
]

export const popTargets = [
  { id: 'p1', emoji: '🐘', word: 'Elephant' },
  { id: 'p2', emoji: '🐶', word: 'Dog' },
  { id: 'p3', emoji: '🐱', word: 'Cat' },
  { id: 'p4', emoji: '🐋', word: 'Whale' },
  { id: 'p5', emoji: '🦁', word: 'Lion' },
  { id: 'p6', emoji: '🐟', word: 'Fish' },
]

export function flattenNodes(node: VocabNode): VocabNode[] {
  const list: VocabNode[] = [node]
  node.children?.forEach((child) => list.push(...flattenNodes(child)))
  return list
}

export function getEdges(node: VocabNode): { from: VocabNode; to: VocabNode }[] {
  const edges: { from: VocabNode; to: VocabNode }[] = []
  node.children?.forEach((child) => {
    edges.push({ from: node, to: child })
    edges.push(...getEdges(child))
  })
  return edges
}
