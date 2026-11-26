-- English Adventure – Initial Database Migration
-- Migration: 001_initial_schema
-- Date: 2026-11-26
-- Description: Creates the complete MVP schema for English Adventure on Supabase/PostgreSQL

-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE character_type AS ENUM ('player', 'buddy', 'npc', 'boss', 'professor');
CREATE TYPE skill_type AS ENUM ('listening', 'speaking', 'reading', 'writing', 'all');
CREATE TYPE question_type AS ENUM (
  'image_choice',
  'audio_choice',
  'word_match',
  'fill_blank',
  'sentence_arrange',
  'word_spell',
  'listen_repeat'
);
CREATE TYPE mini_game_type AS ENUM (
  'word_hunt',
  'listening_mission',
  'word_builder',
  'sentence_builder',
  'reading_challenge',
  'speaking_challenge',
  'boss_battle'
);
CREATE TYPE quest_status AS ENUM ('locked', 'available', 'in_progress', 'completed');
CREATE TYPE audio_accent AS ENUM ('en-US', 'en-GB', 'vi');
CREATE TYPE audio_content_type AS ENUM ('letter_name', 'letter_sound', 'word', 'sentence', 'instruction', 'dialogue', 'music', 'sfx');
CREATE TYPE item_type AS ENUM ('avatar_accessory', 'buddy_skin', 'magic_crystal', 'badge', 'decoration');
CREATE TYPE item_rarity AS ENUM ('common', 'rare', 'epic', 'legendary');
CREATE TYPE srs_quality AS ENUM ('again', 'hard', 'good', 'easy');
CREATE TYPE app_env AS ENUM ('development', 'staging', 'production');

-- ============================================================
-- USER MANAGEMENT
-- ============================================================

-- Player profiles (extends Supabase auth.users)
CREATE TABLE player_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL CHECK (char_length(display_name) BETWEEN 1 AND 30),
  avatar_type TEXT NOT NULL DEFAULT 'boy' CHECK (avatar_type IN ('boy', 'girl')),
  current_world_id TEXT DEFAULT 'world_1',
  player_level INTEGER NOT NULL DEFAULT 1 CHECK (player_level >= 1),
  exp_total INTEGER NOT NULL DEFAULT 0 CHECK (exp_total >= 0),
  exp_current_level INTEGER NOT NULL DEFAULT 0 CHECK (exp_current_level >= 0),
  gold INTEGER NOT NULL DEFAULT 0 CHECK (gold >= 0),
  magic_crystals INTEGER NOT NULL DEFAULT 0 CHECK (magic_crystals >= 0),
  language_preference TEXT NOT NULL DEFAULT 'vi' CHECK (language_preference IN ('vi', 'en')),
  audio_preference_accent TEXT NOT NULL DEFAULT 'en-US' CHECK (audio_preference_accent IN ('en-US', 'en-GB')),
  streak_days INTEGER NOT NULL DEFAULT 0 CHECK (streak_days >= 0),
  last_played_at TIMESTAMPTZ,
  initial_assessment_completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Parental settings (future phase but schema ready)
CREATE TABLE parental_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_email TEXT,
  daily_play_limit_minutes INTEGER DEFAULT NULL CHECK (daily_play_limit_minutes IS NULL OR daily_play_limit_minutes > 0),
  notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- GAME WORLD STRUCTURE
-- ============================================================

