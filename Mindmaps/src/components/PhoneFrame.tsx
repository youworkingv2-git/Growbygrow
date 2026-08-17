import type { ReactNode } from 'react'

interface PhoneFrameProps {
  children: ReactNode
}

export function PhoneFrame({ children }: PhoneFrameProps) {
  return (
    <div className="flex min-h-svh items-center justify-center p-4 sm:p-8">
      <div className="relative w-full max-w-[390px]">
        <div
          className="absolute -inset-3 rounded-[3rem] opacity-40 blur-2xl"
          style={{
            background:
              'linear-gradient(135deg, #ffc94a 0%, #3ecf9a 45%, #4db8e8 100%)',
          }}
        />
        <div className="relative overflow-hidden rounded-[2.4rem] border-[5px] border-[#1a3a44] bg-[#14353f] shadow-[0_25px_60px_rgba(20,53,63,0.35)]">
          {/* Dynamic island */}
          <div className="pointer-events-none absolute left-1/2 top-2.5 z-50 h-6 w-[108px] -translate-x-1/2 rounded-full bg-[#0d242c]" />
          <div className="relative h-[min(844px,92svh)] overflow-hidden bg-[var(--cream)]">
            {children}
          </div>
          {/* Home indicator */}
          <div className="pointer-events-none absolute bottom-1.5 left-1/2 z-50 h-1 w-28 -translate-x-1/2 rounded-full bg-white/40" />
        </div>
        <p className="mt-4 text-center font-display text-sm text-[var(--ink-soft)]">
          MindWord World · Mobile preview
        </p>
      </div>
    </div>
  )
}
