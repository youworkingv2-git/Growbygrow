-- ============================================================================
-- ENGLISH ADVENTURE - INITIAL DATABASE SCHEMA MIGRATION
-- Target: Supabase PostgreSQL 15+
-- Matches: docs/DATABASE_SCHEMA.md & docs/ERD.md (1:1)
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Helper trigger function for updated_at columns
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

-- ============================================================================
-- GROUP A: USER MANAGEMENT (3 tables)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    account_role TEXT NOT NULL DEFAULT 'player' CHECK (account_role IN ('player', 'parent', 'admin')),
    is_anonymous BOOLEAN NOT NULL DEFAULT true,
    auth_provider TEXT NOT NULL DEFAULT 'anonymous',
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
    last_seen_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.player_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    nickname TEXT NOT NULL CHECK (char_length(nickname) BETWEEN 2 AND 24),
    avatar_gender TEXT NOT NULL DEFAULT 'boy' CHECK (avatar_gender IN ('boy', 'girl')),
    buddy_name TEXT NOT NULL DEFAULT 'Buddy',
    preferred_ui_locale TEXT NOT NULL DEFAULT 'vi' CHECK (preferred_ui_locale IN ('vi', 'en')),
    preferred_accent TEXT NOT NULL DEFAULT 'en-US' CHECK (preferred_accent IN ('en-US', 'en-GB')),
    initial_assessment_level SMALLINT NOT NULL DEFAULT 0 CHECK (initial_assessment_level BETWEEN 0 AND 3),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_player_profiles_user_id ON public.player_profiles(user_id);

CREATE TRIGGER trg_player_profiles_updated_at
    BEFORE UPDATE ON public.player_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.parental_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES public.users(id) ON DELETE CASCADE,
    daily_time_limit_minutes INTEGER NOT NULL DEFAULT 45 CHECK (daily_time_limit_minutes BETWEEN 10 AND 240),
    microphone_allowed BOOLEAN NOT NULL DEFAULT true,
    sound_effects_enabled BOOLEAN NOT NULL DEFAULT true,
    parent_pin_hash TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_parental_settings_updated_at
    BEFORE UPDATE ON public.parental_settings
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================================
-- GROUP B & MEDIA: ASSETS + GAME WORLD
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.audio_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    accent TEXT NOT NULL DEFAULT 'en-US' CHECK (accent IN ('en-US', 'en-GB', 'vi-VN')),
    category TEXT NOT NULL CHECK (category IN ('letter_name', 'letter_sound', 'word', 'sentence', 'dialogue', 'sfx')),
    storage_path TEXT NOT NULL,
    duration_ms INTEGER NOT NULL DEFAULT 0 CHECK (duration_ms >= 0),
    checksum_sha256 TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.image_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    storage_path TEXT NOT NULL,
    alt_text_en TEXT NOT NULL,
    width_px INTEGER NOT NULL DEFAULT 512 CHECK (width_px > 0),
    height_px INTEGER NOT NULL DEFAULT 512 CHECK (height_px > 0),
    checksum_sha256 TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.worlds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    order_index SMALLINT NOT NULL UNIQUE,
    name_en TEXT NOT NULL,
    name_vi TEXT NOT NULL,
    description_vi TEXT NOT NULL,
    required_stars INTEGER NOT NULL DEFAULT 0 CHECK (required_stars >= 0),
    is_mvp_active BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_worlds_mvp_active ON public.worlds(is_mvp_active);

CREATE TABLE IF NOT EXISTS public.world_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    world_id UUID NOT NULL REFERENCES public.worlds(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    order_index SMALLINT NOT NULL,
    name_en TEXT NOT NULL,
    name_vi TEXT NOT NULL,
    unlock_required_stars INTEGER NOT NULL DEFAULT 0 CHECK (unlock_required_stars >= 0),
    is_boss_zone BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (world_id, order_index)
);

CREATE INDEX IF NOT EXISTS idx_world_levels_world_id ON public.world_levels(world_id);

CREATE TABLE IF NOT EXISTS public.characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL CHECK (role IN ('player', 'buddy', 'mentor', 'npc', 'boss')),
    name_en TEXT NOT NULL,
    name_vi TEXT NOT NULL,
    world_id UUID NULL REFERENCES public.worlds(id) ON DELETE SET NULL,
    asset_key TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_characters_world_id ON public.characters(world_id);

