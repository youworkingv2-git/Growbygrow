-- ============================================================================
-- ENGLISH ADVENTURE - PROMPT 04 LEARNING ENGINE DATABASE EXTENSIONS
-- Target: Supabase PostgreSQL 15+
-- Additive, non-breaking migration preserving 0001 & 0002 tables/RLS.
-- ============================================================================

-- 1. Learning Path & Level Hierarchy (Pre-A1 -> A1 -> A1+ -> A2)
CREATE TABLE IF NOT EXISTS public.learning_paths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    title_en TEXT NOT NULL,
    title_vi TEXT NOT NULL,
    target_audience TEXT NOT NULL DEFAULT 'Beginners (age ~10)',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_learning_paths_updated_at
    BEFORE UPDATE ON public.learning_paths
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.learning_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learning_path_id UUID NOT NULL REFERENCES public.learning_paths(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    cefr_code TEXT NOT NULL CHECK (cefr_code IN ('Zero', 'Pre-A1', 'A1', 'A1+', 'A2')),
    order_index SMALLINT NOT NULL,
    title_en TEXT NOT NULL,
    title_vi TEXT NOT NULL,
    is_unlocked_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (learning_path_id, order_index)
);

CREATE TRIGGER trg_learning_levels_updated_at
    BEFORE UPDATE ON public.learning_levels
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 2. Topics & Learning Activities (Connecting World -> Topic -> Lesson -> Activity -> Question)
CREATE TABLE IF NOT EXISTS public.topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    world_id UUID NOT NULL REFERENCES public.worlds(id) ON DELETE CASCADE,
    learning_level_id UUID NULL REFERENCES public.learning_levels(id) ON DELETE SET NULL,
    code TEXT NOT NULL UNIQUE,
    order_index SMALLINT NOT NULL,
    title_en TEXT NOT NULL,
    title_vi TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (world_id, order_index)
);

CREATE TRIGGER trg_topics_updated_at
    BEFORE UPDATE ON public.topics
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.learning_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    skill TEXT NOT NULL CHECK (skill IN ('listening', 'speaking', 'reading', 'writing')),
    activity_type TEXT NOT NULL,
    order_index SMALLINT NOT NULL,
    question_id UUID NULL REFERENCES public.questions(id) ON DELETE SET NULL,
    config_json JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (lesson_id, order_index)
);

CREATE INDEX IF NOT EXISTS idx_learning_activities_lesson_id ON public.learning_activities(lesson_id);

CREATE TRIGGER trg_learning_activities_updated_at
    BEFORE UPDATE ON public.learning_activities
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 3. Phonics Examples & Grammar Examples (Normalized supporting examples)
CREATE TABLE IF NOT EXISTS public.phonics_examples (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phonics_id UUID NOT NULL REFERENCES public.phonics_content(id) ON DELETE CASCADE,
    word_id UUID NULL REFERENCES public.vocabulary(id) ON DELETE SET NULL,
    blended_word TEXT NOT NULL,
    segments TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    audio_asset_id UUID NULL REFERENCES public.audio_assets(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_phonics_examples_phonics_id ON public.phonics_examples(phonics_id);

CREATE TABLE IF NOT EXISTS public.grammar_examples (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    grammar_topic_id UUID NOT NULL REFERENCES public.grammar_topics(id) ON DELETE CASCADE,
    sentence_en TEXT NOT NULL,
    sentence_vi TEXT NOT NULL,
    audio_asset_id UUID NULL REFERENCES public.audio_assets(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_grammar_examples_topic_id ON public.grammar_examples(grammar_topic_id);

-- 4. Player Skill Progress (Aggregated 4-skill weakness & mastery tracking)
CREATE TABLE IF NOT EXISTS public.player_skill_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    skill TEXT NOT NULL CHECK (skill IN ('listening', 'speaking', 'reading', 'writing')),
    attempts_count INTEGER NOT NULL DEFAULT 0 CHECK (attempts_count >= 0),
    first_try_correct_count INTEGER NOT NULL DEFAULT 0 CHECK (first_try_correct_count >= 0),
    accuracy_pct NUMERIC(5,2) NOT NULL DEFAULT 0.00 CHECK (accuracy_pct >= 0 AND accuracy_pct <= 100),
    avg_response_time_ms INTEGER NOT NULL DEFAULT 0 CHECK (avg_response_time_ms >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, skill)
);

CREATE TRIGGER trg_player_skill_progress_updated_at
    BEFORE UPDATE ON public.player_skill_progress
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 5. Enable Row Level Security & Policies on new tables
ALTER TABLE public.learning_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.phonics_examples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grammar_examples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_skill_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY read_learning_paths ON public.learning_paths FOR SELECT TO authenticated USING (true);
CREATE POLICY read_learning_levels ON public.learning_levels FOR SELECT TO authenticated USING (true);
CREATE POLICY read_topics ON public.topics FOR SELECT TO authenticated USING (true);
CREATE POLICY read_learning_activities ON public.learning_activities FOR SELECT TO authenticated USING (true);
CREATE POLICY read_phonics_examples ON public.phonics_examples FOR SELECT TO authenticated USING (true);
CREATE POLICY read_grammar_examples ON public.grammar_examples FOR SELECT TO authenticated USING (true);

CREATE POLICY player_skill_progress_own ON public.player_skill_progress
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));
