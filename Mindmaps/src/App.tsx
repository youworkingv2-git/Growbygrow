import { useState } from 'react'
import { AnimatePresence, motion } from 'framer-motion'
import { PhoneFrame } from './components/PhoneFrame'
import { BottomNav } from './components/BottomNav'
import { HomeScreen } from './screens/HomeScreen'
import { MindmapScreen } from './screens/MindmapScreen'
import { ConnectGameScreen } from './screens/ConnectGameScreen'
import { PopGameScreen } from './screens/PopGameScreen'
import { PetScreen } from './screens/PetScreen'
import { ColorModeScreen } from './screens/ColorModeScreen'
import { VoiceScreen } from './screens/VoiceScreen'
import { ParentScreen } from './screens/ParentScreen'
import { ContextInputScreen } from './screens/ContextInputScreen'
import { ContextMindmapScreen } from './screens/ContextMindmapScreen'
import { ContextReviewScreen } from './screens/ContextReviewScreen'
import { topics, type ScreenId } from './data/mindmaps'
import type { ContextMapResult } from './data/contextMap'

export default function App() {
  const [screen, setScreen] = useState<ScreenId>('home')
  const [topicId, setTopicId] = useState('family')
  const [contextMap, setContextMap] = useState<ContextMapResult | null>(null)

  const topic = topics.find((t) => t.id === topicId) ?? topics[0]

  const openTopic = (id: string) => {
    setTopicId(id)
    setScreen('mindmap')
  }

  const goHomeish = () => setScreen('home')

  const showNav = [
    'home',
    'mindmap',
    'pet',
    'parent',
    'color',
    'voice',
    'context',
    'context-map',
  ].includes(screen)

  return (
    <PhoneFrame>
      <div className="relative h-full">
        <AnimatePresence mode="wait">
          <motion.div
            key={screen + topicId + (contextMap?.id ?? '')}
            className="h-full"
            initial={{ opacity: 0, x: 18 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -12 }}
            transition={{ duration: 0.22 }}
          >
            {screen === 'home' && (
              <HomeScreen
                topics={topics}
                streak={5}
                onOpenTopic={openTopic}
                onNavigate={setScreen}
              />
            )}
            {screen === 'mindmap' && (
              <MindmapScreen
                topic={topic}
                onBack={goHomeish}
                onNavigate={setScreen}
              />
            )}
            {screen === 'connect' && (
              <ConnectGameScreen onBack={() => setScreen('mindmap')} onNavigate={setScreen} />
            )}
            {screen === 'pop' && (
              <PopGameScreen onBack={() => setScreen('mindmap')} onNavigate={setScreen} />
            )}
            {screen === 'pet' && <PetScreen />}
            {screen === 'color' && (
              <ColorModeScreen onBack={() => setScreen('mindmap')} onNavigate={setScreen} />
            )}
            {screen === 'voice' && <VoiceScreen onBack={() => setScreen('mindmap')} />}
            {screen === 'parent' && <ParentScreen />}
            {screen === 'context' && (
              <ContextInputScreen
                onGenerate={(result) => {
                  setContextMap(result)
                  setScreen('context-map')
                }}
              />
            )}
            {screen === 'context-map' && contextMap && (
              <ContextMindmapScreen
                map={contextMap}
                onBack={() => setScreen('context')}
                onReview={() => setScreen('context-review')}
                onRegenerate={() => setScreen('context')}
              />
            )}
            {screen === 'context-review' && contextMap && (
              <ContextReviewScreen
                map={contextMap}
                onBack={() => setScreen('context-map')}
                onDone={() => setScreen('context-map')}
              />
            )}
          </motion.div>
        </AnimatePresence>

        {showNav && <BottomNav active={screen} onNavigate={setScreen} />}
      </div>
    </PhoneFrame>
  )
}