CREATE TABLE IF NOT EXISTS public.character_dialogues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
    dialogue_key TEXT NOT NULL UNIQUE,
    context_type TEXT NOT NULL CHECK (context_type IN ('quest_intro', 'quest_end', 'hint', 'encourage', 'celebrate', 'ambient')),
    text_en TEXT NULL,
    text_vi TEXT NOT NULL,
    audio_asset_id UUID NULL REFERENCES public.audio_assets(id) ON DELETE SET NULL,
    order_index SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_character_dialogues_character_id ON public.character_dialogues(character_id);

-- ============================================================================
-- GROUP C: LEARNING CONTENT (8 remaining tables + 2 media tables above = 10)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.learning_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    world_id UUID NOT NULL REFERENCES public.worlds(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    title_en TEXT NOT NULL,
    title_vi TEXT NOT NULL,
    order_index SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (world_id, order_index)
);

CREATE INDEX IF NOT EXISTS idx_learning_modules_world_id ON public.learning_modules(world_id);

CREATE TABLE IF NOT EXISTS public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learning_module_id UUID NOT NULL REFERENCES public.learning_modules(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    title_en TEXT NOT NULL,
    title_vi TEXT NOT NULL,
    target_cefr TEXT NOT NULL DEFAULT 'Pre-A1' CHECK (target_cefr IN ('Zero', 'Pre-A1', 'A1', 'A2')),
    order_index SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (learning_module_id, order_index)
);

CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON public.lessons(learning_module_id);

CREATE TABLE IF NOT EXISTS public.vocabulary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    world_id UUID NOT NULL REFERENCES public.worlds(id) ON DELETE RESTRICT,
    word TEXT NOT NULL,
    part_of_speech TEXT NOT NULL DEFAULT 'noun',
    ipa_us TEXT NOT NULL,
    ipa_uk TEXT NULL,
    meaning_vi TEXT NOT NULL,
    category TEXT NOT NULL,
    difficulty SMALLINT NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
    skills TEXT[] NOT NULL DEFAULT ARRAY['listening', 'speaking', 'reading', 'writing']::TEXT[],
    image_asset_id UUID NOT NULL REFERENCES public.image_assets(id) ON DELETE RESTRICT,
    audio_us_id UUID NOT NULL REFERENCES public.audio_assets(id) ON DELETE RESTRICT,
    audio_uk_id UUID NULL REFERENCES public.audio_assets(id) ON DELETE SET NULL,
    related_word_codes TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vocabulary_world_id ON public.vocabulary(world_id);
CREATE INDEX IF NOT EXISTS idx_vocabulary_word ON public.vocabulary(word);
CREATE INDEX IF NOT EXISTS idx_vocabulary_category ON public.vocabulary(category);
CREATE INDEX IF NOT EXISTS idx_vocabulary_difficulty ON public.vocabulary(difficulty);
CREATE INDEX IF NOT EXISTS idx_vocabulary_skills_gin ON public.vocabulary USING GIN (skills);

CREATE TABLE IF NOT EXISTS public.vocabulary_examples (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vocabulary_id UUID NOT NULL REFERENCES public.vocabulary(id) ON DELETE CASCADE,
    sentence_en TEXT NOT NULL,
    sentence_vi TEXT NOT NULL,
    audio_asset_id UUID NULL REFERENCES public.audio_assets(id) ON DELETE SET NULL,
    difficulty SMALLINT NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vocabulary_examples_vocab_id ON public.vocabulary_examples(vocabulary_id);

CREATE TABLE IF NOT EXISTS public.phonics_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    world_id UUID NOT NULL REFERENCES public.worlds(id) ON DELETE RESTRICT,
    letter_upper TEXT NOT NULL,
    letter_lower TEXT NOT NULL,
    letter_type TEXT NOT NULL CHECK (letter_type IN ('vowel', 'consonant', 'digraph', 'blend')),
    letter_name_ipa TEXT NOT NULL,
    letter_name_audio_id UUID NOT NULL REFERENCES public.audio_assets(id) ON DELETE RESTRICT,
    phoneme_symbol TEXT NOT NULL,
    letter_sound_ipa TEXT NOT NULL,
    letter_sound_audio_id UUID NOT NULL REFERENCES public.audio_assets(id) ON DELETE RESTRICT,
    mouth_hint_vi TEXT NULL,
    anchor_word_ids UUID[] NOT NULL DEFAULT '{}'::UUID[],
    order_index SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_distinct_letter_name_and_sound_audio CHECK (letter_name_audio_id <> letter_sound_audio_id)
);

