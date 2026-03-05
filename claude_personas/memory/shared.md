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

### Loading Feedback System (4 layers) — Built 2026-03-04
- Layer 1: Global Turbo nav dimming (`.xw-loading` on click, spinner on puzzle cards)
- Layer 2: `disable_with` on 16 form buttons across 12 HAML files
- Layer 3: Solve toolbar busy state (`.xw-btn--busy` spinner, `.xw-btn--saved` green pulse)
- Layer 4: Edit pattern search wired to `loading_controller.js`
- No migrations. Pure JS/CSS/HAML changes.
- Builder → Deployer: No migration needed. Standard deploy.

## Active / In Progress

### ✅ All recent work deployed (v547–v554)
- Backlog sprint (BEM rename, stats, NYT calendar) — v548
- Vendor Chart.js, CLAUDE.md refresh, session specs — v549
- Solve timer, next puzzle, profile N+1, FriendshipService, error pages — v550
- Visual design review (12 items: empty states, sticky footer, nav labels, error pages, etc.) — v554

### Remaining visual items (not addressed):
- Solve page toolbar icons cramped on mobile (minor)
- Admin panel table unstyled (low priority)

## Backlog

### Clue Suggestions from Phrase DB
Creator feature: suggest clues during puzzle editing based on 53K existing phrases. Query by
word content + text prefix. Infrastructure ready (Phrase model, Word model, pg_search).
Not yet planned in detail — next after timer/next-puzzle ships.
