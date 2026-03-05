# Product Spec: Clue Suggestions from Phrase Database

## Problem

When editing a crossword, constructors must write every clue from scratch. The app already has
53,526 reusable phrases linked to words via the Phrase model, but this data is invisible during
editing. NYT-quality clues exist in the database for common crossword words — surfacing them
would dramatically speed up puzzle creation and improve clue quality.

## Solution

Add a "Suggest Clues" feature to the edit page that, given a word in the grid, shows clues
previously used for that word across all published puzzles.

---

## User Flow

1. Constructor is editing a puzzle and clicks on a clue textarea (or the corresponding cell)
2. They see a small "Suggest" link/button next to or below the clue textarea
3. Clicking it opens a dropdown/popover showing clues previously used for that word
4. Suggestions show: clue text, difficulty rating (1-5 dots/stars), usage count
5. Clicking a suggestion fills the textarea with that clue text
6. Constructor can edit the filled text (it's a starting point, not locked)

### Edge Cases

| Case | Behavior |
|------|----------|
| Word has no suggestions (new/rare word) | Show "No suggestions found" with a subtle message |
| Word is partially filled (has blanks) | Don't show Suggest button — word must be complete |
| Clue already has text | Still allow Suggest — constructor may want alternatives |
| Void cells in word | N/A — void cells don't have clues |
| Word matches but no Phrase links | Can happen for very old puzzles — show nothing |

---

## Data Model

**Existing infrastructure (no schema changes needed):**

```
Word (content: "OREO")
  → has_many :clues
    → each Clue belongs_to :phrase
      → Phrase (content: "Sandwich cookie brand")
```

**Query for suggestions:**
```ruby
# Given a word string from the edit grid:
word = Word.find_by(content: word_string.upcase)
return [] unless word

Phrase.joins(:clues)
      .where(clues: { word_id: word.id })
      .select('phrases.*, COUNT(clues.id) AS usage_count, AVG(clues.difficulty) AS avg_difficulty')
      .group('phrases.id')
      .order('usage_count DESC')
      .limit(10)
```

This returns the top 10 most-used clue phrasings for a word, with usage count and average
difficulty. Single query, indexed on `clues.word_id`.

---

## API Endpoint

**Route:** `GET /api/clue_suggestions?word=OREO`

**Controller:** `ApiController#clue_suggestions` (add to existing `ApiController`)

**Response (JSON):**
```json
{
  "word": "OREO",
  "suggestions": [
    { "text": "Sandwich cookie brand", "usage_count": 47, "avg_difficulty": 1.8 },
    { "text": "Nabisco cookie", "usage_count": 23, "avg_difficulty": 1.2 },
    { "text": "Black-and-white snack", "usage_count": 8, "avg_difficulty": 2.4 }
  ]
}
```

**Auth:** Require logged-in user (existing `require_login` pattern). Only puzzle creators need
this, and they're always logged in.

**Rate limiting:** Not needed at current scale. If spammed, the query is fast (indexed).

---

## UI Design

### Option A: Inline Popover (Recommended)

Small "lightbulb" icon button appears next to each clue textarea when the word is complete.
Clicking opens a popover dropdown below the textarea showing suggestions.

```
  1. [OREO clue textarea________________] [lightbulb]
     +----------------------------------+
     | Sandwich cookie brand        (47)|
     | Nabisco cookie               (23)|
     | Black-and-white snack         (8)|
     | Cookie with creme filling     (5)|
     +----------------------------------+
```

**Why popover, not modal:** Constructors bounce between clues rapidly. A modal interrupts flow.
A popover appears inline, you click a suggestion, it fills, you move on.

**Why lightbulb:** The icon already exists in the icon set. Signals "idea/suggestion" without
implying system error or required action.

### Option B: Sidebar Panel

A "Suggestions" panel in the bottom toolbar area (alongside Notepad and Pattern Search).
Shows suggestions for whatever clue is currently focused.

**Downside:** Requires eye movement between clue area and bottom panel. Less direct.

### Recommendation: Option A

Inline popover is faster, more contextual, and matches how autocomplete works in every
text editor. Option B is a fallback if the popover feels cluttered.

### Popover Design

- Background: `var(--color-surface-alt)` (warm cream, nested paper)
- Border: `1px solid var(--color-border)`
- Shadow: `var(--shadow-md)`
- Max height: `200px` with `overflow-y: auto`
- Each row: hover highlight with `var(--color-overlay-hover)`
- Usage count: right-aligned, `var(--color-text-muted)`, parenthesized
- Empty state: "No suggestions for [WORD]" in muted text
- Loading state: `xw-spinner` while fetching

### Trigger Visibility

The lightbulb button should only appear when:
1. The word in that clue's cells is **fully filled** (no empty cells)
2. The word is **at least 2 letters** (single-letter words rarely have useful suggestions)

Hide the button when cells are empty or partially filled — avoids noise and prevents
useless API calls.

---

## JavaScript Approach

### When to Show the Suggest Button

On clue textarea focus (or cell click that highlights a word):
1. Read the word's cells from the grid
2. If all cells have letters → show lightbulb icon next to that clue's textarea
3. If any cell is empty → hide lightbulb

### Fetching Suggestions

On lightbulb click:
1. Show spinner in popover
2. `$.get('/api/clue_suggestions', { word: wordString })`
3. Render suggestions in popover
4. Cache result per word for the session (avoid re-fetching "OREO" every time)

### Selecting a Suggestion

On suggestion row click:
1. Fill the textarea with the suggestion text
2. Close the popover
3. Mark puzzle as unsaved (trigger `edit_app.update_unsaved()`)
4. Focus the textarea (so constructor can tweak the text)

### Client-Side Cache

```javascript
edit_app._suggestionCache = {};
// On fetch: edit_app._suggestionCache['OREO'] = [...]
// On request: if cached, skip fetch
```

Prevents redundant requests when the constructor clicks between clues for the same word.

---

## Files Touched

| File | Change |
|------|--------|
| `app/controllers/api_controller.rb` | Add `clue_suggestions` action |
| `config/routes.rb` | Add `get 'api/clue_suggestions'` |
| `app/assets/javascripts/crosswords/edit_funcs.js` | Suggest button show/hide, fetch, popover, fill |
| `app/assets/stylesheets/crossword.scss.erb` | Popover styles (`.xw-suggest-popover`) |
| `app/views/unpublished_crosswords/partials/_clue_column.html.haml` | Add lightbulb icon next to textarea |

## What NOT to Build (Yet)

- **Difficulty filtering** — show all suggestions; let the constructor choose. Filtering by
  difficulty is a future enhancement if the list gets long.
- **"Create new phrase" from edit page** — phrases are created at publish time only. Don't
  change this architecture.
- **Autocomplete-as-you-type** — too aggressive. The constructor should explicitly request
  suggestions, not be interrupted while typing original clues.
- **Phrase editing** — if a constructor picks a suggestion and modifies it, the modified text
  becomes a new phrase at publish time. This is correct behavior.

## Acceptance Criteria

1. Lightbulb icon appears next to clue textareas when the word is fully filled
2. Clicking lightbulb opens popover with suggestions (or "No suggestions" message)
3. Clicking a suggestion fills the textarea and closes the popover
4. Spinner shows while suggestions load
5. Results are cached per word for the session
6. API returns suggestions ordered by usage count (most common first)
7. No suggestions for incomplete words (lightbulb hidden)
8. No new database tables or schema changes required
9. `bundle exec rspec` passes