CREATE INDEX IF NOT EXISTS idx_phonics_content_world_id ON public.phonics_content(world_id);

CREATE TABLE IF NOT EXISTS public.grammar_topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    world_id UUID NOT NULL REFERENCES public.worlds(id) ON DELETE RESTRICT,
    title_en TEXT NOT NULL,
    title_vi TEXT NOT NULL,
    explanation_vi TEXT NOT NULL,
    pattern_template TEXT NOT NULL,
    slots_schema JSONB NOT NULL DEFAULT '[]'::jsonb,
    difficulty SMALLINT NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_grammar_topics_world_id ON public.grammar_topics(world_id);

CREATE TABLE IF NOT EXISTS public.questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    lesson_id UUID NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    skill TEXT NOT NULL CHECK (skill IN ('listening', 'speaking', 'reading', 'writing')),
    question_type TEXT NOT NULL,
    vocabulary_id UUID NULL REFERENCES public.vocabulary(id) ON DELETE SET NULL,
    phonics_id UUID NULL REFERENCES public.phonics_content(id) ON DELETE SET NULL,
    grammar_topic_id UUID NULL REFERENCES public.grammar_topics(id) ON DELETE SET NULL,
    prompt_vi TEXT NOT NULL,
    prompt_en TEXT NULL,
    buddy_hint_vi TEXT NULL,
    audio_asset_id UUID NULL REFERENCES public.audio_assets(id) ON DELETE SET NULL,
    image_asset_id UUID NULL REFERENCES public.image_assets(id) ON DELETE SET NULL,
    difficulty SMALLINT NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
    is_assessment_pool BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_questions_lesson_id ON public.questions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_questions_skill ON public.questions(skill);
CREATE INDEX IF NOT EXISTS idx_questions_vocabulary_id ON public.questions(vocabulary_id);
CREATE INDEX IF NOT EXISTS idx_questions_phonics_id ON public.questions(phonics_id);
CREATE INDEX IF NOT EXISTS idx_questions_grammar_id ON public.questions(grammar_topic_id);
CREATE INDEX IF NOT EXISTS idx_questions_assessment_pool ON public.questions(is_assessment_pool);

CREATE TABLE IF NOT EXISTS public.question_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
    label_en TEXT NOT NULL,
    vocabulary_id UUID NULL REFERENCES public.vocabulary(id) ON DELETE SET NULL,
    image_asset_id UUID NULL REFERENCES public.image_assets(id) ON DELETE SET NULL,
    audio_asset_id UUID NULL REFERENCES public.audio_assets(id) ON DELETE SET NULL,
    is_correct BOOLEAN NOT NULL DEFAULT false,
    order_index SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_question_options_question_id ON public.question_options(question_id);

-- ============================================================================
-- GROUP D: GAMEPLAY (6 tables)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.mini_games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name_en TEXT NOT NULL,
    name_vi TEXT NOT NULL,
    primary_skills TEXT[] NOT NULL,
    is_mvp_enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    world_level_id UUID NOT NULL REFERENCES public.world_levels(id) ON DELETE CASCADE,
    npc_character_id UUID NULL REFERENCES public.characters(id) ON DELETE SET NULL,
    prerequisite_quest_id UUID NULL REFERENCES public.quests(id) ON DELETE SET NULL,
    title_en TEXT NOT NULL,
    title_vi TEXT NOT NULL,
    story_summary_vi TEXT NOT NULL,
    order_index SMALLINT NOT NULL,
    exp_reward INTEGER NOT NULL DEFAULT 50 CHECK (exp_reward >= 0),
    gold_reward INTEGER NOT NULL DEFAULT 20 CHECK (gold_reward >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (world_level_id, order_index)
);

CREATE INDEX IF NOT EXISTS idx_quests_world_level_id ON public.quests(world_level_id);

CREATE TABLE IF NOT EXISTS public.quest_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quest_id UUID NOT NULL REFERENCES public.quests(id) ON DELETE CASCADE,
    step_index SMALLINT NOT NULL,
    step_type TEXT NOT NULL CHECK (step_type IN ('dialogue', 'learn_intro', 'minigame', 'repeat_after_me', 'explore_trigger')),
    lesson_id UUID NULL REFERENCES public.lessons(id) ON DELETE SET NULL,
    mini_game_id UUID NULL REFERENCES public.mini_games(id) ON DELETE SET NULL,
    step_config JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (quest_id, step_index)
);

