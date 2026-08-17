import { useEffect, useState } from 'react'
import { motion, useReducedMotion } from 'framer-motion'
import './App.css'

const guideSteps = [
  {
    title: 'Nạp tài liệu đầu vào',
    description:
      'Đưa bất kỳ nội dung tiếng Anh nào bạn đang học hoặc dùng hàng ngày vào ContextMap AI.',
    points: [
      'Dán bài báo (BBC, CNN, Forbes), email công việc, PDF chuyên ngành hoặc bài IELTS Reading.',
      'Dán link YouTube / TED Talks / Podcast để AI lấy transcript.',
      'Chụp ảnh sách hoặc tài liệu (OCR) khi không có bản số.',
    ],
    preview: {
      label: 'Đầu vào',
      main: 'Paste text · Link · Camera OCR',
      sub: 'Hỗ trợ bài dài ~1.000 từ trở lên',
      chips: ['IELTS Reading', 'Email công việc', 'TED Talk'],
    },
  },
  {
    title: 'AI tạo Mindmap ngôn ngữ chuyên sâu',
    description:
      'Trong vài giây, AI phân tích và dựng sơ đồ cấu trúc ngôn ngữ — không chỉ tóm tắt nội dung.',
    points: [
      'Main Ideas: ý chính & khái niệm cốt lõi của bài.',
      'Advanced Vocab: từ B2–C2, collocations nguyên cụm, synonyms để paraphrase.',
      'Grammar & Patterns: đảo ngữ, mệnh đề phức, academic transitions.',
    ],
    preview: {
      label: 'Mindmap',
      main: '3 nhánh ngôn ngữ nâng cao',
      sub: 'make an informed decision · Inversion · Collocations',
      chips: ['C1/C2 Words', 'Collocations', 'Grammar'],
    },
  },
  {
    title: 'Đọc tương tác Split-screen',
    description:
      'Vừa đọc bài gốc / xem video, vừa theo dõi mindmap — học từ trong đúng ngữ cảnh.',
    points: [
      'Màn hình chia đôi: tài liệu gốc bên trái, mindmap bên phải.',
      'Chạm một nhánh mindmap → highlight vị trí xuất hiện trong bài.',
      'Giữ nguyên ngữ cảnh thật thay vì học từ rời rạc.',
    ],
    preview: {
      label: 'Interactive Reader',
      main: 'Click nhánh → tô sáng trong bài',
      sub: 'Học collocation đúng chỗ nó xuất hiện',
      chips: ['Highlight', 'Split view', 'Context'],
    },
  },
  {
    title: 'Ôn tập ngắt quãng (Spaced Repetition)',
    description:
      'Mindmap giúp hiểu nhanh; flashcards + đường cong quên giúp nhớ lâu.',
    points: [
      'AI tự tách nhánh vocab/collocation thành flashcards dạng sơ đồ.',
      'Nhắc ôn mỗi ngày theo forgetting curve.',
      'Xuất sang Anki nếu bạn đã có thói quen ôn tập sẵn.',
    ],
    preview: {
      label: 'SRS',
      main: 'Mindmap → Flashcards tự động',
      sub: 'Nhắc lại đúng lúc não sắp quên',
      chips: ['Flashcards', 'Anki export', 'Daily review'],
    },
  },
  {
    title: 'Luyện Writing / Speaking từ mindmap',
    description:
      'Sau khi nắm sơ đồ, luyện ngay kỹ năng sản xuất với đề bài gắn với bài vừa học.',
    points: [
      'Bấm Practice Writing/Speaking — AI tạo đề dựa trên mindmap.',
      'Viết đoạn văn hoặc thu âm, bắt buộc dùng collocations vừa học.',
      'AI chấm điểm, chỉnh lỗi và gợi ý paraphrase ngay lập tức.',
    ],
    preview: {
      label: 'Output Practice',
      main: 'Viết / Nói → AI feedback',
      sub: 'Áp dụng collocation vào đề IELTS & công việc',
      chips: ['Writing', 'Speaking', 'Scoring'],
    },
  },
]

function LogoMark({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 32 32" fill="none" aria-hidden>
      <rect width="32" height="32" rx="8" fill="#0B3D3A" />
      <circle cx="16" cy="10" r="3" fill="#F0C75E" />
      <path
        d="M16 13v6M10 24l6-5 6 5"
        stroke="#E8F2F0"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <circle cx="10" cy="24" r="2" fill="#7EC8B8" />
      <circle cx="22" cy="24" r="2" fill="#7EC8B8" />
    </svg>
  )
}

