-- ============================================================================
-- ENGLISH ADVENTURE - PROMPT 05 MINI-GAME SYSTEM DATABASE EXTENSIONS
-- Target: Supabase PostgreSQL 15+
-- Additive, non-breaking migration preserving 0001, 0002 & 0003 tables/RLS.
-- ============================================================================

-- 1. Mini-Game Registry Metadata
CREATE TABLE IF NOT EXISTS public.minigames (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name_en TEXT NOT NULL,
    name_vi TEXT NOT NULL,
    description_vi TEXT NOT NULL DEFAULT '',
    learning_skills TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    default_difficulty TEXT NOT NULL DEFAULT 'easy' CHECK (default_difficulty IN ('easy', 'medium', 'hard')),
    supported_platforms TEXT[] NOT NULL DEFAULT ARRAY['windows', 'android', 'ios', 'web'],
    estimated_duration_sec INTEGER NOT NULL DEFAULT 90 CHECK (estimated_duration_sec > 0),
    availability_status TEXT NOT NULL DEFAULT 'playable',
    reward_config JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_minigames_updated_at
    BEFORE UPDATE ON public.minigames
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 2. Mini-Game Sessions (Separated Learning Score & Game Score)
CREATE TABLE IF NOT EXISTS public.minigame_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    minigame_id UUID NULL REFERENCES public.minigames(id) ON DELETE SET NULL,
    minigame_code TEXT NOT NULL,
    source_type TEXT NOT NULL DEFAULT 'arcade',
    source_id TEXT NOT NULL DEFAULT '',
    quest_id TEXT NOT NULL DEFAULT '',
    difficulty_tier TEXT NOT NULL DEFAULT 'easy' CHECK (difficulty_tier IN ('easy', 'medium', 'hard')),
    total_items INTEGER NOT NULL DEFAULT 0 CHECK (total_items >= 0),
    correct_answers INTEGER NOT NULL DEFAULT 0 CHECK (correct_answers >= 0),
    incorrect_answers INTEGER NOT NULL DEFAULT 0 CHECK (incorrect_answers >= 0),
    first_try_correct INTEGER NOT NULL DEFAULT 0 CHECK (first_try_correct >= 0),
    attempts INTEGER NOT NULL DEFAULT 0 CHECK (attempts >= 0),
    hints_used INTEGER NOT NULL DEFAULT 0 CHECK (hints_used >= 0),
    completion_time_ms INTEGER NOT NULL DEFAULT 0 CHECK (completion_time_ms >= 0),
    learning_score INTEGER NOT NULL DEFAULT 0 CHECK (learning_score >= 0),
    game_score INTEGER NOT NULL DEFAULT 0 CHECK (game_score >= 0),
    accuracy_pct NUMERIC(5,2) NOT NULL DEFAULT 0.00 CHECK (accuracy_pct >= 0 AND accuracy_pct <= 100),
    stars SMALLINT NOT NULL DEFAULT 1 CHECK (stars >= 1 AND stars <= 3),
    completed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_minigame_sessions_profile ON public.minigame_sessions(profile_id, completed_at DESC);

-- 3. Mini-Game Question Answer Logs (Links Mini-Game -> Learning Activity -> Knowledge)
CREATE TABLE IF NOT EXISTS public.minigame_question_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.minigame_sessions(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    minigame_code TEXT NOT NULL,
    learning_activity_id TEXT NOT NULL,
    question_id TEXT NOT NULL,
    knowledge_id TEXT NOT NULL DEFAULT '',
    answer_text TEXT NOT NULL DEFAULT '',
    is_correct BOOLEAN NOT NULL,
    attempts SMALLINT NOT NULL DEFAULT 1 CHECK (attempts >= 1),
    hint_used BOOLEAN NOT NULL DEFAULT false,
    completion_time_ms INTEGER NOT NULL DEFAULT 0 CHECK (completion_time_ms >= 0),
    completed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_minigame_question_logs_session ON public.minigame_question_logs(session_id);

-- 4. Mini-Game One-Time Reward Ledger (Prevents Duplicate Reward Exploits)
CREATE TABLE IF NOT EXISTS public.minigame_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    minigame_code TEXT NOT NULL,
    quest_context_id TEXT NOT NULL DEFAULT '',
    exp_granted INTEGER NOT NULL DEFAULT 0,
    gold_granted INTEGER NOT NULL DEFAULT 0,
    crystal_item_id TEXT NOT NULL DEFAULT '',
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, minigame_code, quest_context_id)
);

-- 5. Enable Row Level Security & Policies
ALTER TABLE public.minigames ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.minigame_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.minigame_question_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.minigame_rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY read_minigames ON public.minigames FOR SELECT TO authenticated USING (true);

CREATE POLICY minigame_sessions_own ON public.minigame_sessions
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY minigame_question_logs_own ON public.minigame_question_logs
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY minigame_rewards_own ON public.minigame_rewards
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));
