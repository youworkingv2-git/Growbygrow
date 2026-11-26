## Vietnamese Localization Strings

This file contains all UI strings displayed in Vietnamese (the instruction language for English Adventure).

**Format:** Key = Vietnamese string
**Usage:** Access via LocalizationManager.get_string("key")

### File structure
- `vi/ui_common.csv` – Buttons, labels, common UI
- `vi/buddy_dialogues.csv` – Buddy's Vietnamese guidance
- `vi/feedback.csv` – Correct/wrong feedback messages
- `vi/quest_names.csv` – Quest names and descriptions
- `vi/tutorial.csv` – Tutorial and onboarding text
- `vi/settings.csv` – Settings screen strings

### Rules
1. All English learning content is in English (not translated here)
2. Interface chrome and instructions are in Vietnamese
3. Buddy speaks Vietnamese when explaining concepts
4. Error messages are in Vietnamese
5. Achievement descriptions are in Vietnamese

### Adding new strings
1. Add to the appropriate CSV file
2. Use the format: `KEY,Vietnamese text`
3. Never hardcode Vietnamese strings in GDScript
4. Use `LocalizationManager.get_string("KEY")` in code