function HeroMindmap() {
  const reduce = useReducedMotion()
  const fade = (delay: number) =>
    reduce
      ? {}
      : {
          initial: { opacity: 0, y: 12 },
          animate: { opacity: 1, y: 0 },
          transition: { duration: 0.55, delay, ease: [0.22, 1, 0.36, 1] as const },
        }

  return (
    <div className="mindmap-stage" aria-hidden>
      <svg className="mm-lines" viewBox="0 0 400 360" preserveAspectRatio="xMidYMid meet">
        <motion.path
          d="M200 55 L70 160"
          initial={reduce ? undefined : { pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ duration: 0.9, delay: 0.35 }}
        />
        <motion.path
          d="M200 55 L200 175"
          initial={reduce ? undefined : { pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ duration: 0.9, delay: 0.45 }}
        />
        <motion.path
          d="M200 55 L330 160"
          initial={reduce ? undefined : { pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ duration: 0.9, delay: 0.55 }}
        />
        <motion.path
          d="M70 175 L40 255"
          initial={reduce ? undefined : { pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ duration: 0.7, delay: 0.8 }}
        />
        <motion.path
          d="M200 195 L200 275"
          initial={reduce ? undefined : { pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ duration: 0.7, delay: 0.9 }}
        />
        <motion.path
          d="M330 175 L360 255"
          initial={reduce ? undefined : { pathLength: 0, opacity: 0 }}
          animate={{ pathLength: 1, opacity: 1 }}
          transition={{ duration: 0.7, delay: 1 }}
        />
      </svg>

      <motion.div className="mm-node mm-root" {...fade(0.15)}>
        Bài báo / Tài liệu
      </motion.div>
      <motion.div className="mm-node mm-branch mm-ideas" {...fade(0.4)}>
        Main Ideas
      </motion.div>
      <motion.div className="mm-node mm-branch mm-vocab" {...fade(0.5)}>
        Advanced Vocab
      </motion.div>
      <motion.div className="mm-node mm-branch mm-grammar" {...fade(0.6)}>
        Grammar
      </motion.div>
      <motion.div className="mm-node mm-leaf mm-l1" {...fade(0.85)}>
        Core concepts
      </motion.div>
      <motion.div className="mm-node mm-leaf mm-l2" {...fade(0.95)}>
        Collocations + Synonyms
      </motion.div>
      <motion.div className="mm-node mm-leaf mm-l3" {...fade(1.05)}>
        Complex patterns
      </motion.div>
    </div>
  )
}

