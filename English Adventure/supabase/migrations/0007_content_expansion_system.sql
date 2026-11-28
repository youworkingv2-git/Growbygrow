-- =============================================================================
-- Prompt 09: Content Expansion System (Pre-A1 & A1 Phrases, Question Bank,
-- Content Review Status & Multi-Factor Level Unlock Tracking)
-- =============================================================================

-- 1. Common Phrases table (reusable across topics, lessons & mini-games)
CREATE TABLE IF NOT EXISTS public.learning_phrases (
  id TEXT PRIMARY KEY,
  phrase_en TEXT NOT NULL,
  meaning_vi TEXT NOT NULL,
  ipa_us TEXT NOT NULL,
  ipa_uk TEXT,
  cefr_level TEXT NOT NULL CHECK (cefr_level IN ('Pre-A1', 'A1', 'A2')),
  topic TEXT NOT NULL,
  world_id TEXT NOT NULL,
  linked_vocab_ids TEXT[] NOT NULL DEFAULT '{}',
  example_sentence TEXT NOT NULL,
  example_translation TEXT NOT NULL,
  audio_status TEXT NOT NULL DEFAULT 'missing_asset',
  review_status TEXT NOT NULL DEFAULT 'approved' CHECK (review_status IN ('draft', 'under_review', 'approved', 'published', 'archived')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Reusable Question Bank table (10 activity types, difficulty tiers 1..5)
CREATE TABLE IF NOT EXISTS public.question_bank_items (
  id TEXT PRIMARY KEY,
  question_type TEXT NOT NULL CHECK (
    question_type IN (
      'multiple_choice', 'listen_and_choose', 'image_word_matching',
      'drag_and_drop', 'fill_in_the_blank', 'word_ordering',
      'sentence_ordering', 'spelling', 'reading_comprehension', 'speaking_practice'
    )
  ),
  difficulty_tier SMALLINT NOT NULL CHECK (difficulty_tier BETWEEN 1 AND 5),
  cefr_level TEXT NOT NULL CHECK (cefr_level IN ('Pre-A1', 'A1', 'A2')),
  topic TEXT NOT NULL,
  knowledge_ids TEXT[] NOT NULL DEFAULT '{}',
  prompt_vi TEXT NOT NULL,
  options JSONB NOT NULL DEFAULT '[]'::jsonb,
  correct_answer TEXT NOT NULL,
  acceptable_answers TEXT[] NOT NULL DEFAULT '{}',
  explanation_vi TEXT NOT NULL,
  review_status TEXT NOT NULL DEFAULT 'approved' CHECK (review_status IN ('draft', 'under_review', 'approved', 'published', 'archived')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Content Review Audit Log (tracks Draft -> Under Review -> Approved -> Published)
CREATE TABLE IF NOT EXISTS public.content_review_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_type TEXT NOT NULL,
  content_id TEXT NOT NULL,
  previous_status TEXT,
  new_status TEXT NOT NULL CHECK (new_status IN ('draft', 'under_review', 'approved', 'published', 'archived')),
  reviewer_note TEXT,
  reviewed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Multi-factor Level Unlock Evaluations per Player Profile
CREATE TABLE IF NOT EXISTS public.level_unlock_evaluations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
  target_level TEXT NOT NULL CHECK (target_level IN ('pre_a1', 'a1_basic', 'a1_plus', 'a2_starter')),
  pre_a1_lessons_done INTEGER NOT NULL DEFAULT 0,
  remembered_items INTEGER NOT NULL DEFAULT 0,
  mastered_items INTEGER NOT NULL DEFAULT 0,
  overall_accuracy_pct NUMERIC(5,2) NOT NULL DEFAULT 0.0,
  required_quests_completed BOOLEAN NOT NULL DEFAULT false,
  is_unlocked BOOLEAN NOT NULL DEFAULT false,
  evaluated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (profile_id, target_level)
);

-- =============================================================================
-- Row Level Security (RLS)
-- =============================================================================
ALTER TABLE public.learning_phrases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_bank_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_review_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.level_unlock_evaluations ENABLE ROW LEVEL SECURITY;

-- Public read-only access for approved/published catalog rows
DROP POLICY IF EXISTS "Approved phrases readable" ON public.learning_phrases;
CREATE POLICY "Approved phrases readable" ON public.learning_phrases
  FOR SELECT USING (review_status IN ('approved', 'published'));

DROP POLICY IF EXISTS "Approved question bank readable" ON public.question_bank_items;
CREATE POLICY "Approved question bank readable" ON public.question_bank_items
  FOR SELECT USING (review_status IN ('approved', 'published'));

DROP POLICY IF EXISTS "Review logs readable by authenticated" ON public.content_review_logs;
CREATE POLICY "Review logs readable by authenticated" ON public.content_review_logs
  FOR SELECT TO authenticated USING (true);

-- Strict ownership policies for player level unlock evaluations
DROP POLICY IF EXISTS "Player owns level unlock evaluations" ON public.level_unlock_evaluations;
CREATE POLICY "Player owns level unlock evaluations" ON public.level_unlock_evaluations
  FOR ALL USING (public.is_profile_owner(profile_id))
  WITH CHECK (public.is_profile_owner(profile_id));
