# Workflow Rule: Instant Live Update & GitHub Sync

1. **Immediate Live Update**:
   - Whenever vocabulary, content, or code changes are requested, update the data files (`data/all-topics-*.json` and `data/generate/*.json`) and application code (`index.html`) immediately.
   - Ensure the static server / live preview serves the updated content so the user can test right away on `http://127.0.0.1:5502/index.html`.

2. **Immediate GitHub Push**:
   - After completing and validating the user's requested updates, automatically commit and push the changes to GitHub (`git add`, `git commit -m "..."`, `git push`).
