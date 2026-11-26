-- ============================================================================
-- ENGLISH ADVENTURE - ROW LEVEL SECURITY (RLS) POLICIES
-- Target: Supabase PostgreSQL 15+
-- Guarantees strict user & child data isolation across all player tables.
-- ============================================================================

-- Helper ownership check
CREATE OR REPLACE FUNCTION public.is_profile_owner(target_profile_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.player_profiles p
        WHERE p.id = target_profile_id
          AND p.user_id = auth.uid()
    );
$$;

-- ============================================================================
-- 1. ENABLE RLS ON ALL 32 TABLES
-- ============================================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parental_settings ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.audio_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.image_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worlds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.world_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.characters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.character_dialogues ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.learning_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vocabulary ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vocabulary_examples ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.phonics_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grammar_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_options ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.mini_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quest_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.player_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_world_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_quest_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vocabulary_mastery ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_achievements ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. USER MANAGEMENT POLICIES
-- ============================================================================

CREATE POLICY users_select_own ON public.users
    FOR SELECT TO authenticated
    USING (id = auth.uid());

CREATE POLICY users_insert_own ON public.users
    FOR INSERT TO authenticated
    WITH CHECK (id = auth.uid());

CREATE POLICY users_update_own ON public.users
    FOR UPDATE TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

CREATE POLICY player_profiles_all_own ON public.player_profiles
    FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY parental_settings_all_own ON public.parental_settings
    FOR ALL TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- 3. PUBLIC / AUTHENTICATED READ-ONLY CONTENT POLICIES
-- (No INSERT/UPDATE/DELETE from client; managed via secure migrations/CI)
-- ============================================================================

CREATE POLICY read_audio_assets ON public.audio_assets FOR SELECT TO authenticated USING (true);
CREATE POLICY read_image_assets ON public.image_assets FOR SELECT TO authenticated USING (true);
CREATE POLICY read_worlds ON public.worlds FOR SELECT TO authenticated USING (true);
CREATE POLICY read_world_levels ON public.world_levels FOR SELECT TO authenticated USING (true);
CREATE POLICY read_characters ON public.characters FOR SELECT TO authenticated USING (true);
CREATE POLICY read_character_dialogues ON public.character_dialogues FOR SELECT TO authenticated USING (true);

CREATE POLICY read_learning_modules ON public.learning_modules FOR SELECT TO authenticated USING (true);
CREATE POLICY read_lessons ON public.lessons FOR SELECT TO authenticated USING (true);
CREATE POLICY read_vocabulary ON public.vocabulary FOR SELECT TO authenticated USING (true);
CREATE POLICY read_vocabulary_examples ON public.vocabulary_examples FOR SELECT TO authenticated USING (true);
CREATE POLICY read_phonics_content ON public.phonics_content FOR SELECT TO authenticated USING (true);
CREATE POLICY read_grammar_topics ON public.grammar_topics FOR SELECT TO authenticated USING (true);
CREATE POLICY read_questions ON public.questions FOR SELECT TO authenticated USING (true);
CREATE POLICY read_question_options ON public.question_options FOR SELECT TO authenticated USING (true);

CREATE POLICY read_mini_games ON public.mini_games FOR SELECT TO authenticated USING (true);
CREATE POLICY read_quests ON public.quests FOR SELECT TO authenticated USING (true);
CREATE POLICY read_quest_steps ON public.quest_steps FOR SELECT TO authenticated USING (true);
CREATE POLICY read_items ON public.items FOR SELECT TO authenticated USING (true);
CREATE POLICY read_rewards ON public.rewards FOR SELECT TO authenticated USING (true);
CREATE POLICY read_achievements ON public.achievements FOR SELECT TO authenticated USING (true);

-- ============================================================================
-- 4. PLAYER DATA POLICIES (STRICT PROFILE OWNERSHIP ISOLATION)
-- ============================================================================

CREATE POLICY player_progress_own ON public.player_progress
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY player_world_progress_own ON public.player_world_progress
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY player_lesson_progress_own ON public.player_lesson_progress
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY player_quest_progress_own ON public.player_quest_progress
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY learning_attempts_own ON public.learning_attempts
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY vocabulary_mastery_own ON public.vocabulary_mastery
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY review_schedule_own ON public.review_schedule
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY player_inventory_own ON public.player_inventory
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY player_achievements_own ON public.player_achievements
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));
