# Design Review: Footer Info Pages (About, FAQ, Contact, Stats)

Reviewed live at crossword-cafe.org on desktop (1440px) and mobile (375px).

---

## Summary

About is fine. FAQ is fine except it dead-ends. Contact is overstructured for what it contains.
Stats has a CSS bug. Mobile rendering is clean across all four.

---

## Findings

### 1. Stats `xw-hr--accent` — CSS class doesn't exist — **must-fix**

`stats.html.haml` line 13 uses `%hr.xw-hr--accent` but the class is never defined. Only
`.xw-hr--flush` exists. Global reset sets `border: none`, so this `<hr>` is invisible — no
line, no dinkus, nothing. The two charts have no visual separator between them.

Fix: define `.xw-hr--accent` or swap to a class that exists.

### 2. FAQ and Contact are dead-ends — **should-fix**

Both pages just stop at the bottom. About has a "Browse Puzzles" button. FAQ and Contact
should too. Two lines of HAML each:

```haml
= link_to 'Browse Puzzles', root_path, class: 'xw-btn'
```

### 3. Contact is overstructured — **should-fix**

Three `h2` sections ("Get in Touch", "Email", "Source Code") for an email address and a
GitHub link. "Get in Touch" says the same thing as the page title "Contact." You don't
need an `h2` labeled "Email" above a single email address.

Flatten it: a short paragraph with the email inline, then a dinkus, then the GitHub mention.
Or even just one paragraph with both. The content doesn't justify three sections.

### 4. Contact has no dinkus separators — **suggestion**

FAQ uses `%hr` dinkus between every question. Contact has none. These are sibling pages
in the same footer nav using the same `.xw-prose` component — the inconsistency is visible
if you click between them. Either add separators to Contact or don't, but pick one pattern.

### 5. Row-topper h1 hardcoded font size — **nitpick**

`global.scss.erb:87` uses `1.4375rem` (23px, legacy Foundation value) instead of
`var(--text-2xl)` (24px). Works fine. Change it or don't.

---

## Priority

| # | Finding | Severity | Effort |
|---|---------|----------|--------|
| 1 | `xw-hr--accent` undefined — invisible separator on Stats | must-fix | 5 min |
| 2 | FAQ + Contact dead-end (no CTA button) | should-fix | 2 min each |
| 3 | Contact overstructured — 3 headings for 2 links | should-fix | 15 min |
| 4 | Contact missing dinkus separators (inconsistent with FAQ) | suggestion | 2 min |
| 5 | Row-topper h1 hardcoded font size | nitpick | 1 min |