CREATE INDEX IF NOT EXISTS idx_quest_steps_quest_id ON public.quest_steps(quest_id);

CREATE TABLE IF NOT EXISTS public.items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    item_type TEXT NOT NULL CHECK (item_type IN ('crystal_shard', 'magic_crystal', 'consumable', 'badge', 'cosmetic')),
    name_en TEXT NOT NULL,
    name_vi TEXT NOT NULL,
    description_vi TEXT NOT NULL,
    icon_asset_id UUID NULL REFERENCES public.image_assets(id) ON DELETE SET NULL,
    gold_price INTEGER NOT NULL DEFAULT 0 CHECK (gold_price >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type TEXT NOT NULL CHECK (source_type IN ('quest', 'achievement', 'daily_review', 'world_clear')),
    source_ref_id UUID NOT NULL,
    exp_amount INTEGER NOT NULL DEFAULT 0 CHECK (exp_amount >= 0),
    gold_amount INTEGER NOT NULL DEFAULT 0 CHECK (gold_amount >= 0),
    item_id UUID NULL REFERENCES public.items(id) ON DELETE SET NULL,
    item_quantity INTEGER NOT NULL DEFAULT 1 CHECK (item_quantity >= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rewards_source ON public.rewards(source_type, source_ref_id);

CREATE TABLE IF NOT EXISTS public.achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    title_en TEXT NOT NULL,
    title_vi TEXT NOT NULL,
    description_vi TEXT NOT NULL,
    condition_type TEXT NOT NULL,
    condition_target INTEGER NOT NULL DEFAULT 1 CHECK (condition_target >= 1),
    badge_image_id UUID NULL REFERENCES public.image_assets(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- GROUP E: PLAYER DATA (9 tables)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.player_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    player_level INTEGER NOT NULL DEFAULT 1 CHECK (player_level >= 1),
    total_exp INTEGER NOT NULL DEFAULT 0 CHECK (total_exp >= 0),
    gold INTEGER NOT NULL DEFAULT 0 CHECK (gold >= 0),
    total_stars INTEGER NOT NULL DEFAULT 0 CHECK (total_stars >= 0),
    magic_crystals_count INTEGER NOT NULL DEFAULT 0 CHECK (magic_crystals_count >= 0),
    current_streak_days INTEGER NOT NULL DEFAULT 0 CHECK (current_streak_days >= 0),
    last_study_date DATE NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_player_progress_updated_at
    BEFORE UPDATE ON public.player_progress
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.player_world_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    world_id UUID NOT NULL REFERENCES public.worlds(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'locked' CHECK (status IN ('locked', 'unlocked', 'completed')),
    stars_earned INTEGER NOT NULL DEFAULT 0 CHECK (stars_earned >= 0),
    crystal_shards_collected INTEGER NOT NULL DEFAULT 0 CHECK (crystal_shards_collected >= 0),
    boss_defeated BOOLEAN NOT NULL DEFAULT false,
    unlocked_at TIMESTAMPTZ NULL,
    completed_at TIMESTAMPTZ NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, world_id)
);

CREATE INDEX IF NOT EXISTS idx_player_world_progress_world_id ON public.player_world_progress(world_id);

CREATE TRIGGER trg_player_world_progress_updated_at
    BEFORE UPDATE ON public.player_world_progress
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.player_lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
    best_accuracy_pct NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (best_accuracy_pct BETWEEN 0 AND 100),
    attempts_count INTEGER NOT NULL DEFAULT 0 CHECK (attempts_count >= 0),
    last_practiced_at TIMESTAMPTZ NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, lesson_id)
);

CREATE INDEX IF NOT EXISTS idx_player_lesson_progress_lesson_id ON public.player_lesson_progress(lesson_id);

CREATE TRIGGER trg_player_lesson_progress_updated_at
    BEFORE UPDATE ON public.player_lesson_progress
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.player_quest_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    quest_id UUID NOT NULL REFERENCES public.quests(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'locked' CHECK (status IN ('locked', 'available', 'in_progress', 'completed')),
    current_step_index SMALLINT NOT NULL DEFAULT 0 CHECK (current_step_index >= 0),
    best_stars SMALLINT NOT NULL DEFAULT 0 CHECK (best_stars BETWEEN 0 AND 3),
    best_score INTEGER NOT NULL DEFAULT 0 CHECK (best_score >= 0),
    completed_at TIMESTAMPTZ NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, quest_id)
);

