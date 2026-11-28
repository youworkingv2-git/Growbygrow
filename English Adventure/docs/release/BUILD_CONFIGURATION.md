# CẤU HÌNH BUILD ĐA NỀN TẢNG (BUILD CONFIGURATION)
# PROJECT: ENGLISH ADVENTURE

**Engine cố định:** Godot `4.3` Standard (GDScript, không dùng .NET), Renderer `gl_compatibility`.  
**Tệp cấu hình chính:** `project.godot`, `export_presets.cfg`, `data/release/version.json`.

---

## 1. Phân biệt Development Build và Release Build

| Tiêu chí | Development Build (`OS.is_debug_build() == true`) | Release Build (`--export-release`) |
|---|---|---|
| `AppLogger.min_level` | `DEBUG` (in đầy đủ log chẩn đoán cục bộ) | `INFO` (tắt DEBUG verbose, giữ `INFO/WARN/ERROR` đã che secret) |
| Nội dung học tập | Có thể thử nghiệm dữ liệu mới | `LearningContentRepository` chỉ nạp `approved` / `published` |
| Dữ liệu test & Tool nội bộ | Cho phép chạy `tests/`, `tools/` | `exclude_filter="tests/*,tools/*,docs/*,supabase/*"` loại bỏ khỏi `.pck` |
| Secrets / Key | Không chứa secret thật trong repo | Tuyệt đối 0 secret trong `.pck` hoặc `export_presets.cfg` |

---

## 2. Cấu hình Export Presets (`export_presets.cfg`)

| Preset Index | Tên Preset | Đường dẫn đầu ra | Lưu ý cấu hình chính |
|---|---|---|---|
| `preset.0` | `Web` | `builds/web/index.html` | Single-threaded WASM, `canvas_resize_policy=2`, `experimental_virtual_keyboard=true` |
| `preset.1` | `Windows Desktop` | `builds/windows/EnglishAdventure.exe` | Kiến trúc `x86_64`, S3TC/BPTC texture compression, `file_version="0.9.0.0"` |
| `preset.2` | `Android` | `builds/android/EnglishAdventure.apk` | `com.englishadventure.game`, `arm64-v8a`, `min_sdk=24`, `target_sdk=35`, `RECORD_AUDIO` & `INTERNET` |
| `preset.3` | `Android AAB` | `builds/android/EnglishAdventure.aab` | `use_gradle_build=true`, `export_format=1` (Google Play App Bundle) |
| `preset.4` | `iOS` | `builds/ios/EnglishAdventure.ipa` | `com.englishadventure.game`, `NSMicrophoneUsageDescription` tiếng Việt |

## 3. Quy trình build lặp lại
- Windows PowerShell: `.\tools\build_release.ps1 -Target windows`
- Linux / macOS: `./tools/build_release.sh windows` (hoặc `android_apk`, `android_aab`, `ios`, `web`)
- GitHub Actions CI: `.github/workflows/release-multiplatform.yml`
