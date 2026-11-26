## Services Module

**Purpose:** All communication with Supabase backend. Provides a clean API layer that the rest of the game uses to interact with the backend. The game never calls Supabase APIs directly.

**Key Scripts:**
- `supabase_client.gd` – Low-level HTTP client for Supabase REST API. Manages auth headers, request queuing, retry logic.
- `auth_service.gd` – Sign up, sign in (email), anonymous guest login, sign out, session refresh.
- `sync_service.gd` – Syncs local progress data to Supabase when online. Handles conflicts.
- `content_service.gd` – Fetches game content (vocabulary, quests, worlds) from Supabase when updates are available.
- `progress_service.gd` – Pushes player progress (quest completion, mastery, XP) to Supabase.

**Security Rules:**
1. ONLY the Supabase Anon Key is stored in the client (loaded from config, never hardcoded).
2. The Service Role Key is NEVER used in the client.
3. All data access is controlled by Supabase Row Level Security (RLS).
4. Players can only read/write their own data (enforced by RLS, not just client-side).

**Offline Strategy:**
- All writes go to local SaveManager first.
- SyncService queues changes and uploads when connectivity is restored.
- Content is cached locally after first download.

**Error Handling:**
```gdscript
# All service calls return Result objects:
class_name Result
var success: bool
var data: Variant
var error_code: int
var error_message: String
```

**Dependencies:**
- Core Module (config_manager for Supabase URL/key, EventBus for network status)
- Save/Load Module (local queue for offline sync)

**Does NOT depend on:**
- Learning Module
- Adventure Module
- Mini-game Module
