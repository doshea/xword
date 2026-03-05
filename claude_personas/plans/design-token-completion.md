# P3-C: Design Token Completion

**Reviewed by:** Planner, 2026-03-05
**Estimated effort:** 25 min (Builder)
**Files to touch:** `_design_tokens.scss`, `_components.scss`, `_nav.scss`, `crossword.scss.erb`, `welcome.scss.erb`, `edit.scss.erb`

---

## Summary

Full audit found **25 hardcoded color values** across 5 files outside `_design_tokens.scss`.
Grouped by intent, they collapse into **5 new tokens + 2 existing token reuses**.
~6 low-value instances are left as-is (documented below with rationale).

---

## New Tokens to Add (in `_design_tokens.scss`)

Add after the `--color-scrollbar-thumb` line (line 134), in a new "Overlay" section:

```scss
// ---------------------------------------------------------------------------
// COLOR — Overlays (semi-transparent layers on dark/light surfaces)
// ---------------------------------------------------------------------------

--color-overlay-hover:    rgba(255, 255, 255, 0.12); // hover highlight on dark surfaces
--color-overlay-subtle:   rgba(255, 255, 255, 0.06); // faint differentiation on dark surfaces
--color-overlay-border:   rgba(255, 255, 255, 0.20); // borders/dividers on dark surfaces
--color-overlay-backdrop: rgba(28, 26, 23, 0.6);     // modal/dialog backdrop
--color-tint-hover:       rgba(28, 26, 23, 0.06);    // hover tint on light surfaces
```

---

## Replacements by File

### `_components.scss` — 8 replacements

| Line | Old | New | Severity |
|------|-----|-----|----------|
| 45 | `color: #fff` (`.xw-btn` default) | `color: var(--color-text-inverse)` | should-fix |
| 100 | `color: #fff` (`.xw-btn--danger`) | `color: var(--color-text-inverse)` | should-fix |
| 110 | `color: #fff` (`.xw-btn--success`) | `color: var(--color-text-inverse)` | should-fix |
| 120 | `color: #fff` (`.xw-btn--warning`) | `color: var(--color-text-inverse)` | should-fix |
| 360 | `rgba(28, 26, 23, 0.6)` (modal backdrop) | `var(--color-overlay-backdrop)` | should-fix |
| 708 | `color: #fff` (pagination current) | `color: var(--color-text-inverse)` | should-fix |
| 745 | `rgba(255, 255, 255, 0.10)` (footer border) | `rgba(255, 255, 255, 0.10)` | skip — see note 1 |
| 794 | `rgba(255, 255, 255, 0.20)` (footer dot) | `var(--color-overlay-border)` | nitpick |
| 1146 | `color: white` (calendar cell hover) | `color: var(--color-text-inverse)` | should-fix |

### `_nav.scss` — 11 replacements

| Line | Old | New | Severity |
|------|-----|-----|----------|
| 29 | `rgba(28, 26, 23, 0.5)` (nav shadow) | skip — see note 2 | — |
| 162 | `rgba(255, 255, 255, 0.12)` (icon-btn hover) | `var(--color-overlay-hover)` | should-fix |
| 193 | `color: #fff` (badge text) | `color: var(--color-text-inverse)` | should-fix |
| 313 | `background-color: #fff` (search input) | `background-color: var(--color-surface)` | should-fix |
| 314 | `rgba(255, 255, 255, 0.20)` (search border) | `var(--color-overlay-border)` | should-fix |
| 333 | `background-color: #fff` (search focus) | `background-color: var(--color-surface)` | should-fix |
| 426 | `rgba(255, 255, 255, 0.10)` (dropdown hover) | `var(--color-overlay-hover)` | nitpick — 0.10 vs 0.12 |
| 445 | `rgba(255, 255, 255, 0.40)` (group label) | skip — see note 3 | — |
| 479 | `rgba(255, 255, 255, 0.12)` (user-btn hover) | `var(--color-overlay-hover)` | should-fix |
| 487 | `rgba(255, 255, 255, 0.20)` (avatar border) | `var(--color-overlay-border)` | should-fix |
| 547 | `rgba(255, 255, 255, 0.06)` (mobile dropdown) | `var(--color-overlay-subtle)` | should-fix |
| 559 | `rgba(255, 255, 255, 0.06)` (mobile notif bg) | `var(--color-overlay-subtle)` | should-fix |
| 576 | `rgba(255, 255, 255, 0.10)` (mobile see-all) | `var(--color-overlay-hover)` | nitpick — 0.10 vs 0.12 |
| 585 | `rgba(255, 255, 255, 0.10)` (mobile unread) | `var(--color-overlay-hover)` | nitpick — 0.10 vs 0.12 |
| 590 | `rgba(255, 255, 255, 0.60)` (mobile meta text) | skip — see note 3 | — |
| 595 | `rgba(255, 255, 255, 0.50)` (mobile loading) | skip — see note 3 | — |

