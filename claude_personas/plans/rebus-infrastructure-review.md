# Rebus Cell Support — Plan Review

**Reviewed by**: Planner
**Date**: 2026-03-05
**Overall verdict**: Excellent plan. Sparse overlay is the right architecture. 2 must-fixes, 3 should-fixes, 2 suggestions, 2 nitpicks.

---

## Architecture Assessment

The sparse overlay approach (`rebus_map` JSONB on crosswords and solutions) is the right design:
- **99% fast path**: Non-rebus puzzles have `rebus_map = {}`, all code hits identical paths to today
- **No flat string changes**: `letters` stays 1-char-per-position; rebus cells use first-char placeholder + overlay map
- **No Cell schema change**: `cell.letter` is already VARCHAR(255) — multi-char fits
- **Clean encapsulation**: `answer_at(i)` and `rebus?` hide the overlay from callers
- **Backward compatible**: All existing tests pass unchanged

Dependency order is correct. Build order (1 → 2 → 3 → 4+5 → 6 → 7+9 → 8+10 → 11 → 12) makes sense.

---

## Findings

### MUST-FIX (2)

#### M1. Task 2d — Variable rename breaks void check
**File**: `app/models/crossword.rb` (update_cells_from_letters)

Plan renames `letter = letters[i]` to `letter_char = letters[i]` but doesn't update the void check on line 406:
```ruby
if [' ', '_'].include? letter   # ← still references old name; undefined after rename
```

**Fix**: Use `letter_char` in the void check, or keep the original variable name `letter` and just add `full_answer = answer_at(i)`.

#### M2. Task 12 — Factory trait corrupts puzzle data
**File**: `spec/factories/crossword_factory.rb`

The `:rebus` trait modifies the letters string:
```ruby
letters: cw.letters[0] + cw.letters[2..]   # 'AMIGOVOLOWANIONIDOSELONER' → 'AIGOVOLOWANIONIDOSELONER'
```

This shifts all positions starting at index 1 — cell[1] has letter 'M' but `letters[1]` is now 'I'. Every cell/letter position after index 0 is inconsistent.

**Fix**: Don't modify the letters string. Just overlay the rebus_map:
```ruby
trait :rebus do
  after(:create) do |cw|
    cw.update!(rebus_map: { '0' => 'AM' })
    cw.cells.order(:index).first.update!(letter: 'AM')
  end
end
```

`letters[0]` stays 'A' (first char of 'AM'), `answer_at(0)` returns 'AM' from the overlay. All other positions unchanged.

---

### SHOULD-FIX (3)

#### S1. Task 2b — False negative in full-puzzle check for partially-filled rebus cells
**File**: `app/models/crossword.rb` (cell_mismatches, no-indices branch)

When a crossword has a rebus cell at position `i` (answer = "AB") but the user typed only "A":
- Client sends `letters[i] = 'A'` in flat string, no `rebus_answers[i]` entry (content length 1)
- Server hits `else` branch: `'A' != 'A'` → false → "not a mismatch"
- **Bug**: Cell should be flagged as incorrect (expected "AB", got "A")

**Fix**: Add crossword's own rebus_map check in the else branch:
```ruby
elsif rebus_map.key?(i.to_s) && v != ' ' && v != '_'
  # User typed something but didn't provide full rebus answer — incorrect
  [i, true]
else
  [i, (v != ' ') && (v != '_') && (v != letters[i])]
end
```