export default function App() {
  const [scrolled, setScrolled] = useState(false)
  const reduce = useReducedMotion()

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <>
      <header className={`nav${scrolled ? ' scrolled' : ''}`}>
        <div className="container nav-inner">
          <a href="#top" className="logo">
            <LogoMark className="logo-mark" />
            ContextMap AI
          </a>
          <nav aria-label="Điều hướng chính">
            <ul className="nav-links">
              <li>
                <a href="#huong-dan">Hướng dẫn</a>
              </li>
              <li>
                <a href="#tinh-nang">Tính năng</a>
              </li>
            </ul>
          </nav>
          <a className="nav-cta" href="#huong-dan">
            Bắt đầu học
          </a>
        </div>
      </header>

      <main id="top">
        <section className="hero">
          <div className="container hero-grid">
            <div className="hero-copy">
              <motion.span
                className="hero-brand display"
                initial={reduce ? false : { opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
              >
                ContextMap AI
              </motion.span>
              <motion.h1
                className="display"
                initial={reduce ? false : { opacity: 0, y: 18 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.08, ease: [0.22, 1, 0.36, 1] }}
              >
                Biến đoạn văn & video thành mindmap học tiếng Anh
              </motion.h1>
              <motion.p
                className="hero-lead"
                initial={reduce ? false : { opacity: 0, y: 18 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.16, ease: [0.22, 1, 0.36, 1] }}
              >
                Dành cho Intermediate+: tiết kiệm thời gian tổng hợp tài liệu IELTS,
                TOEIC và công việc — học collocation & ngữ pháp đúng ngữ cảnh.
              </motion.p>
              <motion.div
                className="hero-actions"
                initial={reduce ? false : { opacity: 0, y: 18 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: 0.24, ease: [0.22, 1, 0.36, 1] }}
              >
                <a className="btn-primary" href="#huong-dan">
                  Xem hướng dẫn sử dụng
                </a>
                <a className="btn-ghost" href="#tinh-nang">
                  Tính năng nổi bật
                </a>
              </motion.div>
            </div>
            <div className="hero-visual">
              <HeroMindmap />
            </div>
          </div>
        </section>

        <section id="huong-dan" className="section guide" aria-labelledby="guide-title">
          <div className="container">
            <header className="guide-header">
              <span className="section-label">Hướng dẫn sử dụng</span>
              <h2 id="guide-title" className="section-title display">
                Từ tài liệu dài đến bài học trong 5 bước
              </h2>
              <p className="section-lead">
                Làm theo tuần tự dưới đây để biến bài báo, email hay video yêu thích
                thành mindmap + flashcards + bài luyện Writing/Speaking.
              </p>
            </header>

            <ol className="guide-steps">
              {guideSteps.map((step, i) => (
                <motion.li
                  key={step.title}
                  className="guide-step"
                  initial={reduce ? false : { opacity: 0, y: 24 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true, margin: '-60px' }}
                  transition={{
                    duration: 0.5,
                    delay: reduce ? 0 : i * 0.06,
                    ease: [0.22, 1, 0.36, 1],
                  }}
                >
                  <div className="step-num" aria-hidden />
                  <div className="step-body">
                    <h3>{step.title}</h3>
                    <p>{step.description}</p>
                    <ul>
                      {step.points.map((point) => (
                        <li key={point}>{point}</li>
                      ))}
                    </ul>
                  </div>
                  <aside className="step-preview" aria-hidden>
                    <span className="preview-label">{step.preview.label}</span>
                    <span className="preview-main">{step.preview.main}</span>
                    <span className="preview-sub">{step.preview.sub}</span>
                    <div className="preview-chips">
                      {step.preview.chips.map((chip) => (
                        <span key={chip}>{chip}</span>
                      ))}
                    </div>
                  </aside>
                </motion.li>
              ))}
            </ol>

            <div className="guide-tip">
              <strong>Mẹo cho người luyện thi IELTS / TOEIC</strong>
              <p>
                Ưu tiên nạp đúng dạng đề bạn đang luyện (Reading Passage, Listening
                script, Writing sample). Sau mỗi mindmap, dành 10–15 phút Practice
                Writing/Speaking — AI sẽ bắt bạn dùng collocation vừa học, giúp chuyển
                từ “hiểu thụ động” sang “dùng chủ động”.
              </p>
            </div>
          </div>
        </section>

        <section id="tinh-nang" className="section features" aria-labelledby="features-title">
          <div className="container">
            <span className="section-label">Điểm ăn tiền</span>
            <h2 id="features-title" className="section-title display">
              Ba tính năng giữ bạn quay lại mỗi ngày
            </h2>
            <p className="section-lead">
              Không soạn tay. Không học từ rời. Học đúng thứ bạn cần cho thi cử và công việc.
            </p>
            <div className="feature-list">
              <article className="feature-item">
                <h3>Interactive Mindmap Reader</h3>
                <p>
                  Split-screen đọc gốc + mindmap; chạm nhánh là highlight đúng chỗ
                  collocation xuất hiện trong ngữ cảnh thật.
                </p>
              </article>
              <article className="feature-item">
                <h3>Mindmap → Spaced Repetition</h3>
                <p>
                  Tự phân rã sơ đồ thành flashcards và nhắc ôn theo đường cong quên —
                  hiểu nhanh, nhớ lâu.
                </p>
              </article>
              <article className="feature-item">
                <h3>AI Output Generator</h3>
                <p>
                  Đề Writing/Speaking bám mindmap vừa học, chấm điểm và sửa lỗi ngay
                  để luyện paraphrase & academic language.
                </p>
              </article>
            </div>
          </div>
        </section>

        <section className="cta">
          <div className="container">
            <h2 className="display">Sẵn sàng học từ ngữ cảnh thật?</h2>
            <p>
              Dán một đoạn tiếng Anh bạn đang đọc — để AI dựng mindmap trong vài giây.
            </p>
            <a className="btn-primary" href="#huong-dan">
              Quay lại hướng dẫn
            </a>
          </div>
        </section>
      </main>

      <footer className="footer">
        <div className="container footer-inner">
          <a href="#top" className="logo">
            <LogoMark className="logo-mark" />
            ContextMap AI
          </a>
          <span>Contextual Learning cho Intermediate+</span>
        </div>
      </footer>
    </>
  )
}
