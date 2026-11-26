## Content Validation Tools

This directory contains tools for validating learning content before it goes into the game.

### Tools

#### `validate_vocabulary.py`
Validates vocabulary JSON files:
- Checks all required fields are present
- Validates IPA format
- Checks audio file naming conventions
- Verifies image file naming conventions
- Validates difficulty scale (1-5)
- Checks for duplicate IDs
- Validates example sentences (basic grammar check)

**Usage:**
```bash
python tools/content_validator/validate_vocabulary.py data/vocabulary/world_1/
```

#### `validate_alphabet.py`
Validates alphabet/phonics data:
- Checks letter names vs letter sounds are different
- Validates audio file references
- Checks IPA phoneme format

#### `check_assets.py`
Checks that all referenced asset files exist:
- Audio files (mp3)
- Image files (png)
- Reports missing assets

### Rules for Content Creators
1. Never upload content without running validation first
2. Audio files: `[word]_us.mp3` and `[word]_gb.mp3`
3. Image files: `[word].png` (lowercase, no spaces)
4. IPA must use standard Unicode IPA characters
5. Vietnamese meanings must be provided for every word
6. All 4 skills should be listed unless a word is truly not usable in a skill

### Adding 600-800 Words (Future Scale)
The system is designed so that adding vocabulary requires:
1. Add entry to vocabulary JSON file
2. Provide audio files
3. Provide image file
4. Run validation
5. Upload assets to Supabase Storage
6. Import JSON to database
No code changes required.