Where `rebus_map` refers to `self.rebus_map` (crossword's).

#### S2. Task 7d — reveal_puzzle doesn't add rebus CSS classes
**File**: `app/assets/javascripts/crosswords/solve_funcs.js` (reveal_puzzle)

`reveal_puzzle` sets cell text directly via `.text()` to avoid per-cell broadcasts. But it skips `set_letter`, so no `rebus-2/3/4` classes are applied. Rebus cells will show multi-char content at full font size — overflows the cell.

**Fix**: After setting text, add rebus class management:
```javascript
$cell.removeClass('rebus-2 rebus-3 rebus-4');
if (content.length === 2) $cell.addClass('rebus-2');
else if (content.length === 3) $cell.addClass('rebus-3');
else if (content.length >= 4) $cell.addClass('rebus-4');
```

#### S3. Task 8e — Both delete_letter implementations need rebus handling
**Files**: `solve_funcs.js` AND `edit_funcs.js`

Plan mentions modifying backspace behavior in rebus mode but only addresses one `delete_letter`. There are two:
- `solve_funcs.js` line 663 — includes team broadcast
- `edit_funcs.js` line 312 — simpler, no broadcast

Both need the "remove last character if rebus" logic, since both pages can have rebus mode active.

---

### SUGGESTIONS (2)

#### G1. Task 6 — Stale rebus_map entries on solution save
**File**: `app/controllers/solutions_controller.rb` (update)

```ruby
@solution.rebus_map = params[:rebus_map].to_unsafe_h if params[:rebus_map].present?
```

When client sends empty `rebus_map` (all rebus cells cleared), `{}.present?` → false in jQuery serialization (no params sent). Server keeps stale entries. In practice, stale entries are harmless — completion checks only verify crossword→solution direction. But for data cleanliness, consider:
```ruby
@solution.rebus_map = params[:rebus_map]&.to_unsafe_h || {}
```

(Always overwrite. Empty hash means "no rebus content".)

#### G2. Task 2a — Redundant guard in rebus?
```ruby
def rebus?
  rebus_map.present? && rebus_map.any?
end
```

In Rails, `{}.present?` returns `false` (because `{}.blank?` is `true`). So `.present?` alone suffices. The `&& .any?` is redundant. Minor, but worth simplifying to just:
```ruby
def rebus?
  rebus_map.present?
end
```

---

### NITPICKS (2)

#### N1. Task 7a — Dead ternary in get_puzzle_letters
`get_letter()` always returns non-empty string (returns `" "` for empty cells). So `content.length > 0 ? content[0] : " "` is always true branch. Could simplify to `content[0]`.

#### N2. Task 8d — INSERT key accessibility
`INSERT` keyCode (45) may not be available on laptops without dedicated Insert key. Document the editor checkbox as the primary rebus toggle, with INSERT as a keyboard shortcut for power users. Consider showing a small "Rebus mode" indicator when `has_rebus` is true on the solve page.

---

## What the Plan Gets Right

- **Sparse overlay is elegant** — no structural changes to the flat letters string or cell schema
- **Zero-change fast path** — non-rebus puzzles (99%) are completely unaffected
- **Both import paths covered** — NYT import AND user publishing extract rebus data
- **Full-stack coverage** — model, service, controller, JS, CSS, view, tests
- **Team solving addressed** — `set_letter` broadcasts multi-char content; `team_update` passes strings through
- **CSS scaling is sensible** — `0.55em / 0.42em / 0.35em` for 2/3/4+ chars with design tokens
- **Test strategy is comprehensive** — factory traits, model specs, request specs, service specs all described

---

## Builder Notes

1. Start with Task 1 (migration) and Task 2 (model). Run `bundle exec rspec` after each.
2. For M1: keep variable name `letter` on line 404, add `full_answer = answer_at(i)` as a new variable. Change only lines 412-413 to use `full_answer`.
3. For M2: simplest factory is just `cw.update!(rebus_map: { '0' => 'AM' })` + cell update. Don't touch letters string.
4. For S1: the fix goes inside `cell_mismatches` no-indices branch, not as a separate method.
5. For S2: extract a shared `_applyRebusClasses($cell, content)` helper in crossword_funcs.js and call from both `set_letter` and `reveal_puzzle`.
6. For S3: consider extracting the rebus-aware delete logic into a shared helper that both `delete_letter` functions call.
