# Shared Project Board

Cross-persona handoffs. Keep this short — completed items get removed once deployed.

## Builder Pickup Rules

When a Builder picks up a plan:
1. **Timestamp it.** Add `Picked up by Builder at YYYY-MM-DD HH:MM` to the item.
2. **Check for conflicts.** If an item already has a pickup timestamp within the last
   15 minutes, **do not pick it up** — another Builder is already working on it.
3. After 15 minutes with no commit, the pickup expires and the item is available again.

## Pending Deploy

Items built but not yet deployed to production.

_(Nothing pending — all clear.)_

## Active / In Progress

### Planner → Builder: Vendor Chart.js (Replace CDN)
Swap jsdelivr CDN → vendored local file. 3 files, 5 minutes. Full plan in `plan.md`.
- `curl` Chart.js v4 UMD → `vendor/assets/javascripts/chart.umd.min.js`
- HAML: `javascript_include_tag 'chart.umd.min'` (was full CDN URL)
- Stimulus: remove CDN load fallback (3 lines → 1)

### Planner → Builder: Solve Timer + Next Puzzle on Win

Full plan in `claude_personas/memory/plan.md`. **6 files modified, 0 new, 0 migrations.** Key points:
- **Timer:** `solution.created_at` → JS as epoch ms. Client-side `setInterval(1s)`. Freezes on
  win or if already complete. Format: `MM:SS` / `H:MM:SS` / `Dd H:MM:SS`. Muted monospace.
- **Next puzzle:** `Crossword.new_to_user(@current_user).order("RANDOM()").first` at
  check_completion time. Falls back to random for anonymous. Link + title in win modal.
- **3 new specs** in crosswords_spec.rb.

### Planner → Builder: CLAUDE.md Refresh
CLAUDE.md is stale — "Architecture Direction" and "Known Runtime Risks" sections list work
that's been completed. All 6 runtime risks are fixed. All 4 architecture principles are done
(except team broadcast — assessed as "already clean," not worth extracting). Update to reflect
current state. Also update CellEdit reference (deleted) and test count (~893, not ~693).

### ✅ Backlog Sprint — Complete (Deployed v547)
1. Puzzle Card BEM Rename — deployed
2. Stats Page Modernization — deployed
3. NYT Calendar smart init + year nav — deployed
4. Test Suite Performance — closed (already adopted)

## Backlog

### Clue Suggestions from Phrase DB
Creator feature: suggest clues during puzzle editing based on 53K existing phrases. Query by
word content + text prefix. Infrastructure ready (Phrase model, Word model, pg_search).
Not yet planned in detail — next after timer/next-puzzle ships.