CREATE TABLE worlds (
  id TEXT PRIMARY KEY, -- e.g. 'world_1', 'world_2'
  slug TEXT NOT NULL UNIQUE,
  name_en TEXT NOT NULL,
  name_vi TEXT NOT NULL,
  theme TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  unlock_condition_json JSONB DEFAULT '{"type": "default_unlocked"}',
  thumbnail_image TEXT,
  description_vi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE world_areas (
  id TEXT PRIMARY KEY,
  world_id TEXT NOT NULL REFERENCES worlds(id),
  name_en TEXT NOT NULL,
  name_vi TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  unlock_after_area_id TEXT REFERENCES world_areas(id),
  visual_theme TEXT,
  description_vi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE characters (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  name_en TEXT NOT NULL,
  name_vi TEXT NOT NULL,
  character_type character_type NOT NULL,
  world_id TEXT REFERENCES worlds(id),
  sprite_key TEXT,
  description_vi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE character_dialogues (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  character_id TEXT NOT NULL REFERENCES characters(id),
  dialogue_key TEXT NOT NULL UNIQUE,
  text_vi TEXT NOT NULL,
  text_en TEXT,
  audio_key TEXT,
  trigger_condition TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ASSETS
-- ============================================================

CREATE TABLE audio_assets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asset_key TEXT NOT NULL UNIQUE,
  file_path TEXT NOT NULL,
  accent audio_accent NOT NULL DEFAULT 'en-US',
  duration_seconds FLOAT,
  content_type audio_content_type NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE image_assets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asset_key TEXT NOT NULL UNIQUE,
  file_path TEXT NOT NULL,
  width INTEGER,
  height INTEGER,
  content_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- LEARNING CONTENT
-- ============================================================

CREATE TABLE learning_modules (
  id TEXT PRIMARY KEY,
  world_id TEXT NOT NULL REFERENCES worlds(id),
  name_en TEXT NOT NULL,
  name_vi TEXT NOT NULL,
  description_vi TEXT,
  order_index INTEGER NOT NULL,
  skill_focus skill_type NOT NULL DEFAULT 'all',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE lessons (
  id TEXT PRIMARY KEY,
  module_id TEXT NOT NULL REFERENCES learning_modules(id),
  name_en TEXT NOT NULL,
  name_vi TEXT NOT NULL,
  lesson_type TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  estimated_minutes INTEGER DEFAULT 5,
  content_data_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE vocabulary (
  id TEXT PRIMARY KEY, -- e.g. 'word_001'
  word TEXT NOT NULL,
  phonetic_ipa TEXT,
  meaning_vi TEXT NOT NULL,
  category TEXT NOT NULL,
  sub_category TEXT,
  difficulty INTEGER NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  world_id TEXT REFERENCES worlds(id),
  image_asset_id UUID REFERENCES image_assets(id),
  audio_us_asset_id UUID REFERENCES audio_assets(id),
  audio_gb_asset_id UUID REFERENCES audio_assets(id),
  example_sentence TEXT,
  example_meaning_vi TEXT,
  related_word_ids TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  skills skill_type[] DEFAULT '{listening,speaking,reading,writing}',
  review_eligible BOOLEAN NOT NULL DEFAULT TRUE,
  srs_eligible BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE vocabulary_examples (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  vocab_id TEXT NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  sentence_en TEXT NOT NULL,
  sentence_meaning_vi TEXT NOT NULL,
  audio_asset_id UUID REFERENCES audio_assets(id),
  context_note_vi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE phonics_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  letter_id TEXT, -- references character id or letter code
  phoneme TEXT NOT NULL,
  phoneme_description_vi TEXT,
  audio_asset_id UUID REFERENCES audio_assets(id),
  example_word_ids TEXT[] DEFAULT '{}',
  blending_group TEXT,
  difficulty INTEGER NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE grammar_topics (
  id TEXT PRIMARY KEY,
  world_id TEXT REFERENCES worlds(id),
  topic_key TEXT NOT NULL UNIQUE,
  name_en TEXT NOT NULL,
  name_vi TEXT NOT NULL,
  rule_en TEXT NOT NULL,
  explanation_vi TEXT NOT NULL,
  difficulty INTEGER NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE grammar_examples (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  grammar_topic_id TEXT NOT NULL REFERENCES grammar_topics(id) ON DELETE CASCADE,
  sentence_en TEXT NOT NULL,
  sentence_vi TEXT NOT NULL,
  highlight_parts_json JSONB,
  audio_asset_id UUID REFERENCES audio_assets(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question_type question_type NOT NULL,
  skill skill_type NOT NULL,
  mini_game_type mini_game_type,
  content_ref_id TEXT NOT NULL, -- ID of vocab, grammar, or letter
  content_ref_type TEXT NOT NULL, -- 'vocabulary', 'grammar', 'letter'
  prompt_text TEXT,
  prompt_audio_asset_id UUID REFERENCES audio_assets(id),
  correct_answer TEXT NOT NULL,
  difficulty INTEGER NOT NULL DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  points_base INTEGER NOT NULL DEFAULT 10,
  hint_vi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE question_options (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  option_text TEXT,
  option_audio_asset_id UUID REFERENCES audio_assets(id),
  option_image_asset_id UUID REFERENCES image_assets(id),
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- GAMEPLAY
-- ============================================================

CREATE TABLE quests (
  id TEXT PRIMARY KEY,
  world_id TEXT NOT NULL REFERENCES worlds(id),
  area_id TEXT REFERENCES world_areas(id),
  name_en TEXT NOT NULL,
  name_vi TEXT NOT NULL,
  description_vi TEXT,
  quest_type TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  unlock_condition_json JSONB NOT NULL DEFAULT '{"type": "world_unlocked"}',
  reward_exp INTEGER NOT NULL DEFAULT 0,
  reward_gold INTEGER NOT NULL DEFAULT 0,
  reward_magic_crystals INTEGER NOT NULL DEFAULT 0,
  reward_items_json JSONB DEFAULT '[]',
  skill_focus skill_type NOT NULL DEFAULT 'all',
  estimated_minutes INTEGER DEFAULT 5,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE quest_steps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quest_id TEXT NOT NULL REFERENCES quests(id) ON DELETE CASCADE,
  step_order INTEGER NOT NULL,
  step_type TEXT NOT NULL CHECK (step_type IN ('dialogue', 'mini_game', 'exploration', 'collection')),
  mini_game_type mini_game_type,
  dialogue_key TEXT,
  content_ref_id TEXT,
  config_json JSONB DEFAULT '{}',
  is_optional BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (quest_id, step_order)
);

CREATE TABLE mini_games (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  game_type mini_game_type NOT NULL,
  name_en TEXT NOT NULL,
  config_json JSONB NOT NULL DEFAULT '{}',
  skill_tested skill_type NOT NULL,
  difficulty_base INTEGER NOT NULL DEFAULT 1,
  time_limit_seconds INTEGER, -- NULL means no time limit
  lives_count INTEGER NOT NULL DEFAULT 3,
  pass_threshold_percent INTEGER NOT NULL DEFAULT 70 CHECK (pass_threshold_percent BETWEEN 1 AND 100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Links vocabulary to mini-games (enables content reuse)
CREATE TABLE mini_game_vocab_links (
  mini_game_id UUID NOT NULL REFERENCES mini_games(id) ON DELETE CASCADE,
  vocab_id TEXT NOT NULL REFERENCES vocabulary(id) ON DELETE CASCADE,
  PRIMARY KEY (mini_game_id, vocab_id)
);

CREATE TABLE rewards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reward_type TEXT NOT NULL CHECK (reward_type IN ('exp', 'gold', 'item', 'crystal', 'achievement')),
  reward_key TEXT NOT NULL UNIQUE,
  name_vi TEXT NOT NULL,
  amount INTEGER NOT NULL DEFAULT 1,
  icon_asset_id UUID REFERENCES image_assets(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  item_key TEXT NOT NULL UNIQUE,
  name_vi TEXT NOT NULL,
  description_vi TEXT,
  item_type item_type NOT NULL,
  rarity item_rarity NOT NULL DEFAULT 'common',
  image_asset_id UUID REFERENCES image_assets(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  achievement_key TEXT NOT NULL UNIQUE,
  name_vi TEXT NOT NULL,
  description_vi TEXT,
  condition_json JSONB NOT NULL,
  reward_id UUID REFERENCES rewards(id),
  icon_asset_id UUID REFERENCES image_assets(id),
  is_secret BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- PLAYER DATA
-- ============================================================

CREATE TABLE player_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  player_id UUID NOT NULL UNIQUE REFERENCES player_profiles(id) ON DELETE CASCADE,
  total_quests_completed INTEGER NOT NULL DEFAULT 0,
  total_vocab_mastered INTEGER NOT NULL DEFAULT 0,
  total_exp INTEGER NOT NULL DEFAULT 0,
  highest_world_id TEXT REFERENCES worlds(id),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE player_world_progress (
  player_id UUID NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
  world_id TEXT NOT NULL REFERENCES worlds(id),
  is_unlocked BOOLEAN NOT NULL DEFAULT FALSE,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  stars_earned INTEGER NOT NULL DEFAULT 0 CHECK (stars_earned >= 0),
  completion_percent FLOAT NOT NULL DEFAULT 0 CHECK (completion_percent BETWEEN 0 AND 100),
  first_unlocked_at TIMESTAMPTZ,
  first_completed_at TIMESTAMPTZ,
  PRIMARY KEY (player_id, world_id)
);

CREATE TABLE player_lesson_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  player_id UUID NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
  lesson_id TEXT NOT NULL REFERENCES lessons(id),
  attempts INTEGER NOT NULL DEFAULT 0,
  best_score INTEGER NOT NULL DEFAULT 0,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  UNIQUE (player_id, lesson_id)
);

CREATE TABLE player_quest_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  player_id UUID NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
  quest_id TEXT NOT NULL REFERENCES quests(id),
  status quest_status NOT NULL DEFAULT 'locked',
  stars_earned INTEGER NOT NULL DEFAULT 0 CHECK (stars_earned BETWEEN 0 AND 3),
  current_step INTEGER NOT NULL DEFAULT 0,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  UNIQUE (player_id, quest_id)
);

-- Learning attempts: analytics-friendly, minimal PII
CREATE TABLE learning_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  player_id UUID NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id),
  session_id UUID NOT NULL,
  answer_given TEXT,
  is_correct BOOLEAN NOT NULL,
  response_time_ms INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  -- No name, no email, no personal data beyond player_id
);

-- SRS: Spaced Repetition per player per vocabulary item
CREATE TABLE vocabulary_mastery (
  player_id UUID NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
  vocab_id TEXT NOT NULL REFERENCES vocabulary(id),
  mastery_level INTEGER NOT NULL DEFAULT 0 CHECK (mastery_level BETWEEN 0 AND 5),
  ease_factor FLOAT NOT NULL DEFAULT 2.5 CHECK (ease_factor >= 1.3),
  interval_days INTEGER NOT NULL DEFAULT 1 CHECK (interval_days >= 1),
  repetitions INTEGER NOT NULL DEFAULT 0,
  next_review_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_reviewed_at TIMESTAMPTZ,
  PRIMARY KEY (player_id, vocab_id)
);

CREATE TABLE review_schedule (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  player_id UUID NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
  vocab_id TEXT NOT NULL REFERENCES vocabulary(id),
  scheduled_at TIMESTAMPTZ NOT NULL,
  completed_at TIMESTAMPTZ,
  result srs_quality
);

CREATE TABLE player_inventory (
  player_id UUID NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES items(id),
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  acquired_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (player_id, item_id)
);

CREATE TABLE player_achievements (
  player_id UUID NOT NULL REFERENCES player_profiles(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES achievements(id),
  earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (player_id, achievement_id)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_player_profiles_user_id ON player_profiles(user_id);
CREATE INDEX idx_vocabulary_category ON vocabulary(category);
CREATE INDEX idx_vocabulary_difficulty ON vocabulary(difficulty);
CREATE INDEX idx_vocabulary_world ON vocabulary(world_id);
CREATE INDEX idx_vocabulary_tags ON vocabulary USING GIN(tags);
CREATE INDEX idx_quests_world ON quests(world_id);
CREATE INDEX idx_quests_order ON quests(world_id, order_index);
CREATE INDEX idx_learning_attempts_player ON learning_attempts(player_id, created_at);
CREATE INDEX idx_learning_attempts_session ON learning_attempts(session_id);
CREATE INDEX idx_vocabulary_mastery_player ON vocabulary_mastery(player_id, next_review_at);
CREATE INDEX idx_review_schedule_player ON review_schedule(player_id, scheduled_at);
CREATE INDEX idx_player_quest_progress_player ON player_quest_progress(player_id, status);
CREATE INDEX idx_character_dialogues_key ON character_dialogues(dialogue_key);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================
ALTER TABLE player_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE parental_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_world_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_quest_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE vocabulary_mastery ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_achievements ENABLE ROW LEVEL SECURITY;

-- Players can only access their own profile
CREATE POLICY "Users can view own profile"
  ON player_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON player_profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON player_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Player progress: access own data only
CREATE POLICY "Players access own progress"
  ON player_quest_progress FOR ALL
  USING (player_id IN (SELECT id FROM player_profiles WHERE user_id = auth.uid()));

CREATE POLICY "Players access own mastery"
  ON vocabulary_mastery FOR ALL
  USING (player_id IN (SELECT id FROM player_profiles WHERE user_id = auth.uid()));

CREATE POLICY "Players access own attempts"
  ON learning_attempts FOR ALL
  USING (player_id IN (SELECT id FROM player_profiles WHERE user_id = auth.uid()));

-- Game content is public read (vocabulary, quests, worlds, etc.)
-- No RLS needed on content tables (they are read-only for all authenticated users)

-- ============================================================
-- SEED DATA: WORLDS
-- ============================================================
INSERT INTO worlds (id, slug, name_en, name_vi, theme, order_index, is_active, description_vi) VALUES
  ('world_1', 'alphabet-island', 'Alphabet Island', 'Đảo Chữ Cái', 'tropical_fantasy', 1, TRUE, 'Nơi 26 chữ cái đang chờ được giải cứu khỏi The Silent Shadow'),
  ('world_2', 'vocabulary-forest', 'Vocabulary Forest', 'Rừng Từ Vựng', 'enchanted_forest', 2, FALSE, 'Rừng ma thuật chứa hàng trăm từ vựng bí ẩn'),
  ('world_3', 'sentence-kingdom', 'Sentence Kingdom', 'Vương Quốc Câu Chữ', 'medieval_castle', 3, FALSE, 'Vương quốc nơi các từ ghép lại thành câu hoàn chỉnh'),
  ('world_4', 'listening-ocean', 'Listening Ocean', 'Đại Dương Âm Thanh', 'underwater_adventure', 4, FALSE, 'Đại dương bí ẩn nơi âm thanh là chìa khóa'),
  ('world_5', 'speaking-city', 'Speaking City', 'Thành Phố Giao Tiếp', 'modern_cartoon_city', 5, FALSE, 'Thành phố sôi động nơi mọi người dùng tiếng Anh để giao tiếp'),
  ('world_6', 'challenge-kingdom', 'Challenge Kingdom', 'Vương Quốc Thử Thách', 'epic_fortress', 6, FALSE, 'Nơi thử thách cuối cùng và Boss Final đang chờ đợi');

-- ============================================================
-- SEED DATA: CHARACTERS
-- ============================================================
INSERT INTO characters (id, slug, name_en, name_vi, character_type, description_vi) VALUES
  ('char_player_boy', 'player-boy', 'Explorer (Boy)', 'Nhà Thám Hiểm (Nam)', 'player', 'Nhân vật chính nam, dũng cảm và tò mò'),
  ('char_player_girl', 'player-girl', 'Explorer (Girl)', 'Nhà Thám Hiểm (Nữ)', 'player', 'Nhân vật chính nữ, thông minh và dũng cảm'),
  ('char_buddy', 'buddy-dragon', 'Buddy', 'Buddy', 'buddy', 'Rồng nhỏ đồng hành trung thành, luôn hướng dẫn và động viên người chơi'),
  ('char_professor_owl', 'professor-owl', 'Professor Owl', 'Giáo Sư Cú', 'professor', 'Học giả uyên bác giảng dạy ngữ âm và ngữ pháp bằng tiếng Việt'),
  ('char_boss_shadow', 'shadow-silencer', 'Shadow Silencer', 'Bóng Tối Im Lặng', 'boss', 'Boss cuối của Alphabet Island – thực thể cướp đi âm thanh của chữ cái');

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_player_profiles_updated_at
  BEFORE UPDATE ON player_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_parental_settings_updated_at
  BEFORE UPDATE ON parental_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
