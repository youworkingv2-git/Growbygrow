# UI/UX Design Specification
## English Adventure

| Field | Value |
|---|---|
| **Document Version** | 1.0 |
| **Date** | 2026-11-26 |
| **Art Direction** | 2.5D Colorful Cartoon Fantasy (Age 10 — friendly, adventurous, not babyish) |
| **Instruction Language** | Vietnamese (`vi`) |
| **Target Platforms** | Mobile Portrait (primary), Mobile Landscape, Tablet, Desktop Web |

---

## 1. Design System

### 1.1 Color Palette
| Token | Hex | Usage |
|---|---|---|
| **Adventure Blue** | `#1A6FBF` | Primary buttons, headers, sky accents |
| **Emerald Green** | `#2ECC71` | Correct answers, progress bars, confirm actions |
| **Golden Yellow** | `#F1C40F` | Stars, Gold, Magic Crystals, highlights |
| **Coral Red** | `#E74C3C` | Hearts/lives, gentle error highlight (never harsh) |
| **Warm Cream** | `#FFFDF5` | Card backgrounds, dialogue boxes (high readability) |
| **Deep Navy** | `#1B263B` | Body text (high contrast on Warm Cream) |

### 1.2 Typography & Accessibility
- **Headings:** Rounded, bold display font (e.g., *Fredoka* / *Nunito ExtraBold*, Vietnamese diacritics supported).
- **Body & Dialogue:** Clean rounded sans-serif (*Nunito* / *Quicksand*), minimum `18px` on mobile, `20px+` on tablet/desktop.
- **Touch Targets:** Minimum `48x48dp` (64dp+ for primary mini-game tiles).
- **Audio-First Rule:** Every English prompt and button has a visible Speaker icon so struggling readers can always listen.

---

## 2. Screen Specifications (18 Screens)

### 1. Splash Screen
- **Purpose:** Brand intro, initialize Core/Audio/Localization modules, check local save.
- **Layout:** Centered animated logo + Buddy peeking + progress bar at bottom.
- **UI Components:** Game Logo, Animated Dragon sprite, ProgressBar, Version label.
- **Navigation:** Auto-advances to **Login Screen** (if no session) or **Home Screen** (if returning).
- **User Interactions:** Tap anywhere to skip intro animation after load completes.
- **Responsive:** Centered hero scales proportionally; background parallax fills aspect ratio (`expand`).
- **States:** Loading (animated bar + "Đang tải...") | Empty (N/A) | Error (Offline fallback notice, still proceeds offline).

### 2. Login / Register Screen
- **Purpose:** Authenticate via Supabase or start immediately as an Anonymous Guest.
- **Layout:** Centered card over animated island background.
- **UI Components:** "Chơi ngay (Không cần đăng ký)" primary CTA, Email/Password fields, "Đăng nhập / Đăng ký" secondary buttons, Parental Gate notice for account creation.
- **Navigation:** From Splash/Settings → To **Character Selection** (new player) or **Home Screen** (returning).
- **User Interactions:** Tap guest play (zero friction) or enter email credentials.
- **Responsive:** Full-width card on Portrait; centered 480px modal card on Landscape/Tablet/Desktop.
- **States:** Loading (spinner on button) | Empty (N/A) | Error (Vietnamese inline message: "Email hoặc mật khẩu chưa đúng").

### 3. Character Selection
- **Purpose:** Choose Boy or Girl explorer, enter nickname, meet Buddy.
- **Layout:** Split character showcase + name input + "Bắt đầu phiêu lưu!" button.
- **UI Components:** Boy/Girl animated cards, Name TextEdit (1–20 chars), Buddy speech bubble.
- **Navigation:** From Login (new user) → To **Initial Assessment**.
- **User Interactions:** Tap Boy/Girl to preview animation, type name, tap Start.
- **Responsive:** Vertical stack on Portrait; side-by-side cards on Landscape/Desktop.
- **States:** Loading (saving profile) | Empty (default name prompt) | Error (profanity/empty name warning in Vietnamese).