CREATE INDEX IF NOT EXISTS idx_player_quest_progress_quest_id ON public.player_quest_progress(quest_id);

CREATE TRIGGER trg_player_quest_progress_updated_at
    BEFORE UPDATE ON public.player_quest_progress
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.learning_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_event_id UUID NOT NULL UNIQUE,
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    quest_id UUID NULL REFERENCES public.quests(id) ON DELETE SET NULL,
    mini_game_code TEXT NOT NULL,
    skill TEXT NOT NULL CHECK (skill IN ('listening', 'speaking', 'reading', 'writing')),
    vocabulary_id UUID NULL REFERENCES public.vocabulary(id) ON DELETE SET NULL,
    phonics_id UUID NULL REFERENCES public.phonics_content(id) ON DELETE SET NULL,
    question_id UUID NULL REFERENCES public.questions(id) ON DELETE SET NULL,
    is_correct BOOLEAN NOT NULL,
    attempt_number SMALLINT NOT NULL DEFAULT 1 CHECK (attempt_number >= 1),
    used_hint BOOLEAN NOT NULL DEFAULT false,
    used_dont_know BOOLEAN NOT NULL DEFAULT false,
    response_time_ms INTEGER NOT NULL DEFAULT 0 CHECK (response_time_ms >= 0),
    quality_score NUMERIC(4,2) NOT NULL DEFAULT 0.00 CHECK (quality_score BETWEEN 0 AND 1),
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_learning_attempts_profile_time ON public.learning_attempts(profile_id, attempted_at DESC);
CREATE INDEX IF NOT EXISTS idx_learning_attempts_profile_vocab ON public.learning_attempts(profile_id, vocabulary_id);
CREATE INDEX IF NOT EXISTS idx_learning_attempts_minigame ON public.learning_attempts(mini_game_code);

CREATE TABLE IF NOT EXISTS public.vocabulary_mastery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    vocabulary_id UUID NOT NULL REFERENCES public.vocabulary(id) ON DELETE CASCADE,
    mastery_score NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (mastery_score BETWEEN 0 AND 100),
    mastery_level SMALLINT NOT NULL DEFAULT 0 CHECK (mastery_level BETWEEN 0 AND 5),
    skills_verified TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    distinct_review_days INTEGER NOT NULL DEFAULT 0 CHECK (distinct_review_days >= 0),
    total_attempts INTEGER NOT NULL DEFAULT 0 CHECK (total_attempts >= 0),
    first_try_correct_count INTEGER NOT NULL DEFAULT 0 CHECK (first_try_correct_count >= 0),
    last_practiced_at TIMESTAMPTZ NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, vocabulary_id)
);

CREATE INDEX IF NOT EXISTS idx_vocabulary_mastery_vocab_id ON public.vocabulary_mastery(vocabulary_id);
CREATE INDEX IF NOT EXISTS idx_vocabulary_mastery_profile_level ON public.vocabulary_mastery(profile_id, mastery_level);

CREATE TRIGGER trg_vocabulary_mastery_updated_at
    BEFORE UPDATE ON public.vocabulary_mastery
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.review_schedule (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    vocabulary_id UUID NOT NULL REFERENCES public.vocabulary(id) ON DELETE CASCADE,
    interval_days INTEGER NOT NULL DEFAULT 1 CHECK (interval_days >= 1),
    ease_factor NUMERIC(4,2) NOT NULL DEFAULT 2.50 CHECK (ease_factor >= 1.30),
    repetition_count INTEGER NOT NULL DEFAULT 0 CHECK (repetition_count >= 0),
    next_review_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_reviewed_at TIMESTAMPTZ NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, vocabulary_id)
);

CREATE INDEX IF NOT EXISTS idx_review_schedule_due ON public.review_schedule(profile_id, next_review_at);

CREATE TRIGGER trg_review_schedule_updated_at
    BEFORE UPDATE ON public.review_schedule
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TABLE IF NOT EXISTS public.player_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 0),
    is_equipped BOOLEAN NOT NULL DEFAULT false,
    acquired_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, item_id)
);

CREATE TABLE IF NOT EXISTS public.player_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
    current_value INTEGER NOT NULL DEFAULT 0 CHECK (current_value >= 0),
    is_unlocked BOOLEAN NOT NULL DEFAULT false,
    unlocked_at TIMESTAMPTZ NULL,
    UNIQUE (profile_id, achievement_id)
);
