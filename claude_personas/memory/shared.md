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

### ✅ All recent work deployed (v547–v557)
- Backlog sprint (BEM rename, stats, NYT calendar) — v548
- Vendor Chart.js, CLAUDE.md refresh, session specs — v549
- Solve timer, next puzzle, profile N+1, FriendshipService, error pages — v550
- Visual design review (12 items: empty states, sticky footer, nav labels, error pages, etc.) — v554
- Loading feedback system (4 layers: nav dimming, disable_with, solve toolbar, pattern search) — v555
- Edit save bugs + account settings rebuild + home page polish — v557

### ✅ Edit Page Frontend Review — COMPLETE (2026-03-05)
All 13 items from Playwright audit addressed (12 fixed, 1 assessed as non-issue):
- **Must-fix:** scroll_to_selected crash, tool panel 90%→45vh sizing, row height jump (already fixed)
- **Should-fix:** dead settings modal removed, phone button overlap fixed, phone switch labels fixed, number_clues NaN fixed, event handler leaks (non-issue — Turbo replaces body)
- **Dead code:** spin_title(), jquery-ui vendor file, #tools/#settings CSS all deleted
- **Tests:** 5 settings modal specs removed, Turbo Drive test updated. 942 specs pass, 0 failures.
- **No migration.** CSS + JS only. Builder → Deployer: No action needed.

### Remaining visual items (not addressed):
- Solve page toolbar icons cramped on mobile (minor)
- Admin panel table unstyled (low priority)

## Backlog

### Clue Suggestions from Phrase DB
Creator feature: suggest clues during puzzle editing based on 53K existing phrases. Query by
word content + text prefix. Infrastructure ready (Phrase model, Word model, pg_search).
Not yet planned in detail — next after timer/next-puzzle ships.
