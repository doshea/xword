# P2-6: JS Event Listener Cleanup

## Audit Summary

The initial meta-plan flagged 4 concerns: leaking Stimulus controllers, stacking edit handlers,
inline win modal JS, and missing `disconnect()` methods. After reading every JS file and HAML
view in the codebase, **3 of 4 are false alarms**. The codebase's JS hygiene is solid.

### Why Most "Leaks" Don't Exist

Turbo Drive replaces `<body>` on navigation. jQuery `.on()` handlers bound to elements inside
the body (e.g. `$('#comments').on(...)`) are attached to fresh DOM nodes each `turbo:load` —
old nodes and their handlers are garbage collected. This eliminates the stacking concern for
all solve/edit/new page handlers.

All 15 Stimulus controllers have correct `connect()`/`disconnect()` lifecycle management,
including the 3 that use `document.addEventListener` (dropdown, nav, notification-dropdown).

---

## Findings

### MUST-FIX: Global keyboard suppression leak

**File:** `crossword_funcs.js:265-266`
**Severity:** must-fix

```javascript
document.onkeydown = cw.suppressBackspaceAndNav;
document.onkeypress = cw.suppressBackspaceAndNav;
```

These run at parse time when `solve.js` or `edit.js` first loads in `<head>`. Because
`data-turbo-track: reload` keeps the `<script>` tag in `<head>` across all subsequent Turbo
navigations, these handlers **persist globally** — even on home, search, profile, and other
non-crossword pages.

**Impact:** After visiting any solve/edit page, arrow keys and space are suppressed on ALL
subsequent pages (outside inputs/textareas). This prevents keyboard scrolling site-wide.
Backspace calls `cw.selected.delete_letter()` but has a nil guard (`if (!cw.selected) return false`),
so it doesn't throw — it just silently suppresses the key.

**Fix:**

Move from top-level property assignment into the existing `turbo:load` handler, and clean up
when leaving crossword pages:

```javascript
// DELETE lines 265-266 (the document.onkeydown/onkeypress assignments)

// ADD inside the existing _cwTurboLoadHandler function (after line 274):
if (window._cwKeydownHandler) {
  document.removeEventListener('keydown', window._cwKeydownHandler);
  document.removeEventListener('keypress', window._cwKeydownHandler);
}
window._cwKeydownHandler = cw.suppressBackspaceAndNav;
document.addEventListener('keydown', window._cwKeydownHandler);
document.addEventListener('keypress', window._cwKeydownHandler);

// ADD a cleanup handler at the bottom of crossword_funcs.js:
document.addEventListener('turbo:before-render', function() {
  if (window._cwKeydownHandler) {
    document.removeEventListener('keydown', window._cwKeydownHandler);
    document.removeEventListener('keypress', window._cwKeydownHandler);
  }
});
```

Wait — there's a simpler approach. The turbo:load handler already has `if (!$(".cell").length) return;`
so it only binds click/keydown handlers on crossword pages. We can put the key suppression
inside that guard and add cleanup on the next turbo:load when cells aren't present:

```javascript
// In _cwTurboLoadHandler, after `if (!$(".cell").length)`:
if (!$(".cell").length) {
  // Clean up key suppression when navigating away from crossword pages
  if (window._cwKeydownHandler) {
    document.removeEventListener('keydown', window._cwKeydownHandler);
    document.removeEventListener('keypress', window._cwKeydownHandler);
    window._cwKeydownHandler = null;
  }
  return;
}

// ... existing handler code ...

// Bind key suppression (replace old document.onkeydown pattern)
if (window._cwKeydownHandler) {
  document.removeEventListener('keydown', window._cwKeydownHandler);
  document.removeEventListener('keypress', window._cwKeydownHandler);
}
window._cwKeydownHandler = cw.suppressBackspaceAndNav;
document.addEventListener('keydown', window._cwKeydownHandler);
document.addEventListener('keypress', window._cwKeydownHandler);
```

**Files:** `app/assets/javascripts/crosswords/crossword_funcs.js`
**Risk:** Low. The handler logic is unchanged; only the binding/unbinding lifecycle changes.
**Test:** Navigate solve → home → press arrow down. Before fix: page doesn't scroll. After fix: page scrolls.

---

### SUGGESTION: Win modal inline JS → Stimulus (defer)

**Files:** `_win_modal_contents.html.haml:50-68`, `_win_modal_js.haml:1-89`
**Severity:** suggestion (not a leak; architectural hygiene)

~100 lines of inline `:javascript` in two win modal partials. The comment enter-to-submit
handler and Flightboard initialization run once when the modal is rendered via Turbo Stream.
Since the win modal only appears once per solve session, there's no practical stacking or leak.

**Why defer:** Extracting to Stimulus requires:
1. A new `WinModalController` with Flightboard init in `connect()` and timer cleanup in `disconnect()`
2. Passing Ruby-computed values (time segments, image paths) via `data-*` attributes instead of inline interpolation
3. The Flightboard library is jQuery-based and uses `afterFlip` callbacks chaining 5 boards — the init sequence is tightly coupled to server-computed data

This is ~2hrs of work for purely architectural benefit with zero user-facing impact. Not worth
doing as part of this ticket. If the win modal ever gets a visual redesign, bundle it then.

---

## False Alarms (from meta-plan)

| Flagged Issue | Verdict | Why |
|---|---|---|
| `nav_controller.js` missing `disconnect()` | **False** | Has `disconnect()` that removes document click listener |
| `dropdown_controller.js` missing `disconnect()` | **False** | Has `disconnect()` that removes document click listener |
| Edit bottom-button handlers stack | **False** | Turbo replaces `<body>` — old elements + handlers are GC'd |
| `moreBtn.addEventListener` stacks in solve_funcs.js | **False** | Same: button is in body, replaced each visit |
| jQuery `.on()` calls stack on Turbo navigation | **False** | All bound to body-interior elements, not `document` |

---

## Builder Instructions

**Single task:** Fix the global keyboard suppression leak in `crossword_funcs.js`.

1. Delete lines 265-266 (`document.onkeydown`/`document.onkeypress` assignments)
2. Expand the existing `_cwTurboLoadHandler` early return to clean up key handlers
3. Add key handler binding inside the handler body (after existing `.cell` click binding)
4. Use the remove+re-add pattern consistent with existing `$(document).off("keydown.cw").on("keydown.cw", ...)` on line 276
5. Manual test: solve page → home page → press arrow down. Verify page scrolls.
6. No spec changes needed (keyboard suppression is not spec-tested; it's a UX behavior)

**Estimated time:** 15 minutes.
**No migration. No new files. 1 file changed.**
