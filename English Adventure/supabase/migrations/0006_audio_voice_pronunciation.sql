-- ============================================================================
-- ENGLISH ADVENTURE - PROMPT 07 AUDIO, VOICE & PRONUNCIATION EXTENSIONS
-- Target: Supabase PostgreSQL 15+
-- Additive, non-breaking migration preserving 0001-0005 tables & RLS.
-- Child Privacy Note: Never stores raw child voice recordings in PostgreSQL.
-- ============================================================================

-- 1. NPC & Narrator Voice Profiles
CREATE TABLE IF NOT EXISTS public.voice_profiles (
    id TEXT PRIMARY KEY,
    display_name_vi TEXT NOT NULL,
    display_name_en TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'secondary' CHECK (priority IN ('mvp_primary', 'secondary')),
    pitch_scale NUMERIC(4,2) NOT NULL DEFAULT 1.00,
    rate_scale NUMERIC(4,2) NOT NULL DEFAULT 0.85,
    lip_sync_mode TEXT NOT NULL DEFAULT 'basic_mouth_animation',
    audio_source_mode TEXT NOT NULL DEFAULT 'bundled_or_tts',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Speaking Practice Sessions (Tracks listening, local recording, replay, and attempts)
CREATE TABLE IF NOT EXISTS public.speaking_practice_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    learning_content_id TEXT NOT NULL,
    word_id TEXT NOT NULL DEFAULT '',
    recording_session_id TEXT NOT NULL DEFAULT '',
    practice_mode TEXT NOT NULL DEFAULT 'self_practice'
        CHECK (practice_mode IN ('listen_only', 'self_practice', 'stt_assisted', 'ai_assisted')),
    expected_text TEXT NOT NULL,
    recognized_text TEXT NOT NULL DEFAULT '',
    listened_model BOOLEAN NOT NULL DEFAULT true,
    recorded_audio BOOLEAN NOT NULL DEFAULT false,
    replayed_own BOOLEAN NOT NULL DEFAULT false,
    attempts INTEGER NOT NULL DEFAULT 1 CHECK (attempts >= 1),
    assessment_status TEXT NOT NULL DEFAULT 'self_practiced',
    completed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_speaking_sessions_profile
    ON public.speaking_practice_sessions(profile_id, completed_at DESC);

-- 3. AI Pronunciation Assessment Results (Metrics nullable — NEVER filled with fake zeros)
CREATE TABLE IF NOT EXISTS public.pronunciation_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_id TEXT NOT NULL UNIQUE,
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    learning_content_id TEXT NOT NULL,
    expected_text TEXT NOT NULL,
    recognized_text TEXT NOT NULL DEFAULT '',
    overall_score NUMERIC(5,2) NULL CHECK (overall_score IS NULL OR (overall_score >= 0 AND overall_score <= 100)),
    accuracy_score NUMERIC(5,2) NULL CHECK (accuracy_score IS NULL OR (accuracy_score >= 0 AND accuracy_score <= 100)),
    fluency_score NUMERIC(5,2) NULL CHECK (fluency_score IS NULL OR (fluency_score >= 0 AND fluency_score <= 100)),
    completeness_score NUMERIC(5,2) NULL CHECK (completeness_score IS NULL OR (completeness_score >= 0 AND completeness_score <= 100)),
    prosody_score NUMERIC(5,2) NULL CHECK (prosody_score IS NULL OR (prosody_score >= 0 AND prosody_score <= 100)),
    word_feedback JSONB NOT NULL DEFAULT '[]'::jsonb,
    phoneme_feedback JSONB NOT NULL DEFAULT '[]'::jsonb,
    provider TEXT NOT NULL DEFAULT 'none',
    assessment_status TEXT NOT NULL DEFAULT 'provider_unavailable',
    is_mock BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pronunciation_assessments_profile
    ON public.pronunciation_assessments(profile_id, created_at DESC);

-- 4. Per-Profile Audio & Dialect Preferences Sync
CREATE TABLE IF NOT EXISTS public.audio_settings_sync (
    profile_id UUID PRIMARY KEY REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    master_volume NUMERIC(3,2) NOT NULL DEFAULT 0.90 CHECK (master_volume >= 0 AND master_volume <= 1),
    music_volume NUMERIC(3,2) NOT NULL DEFAULT 0.65 CHECK (music_volume >= 0 AND music_volume <= 1),
    sfx_volume NUMERIC(3,2) NOT NULL DEFAULT 0.85 CHECK (sfx_volume >= 0 AND sfx_volume <= 1),
    voice_volume NUMERIC(3,2) NOT NULL DEFAULT 0.95 CHECK (voice_volume >= 0 AND voice_volume <= 1),
    learning_audio_volume NUMERIC(3,2) NOT NULL DEFAULT 1.00 CHECK (learning_audio_volume >= 0.15 AND learning_audio_volume <= 1),
    speech_rate NUMERIC(3,2) NOT NULL DEFAULT 0.85 CHECK (speech_rate >= 0.65 AND speech_rate <= 1.15),
    preferred_accent TEXT NOT NULL DEFAULT 'en-US' CHECK (preferred_accent IN ('en-US', 'en-GB')),
    mic_consent_acknowledged BOOLEAN NOT NULL DEFAULT false,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_audio_settings_sync_updated_at
    BEFORE UPDATE ON public.audio_settings_sync
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- 5. Enable Row Level Security & Policies
ALTER TABLE public.voice_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.speaking_practice_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pronunciation_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audio_settings_sync ENABLE ROW LEVEL SECURITY;

CREATE POLICY read_voice_profiles ON public.voice_profiles
    FOR SELECT TO authenticated USING (true);

CREATE POLICY speaking_practice_sessions_own ON public.speaking_practice_sessions
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY pronunciation_assessments_own ON public.pronunciation_assessments
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY audio_settings_sync_own ON public.audio_settings_sync
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));
