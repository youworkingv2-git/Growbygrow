-- ============================================================================
-- ENGLISH ADVENTURE - PROMPT 06 QUEST, NPC, REWARD & INVENTORY EXTENSIONS
-- Target: Supabase PostgreSQL 15+
-- Additive, non-breaking migration preserving 0001-0004 tables & RLS.
-- ============================================================================

-- 1. Unified Reward Ledger (Idempotent anti-duplication across Quests, MiniGames, Objects, Achievements)
CREATE TABLE IF NOT EXISTS public.reward_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    reward_key TEXT NOT NULL,
    reward_type TEXT NOT NULL,
    source_type TEXT NOT NULL,
    source_id TEXT NOT NULL,
    exp_amount INTEGER NOT NULL DEFAULT 0 CHECK (exp_amount >= 0),
    gold_amount INTEGER NOT NULL DEFAULT 0 CHECK (gold_amount >= 0),
    stars_amount INTEGER NOT NULL DEFAULT 0 CHECK (stars_amount >= 0),
    items_json JSONB NOT NULL DEFAULT '[]'::jsonb,
    claim_status TEXT NOT NULL DEFAULT 'claimed' CHECK (claim_status IN ('pending', 'claimed')),
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, reward_key)
);

CREATE INDEX IF NOT EXISTS idx_reward_ledger_profile ON public.reward_ledger(profile_id, granted_at DESC);

-- 2. Granular Quest Objective Progress (Supports 12 objective types, sequential/parallel, optional/repeatable)
CREATE TABLE IF NOT EXISTS public.quest_objective_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    quest_id TEXT NOT NULL,
    objective_id TEXT NOT NULL,
    objective_type TEXT NOT NULL,
    current_count INTEGER NOT NULL DEFAULT 0 CHECK (current_count >= 0),
    target_count INTEGER NOT NULL DEFAULT 1 CHECK (target_count >= 1),
    is_completed BOOLEAN NOT NULL DEFAULT false,
    is_optional BOOLEAN NOT NULL DEFAULT false,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, quest_id, objective_id)
);

-- 3. Player Inventory & Achievements
CREATE TABLE IF NOT EXISTS public.player_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    item_id TEXT NOT NULL,
    item_type TEXT NOT NULL DEFAULT 'collectible',
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 0),
    acquisition_source TEXT NOT NULL DEFAULT '',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, item_id)
);

CREATE TABLE IF NOT EXISTS public.player_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    achievement_id TEXT NOT NULL,
    unlocked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, achievement_id)
);

-- 4. NPC Encounters & Dialogue Progress
CREATE TABLE IF NOT EXISTS public.npc_encounters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.player_profiles(id) ON DELETE CASCADE,
    npc_id TEXT NOT NULL,
    talk_count INTEGER NOT NULL DEFAULT 0 CHECK (talk_count >= 0),
    last_dialogue_id TEXT NOT NULL DEFAULT '',
    seen_dialogue_ids TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (profile_id, npc_id)
);

-- 5. Enable Row Level Security
ALTER TABLE public.reward_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quest_objective_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.npc_encounters ENABLE ROW LEVEL SECURITY;

CREATE POLICY reward_ledger_own ON public.reward_ledger
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));

CREATE POLICY quest_objective_states_own ON public.quest_objective_states
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

CREATE POLICY npc_encounters_own ON public.npc_encounters
    FOR ALL TO authenticated
    USING (public.is_profile_owner(profile_id))
    WITH CHECK (public.is_profile_owner(profile_id));