### `crossword.scss.erb` — 3 replacements

| Line | Old | New | Severity |
|------|-----|-----|----------|
| 400 | `color: white` (row-topper) | `color: var(--color-text-inverse)` | should-fix |
| 792 | `rgba(28, 26, 23, 0.02)` (comment hover) | `var(--color-tint-hover)` | nitpick — changes 0.02→0.06 |
| 937 | `rgba(28, 26, 23, 0.06)` (action-btn hover) | `var(--color-tint-hover)` | should-fix |

### `welcome.scss.erb` — 1 replacement

| Line | Old | New | Severity |
|------|-----|-----|----------|
| 166 | `rgba(255, 255, 255, 0.15)` (chalkboard btn) | `var(--color-overlay-hover)` | nitpick — 0.15→0.12 |

### `edit.scss.erb` — 1 replacement

| Line | Old | New | Severity |
|------|-----|-----|----------|
| 89 | `rgba(0, 0, 0, 0.03)` (title input bg) | `var(--color-tint-hover)` | nitpick — 0.03→0.06, changes from pure black base to warm #1c1a17 base |

---

## Intentionally Skipped

### Note 1: Footer border-top `rgba(255, 255, 255, 0.10)`
This sits between `--color-overlay-subtle` (0.06) and `--color-overlay-hover` (0.12). Creating a `--color-overlay-divider` at 0.10 would add a 6th overlay token for a single use. **Skip** — the footer is its own visual context.

### Note 2: Nav box-shadow `rgba(28, 26, 23, 0.5)`
This is a unique shadow value (stronger than `--shadow-lg`). It belongs as a `--shadow-nav` token if anywhere, not a color token. **Skip** — it's already a one-off shadow, not a reusable color.

### Note 3: Mobile nav text opacity values (0.40, 0.50, 0.60)
Three different opacity levels for mobile notification dropdown text, each used once. These serve as mobile-only theme overrides for a light-bg component rendered in a dark-bg context. Creating 3 tokens for 3 one-off uses inverts the value proposition. **Skip** — if mobile notifications get redesigned, these go away entirely.

### Note 4: `mask-image: linear-gradient(to right, black ...)` (components.scss:487-488)
The `black` keyword is a CSS mask primitive meaning "fully opaque". It's not a visual color. **Do not tokenize.**

---

## Design Decision: `--color-text-inverse` vs pure `#fff`

The existing `--color-text-inverse: #f5f0e8` is a warm off-white, designed for text on dark surfaces (nav). All 8 button/badge/pagination uses currently use pure `#fff`.

**Recommendation: Use `--color-text-inverse` for all of them.**

Rationale:
- The visual difference between `#f5f0e8` and `#fff` on a forest green button is imperceptible (~2% luminance)
- Warm off-white is more cohesive with the "paper on wood" aesthetic
- If a distinction is ever needed (e.g., dark mode), the token is already the right abstraction layer
- WCAG AA contrast: `#f5f0e8` on `#3a7d5c` (accent) = 3.7:1 — passes for large text (buttons). On `#b84040` (danger) = 3.3:1 — passes for large text but tight for normal text. **Builder should verify button font-size is ≥14px bold or ≥18px** to guarantee compliance.

If contrast is insufficient, add `--color-text-on-accent: #fff` as a pure-white alternative. But test first — the current `--text-sm` + `--weight-medium` on buttons is 13px/500, which technically needs 4.5:1 for WCAG AA. **Check this.** If it fails, the answer is `#fff` not `#f5f0e8`.

---

## Opacity Normalization (0.10 → 0.12)

Three nav instances use `rgba(255, 255, 255, 0.10)` while the hover token is `0.12`. The 2% difference is invisible. **Normalize all to `--color-overlay-hover` (0.12)** for consistency. If any visual regression appears (unlikely), the token can be tweaked.

Similarly, `edit.scss.erb` uses `rgba(0, 0, 0, 0.03)` and `crossword.scss.erb` uses `0.02` — both collapse to `--color-tint-hover` (0.06). The difference is sub-perceptual.

---

## Acceptance Criteria

1. Zero hardcoded `#fff` / `color: white` outside `_design_tokens.scss` (except mask-image)
2. Zero hardcoded `rgba(255, 255, 255, ...)` or `rgba(28, 26, 23, ...)` outside `_design_tokens.scss` (except the 5 intentional skips documented above)
3. All 5 new tokens defined in the overlay section of `_design_tokens.scss`
4. Visual regression: none — all changes are value-equivalent (within ±4% opacity)
5. WCAG contrast verified for `--color-text-inverse` on all semantic button variants
6. `bundle exec rspec` passes (CSS changes shouldn't break specs, but verify)
