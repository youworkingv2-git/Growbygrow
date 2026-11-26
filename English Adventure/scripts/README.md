# Scripts Architecture Map (17 Modules)

Toàn bộ logic GDScript trong `scripts/` được tổ chức theo kiến trúc Modular trong `docs/ARCHITECTURE.md`:

| Thư mục | Các Module đảm nhiệm |
|---|---|
| `scripts/core/` | **1. Core Module** (`EventBus`, `SceneRouter`, `AppConfig`, `AppLogger`, `DataValidator`) |
| `scripts/adventure/` | **2. Adventure Module** (World state, Zone triggers, Camera, Exploration) |
| `scripts/character/` | **3. Character Module** (Player controller, Buddy companion, NPC, Dialogue Runner) |
| `scripts/quest/` | **4. Quest Module** (QuestManager, Step evaluator) |
| `scripts/learning/` | **5. Learning Module**, **6. Vocabulary Module**, **7. Grammar Module** (Content repositories & QuestionFactory) |
| `scripts/mini_games/` | **8. Mini-game Module** (`BaseMiniGame`, shared widgets, 5 MVP mini-games) |
| `scripts/audio/` | **9. Audio Module** (BGM/SFX/VoiceEN/VoiceVI buses, accent fallback, mic capture adapter) |
| `scripts/assessment/` | **10. Assessment Module** (Initial placement check, adaptive difficulty) |
| `scripts/progression/` | **11. Review Module**, **12. Progress Module**, **13. Reward Module**, **14. Inventory Module** |
| `scripts/localization/` | **15. Localization Module** (`vi`/`en` bilingual formatting & UI strings) |
| `scripts/services/` | **16. Backend Service Module** (Supabase REST/Auth) & **17. Save/Load Module** (`user://` + sync queue) |

> **Lưu ý:** Code triển khai sẽ bắt đầu từ **Prompt 02**. Không chứa file giả ở giai đoạn Prompt 01.