### 4. Initial Assessment
- **Purpose:** Gauge baseline English (0–5 minutes, non-intimidating) to calibrate starting hints.
- **Layout:** Buddy dialogue banner + 1 large question card + progress dots (5–8 items max).
- **UI Components:** Buddy avatar, Audio replay button, 2–4 image/letter choice cards, "Mình chưa biết từ này" (Skip/Don't know) button.
- **Navigation:** From Character Selection → To **Home Screen** (or directly to Quest 1).
- **User Interactions:** Tap choice or tap "Chưa biết" (encouraged—no red X!).
- **Responsive:** 2x2 grid on Portrait; 4-in-a-row on Landscape/Desktop.
- **States:** Loading (preparing questions) | Empty (N/A) | Error (falls back to bundled local assessment JSON).

### 5. Home Screen
- **Purpose:** Central hub with Buddy greeting, quick-continue quest, and navigation.
- **Layout:** Top bar (Avatar, Level, Gold, Crystals) | Center (Buddy + Daily Review card + "Tiếp tục phiêu lưu" hero CTA) | Bottom/Side Nav.
- **UI Components:** Resource HUD, Buddy interactive sprite (tap for fun animation), Continue Quest button, Daily Review badge, Nav bar (Bản đồ, Túi đồ, Thành tích, Bảng học tập, Cài đặt).
- **Navigation:** Hub to **World Map**, **World Detail**, **Inventory**, **Achievement**, **Learning Dashboard**, **Settings**.
- **User Interactions:** Tap Continue, tap Buddy, switch tabs.
- **Responsive:** Bottom navigation bar on Portrait; Left sidebar rail on Desktop/Tablet Landscape.
- **States:** Loading (syncing indicator) | Empty (first-time welcome state) | Error (offline badge in corner; all local features work).

### 6. World Map
- **Purpose:** Show all 6 Worlds of Linguara, highlighting Alphabet Island (MVP) and future locked worlds.
- **Layout:** Scrollable illustrated fantasy map with 6 island/kingdom nodes connected by a dotted path.
- **UI Components:** 6 World Nodes (active vs. fog/locked), Star counter per world, "Sắp ra mắt" tag on Worlds 2–6.
- **Navigation:** From Home → To **World Detail** (Alphabet Island).
- **User Interactions:** Pan/scroll map, tap Alphabet Island to enter.
- **Responsive:** Vertical scroll map on Portrait; wide panoramic horizontal map on Landscape/Desktop.
- **States:** Loading (map fade-in) | Empty (N/A) | Error (shows local cached map state).

### 7. World Detail (Alphabet Island)
- **Purpose:** Explore the 4 regions of Alphabet Island, see NPCs, and pick quests.
- **Layout:** Interactive 2.5D island view with 4 region pins, NPC markers, and floating Quest cards.
- **UI Components:** Region selector, Quest pin markers (Locked / Available / 1–3 Stars), Buddy hint bubble, Back button.
- **Navigation:** From World Map → To **Quest Selection** or **Quest Introduction**.
- **User Interactions:** Tap region or quest pin.
- **Responsive:** Pan-able canvas on Portrait; full-screen island overview with side quest drawer on Desktop.
- **States:** Loading (scene transition) | Empty (N/A) | Error (retry load local scene).

### 8. Quest Selection
- **Purpose:** Browse quests in a region, see star ratings, skill icons, and rewards.
- **Layout:** Header + scrollable list/grid of Quest Cards.
- **UI Components:** Quest Card (Title VI/EN, Skill badges, 0–3 Stars, EXP/Gold preview, Lock overlay).
- **Navigation:** From World Detail → To **Quest Introduction**.
- **User Interactions:** Scroll, tap unlocked quest.
- **Responsive:** 1-column list on Portrait; 2–3 column grid on Tablet/Desktop.
- **States:** Loading (skeleton cards) | Empty ("Hoàn thành khu vực trước để mở khóa!") | Error (reload button).

### 9. Quest Introduction
- **Purpose:** Story briefing by Buddy / Professor Owl / NPC before mini-games begin.
- **Layout:** 2.5D scene backdrop + large character portraits + dialogue box + "Bắt đầu!" button.
- **UI Components:** Character portraits (speaking character highlighted), Vietnamese dialogue text, optional English preview audio, Next/Skip buttons.
- **Navigation:** From Quest Selection → To **Gameplay Screen**.
- **User Interactions:** Tap to advance dialogue lines.
- **Responsive:** Portraits above dialogue box on Portrait; side-by-side theater framing on Landscape/Desktop.
- **States:** Loading (preload quest vocab audio) | Empty (N/A) | Error (skip audio if missing, show text).

### 10. Gameplay Screen
- **Purpose:** Unified container for all 5+ mini-games with consistent HUD.
- **Layout:** Top HUD (Pause/Back, Progress bar, 3 Hearts, Score) | Center (Dynamic Mini-Game Area) | Bottom-Right (Buddy Hint button).
- **UI Components:** Hearts display, Step progress bar, Mini-game viewport, Buddy Hint FAB.
- **Navigation:** From Quest Intro → To **Learning Feedback** (per step/round) → **Reward Screen**.
- **User Interactions:** Drag, tap, listen, arrange depending on active mini-game.
- **Responsive:** Mini-game containers dynamically reflow grids (e.g., 2x2 vs. 1x4) per aspect ratio.
- **States:** Loading (spinner while `LearningEngine` prepares batch) | Empty (N/A) | Error (graceful exit to Quest Selection without losing prior progress).

### 11. Learning Feedback
- **Purpose:** Immediate, encouraging Vietnamese + English feedback after an answer or round.
- **Layout:** Non-blocking bottom sheet (for quick answers) or modal overlay (for round summary).
- **UI Components:** Buddy expression (cheering/encouraging), English word + IPA + Speaker button, Vietnamese explanation.
- **Navigation:** Overlays **Gameplay Screen** → advances to next question or **Reward Screen**.
- **User Interactions:** Tap "Tiếp tục" or audio button.
- **Responsive:** Bottom drawer on Portrait; centered compact card on Desktop.
- **States:** Loading (N/A) | Empty (N/A) | Error (text fallback if audio fails).

### 12. Reward Screen
- **Purpose:** Celebrate quest completion with animated Stars, EXP, Gold, and Magic Crystals.
- **Layout:** Center celebration stage + animated counters + "Nhiệm vụ tiếp theo" / "Về bản đồ" buttons.
- **UI Components:** 1–3 Pop-in Stars, EXP bar fill animation, Gold/Crystal badges, unlocked Item card (if any).
- **Navigation:** From Gameplay → To **World Detail** or next **Quest Introduction**.
- **User Interactions:** Tap to speed up counter animation, tap Next.
- **Responsive:** Centered vertical card on all devices; wider horizontal reward showcase on Desktop.
- **States:** Loading (saving progress locally & queuing sync) | Empty (N/A) | Error (saved locally, sync later).

### 13. Inventory Screen
- **Purpose:** View collected Magic Crystals, avatar accessories, and Buddy skins.
- **Layout:** Category tabs + item grid + item detail preview panel.
- **UI Components:** Category tabs, Item cards with rarity border, Equip button (for cosmetics).
- **Navigation:** From Home / Profile → Back to Home.
- **User Interactions:** Filter tabs, tap item to preview/equip.
- **Responsive:** 3-column grid on Portrait; 4–5 columns + side preview on Tablet/Desktop.
- **States:** Loading (local cache) | Empty ("Hãy hoàn thành nhiệm vụ để thu thập vật phẩm!") | Error (reload).

### 14. Achievement Screen
- **Purpose:** Display earned and locked badges with progress bars.
- **Layout:** Summary header (X/20 earned) + badge grid.
- **UI Components:** Badge icon (grayscale if locked, full color if earned), Vietnamese title/condition, progress bar.
- **Navigation:** From Home → Back to Home.
- **User Interactions:** Tap badge for details.
- **Responsive:** 2-column on Portrait; 3–4 column grid on Tablet/Desktop.
- **States:** Loading | Empty ("Chơi nhiệm vụ đầu tiên để mở khóa thành tích!") | Error.

### 15. Player Profile
- **Purpose:** Show explorer avatar, level, streak, and overall CEFR progress.
- **Layout:** Avatar showcase card + stats grid + skill summary.
- **UI Components:** Customizable Avatar preview, Edit Name button, Level/EXP bar, Streak counter, 4-skill radar/bars.
- **Navigation:** From Home → To **Inventory** or **Learning Dashboard**.
- **User Interactions:** Edit display name, switch Boy/Girl outfit.
- **Responsive:** Stacked cards on Portrait; 2-column dashboard on Desktop.
- **States:** Loading | Empty (default new player stats) | Error.

### 16. Learning Dashboard
- **Purpose:** Give child (and curious parents) clear visibility into mastered words and daily SRS reviews.
- **Layout:** Review Due banner ("Ôn tập hôm nay: X từ") + 4 Skill Progress Bars (L/S/R/W) + Word Mastery list.
- **UI Components:** "Ôn tập ngay" CTA, L/S/R/W progress bars, Mastered/Learning word filterable list.
- **Navigation:** From Home / Profile → Launches SRS Review session in **Gameplay Screen**.
- **User Interactions:** Tap Review Now, tap any word to hear pronunciation.
- **Responsive:** Vertical scroll on Portrait; multi-panel grid on Tablet/Desktop.
- **States:** Loading | Empty ("Học từ mới ở Đảo Chữ Cái để bắt đầu!") | Error.

### 17. Settings Screen
- **Purpose:** Manage audio, accent preference (`en-US` / `en-GB`), account, and offline sync.
- **Layout:** Grouped settings list.
- **UI Components:** Music/SFX/Voice sliders, Accent selector, Account link/logout button, Manual Sync button, Credits/Privacy Policy.
- **Navigation:** From Home → Back to Home (or Login on logout).
- **User Interactions:** Toggle switches, drag sliders.
- **Responsive:** Centered single column (max-width 640px on Desktop).
- **States:** Loading (syncing) | Empty (N/A) | Error (sync error toast).

### 18. Parent Dashboard *(Future Phase — NOT in MVP)*
- **Purpose:** Allow parents to view detailed weekly learning analytics, set daily play limits, and manage child accounts behind a Parental Gate.
- **Status:** **Post-MVP.** Database schema (`parental_settings`) is prepared, but UI is deferred to Phase 2+.
