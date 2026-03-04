# Builder Memory

## Implementation Notes

### CrosswordPublisher cleanup (2026-03-04)
- `CrosswordPublisher` service already existed (flat implementation). Refactored into 5 named
  private helpers matching the `NytPuzzleImporter` pattern: `validate_complete!`, `create_crossword`,
  `apply_letters`, `assign_clues`, `clean_up_cells`, `apply_circles`.
- Deleted `Crossword#publish!` (was dead code — zero callers).
- Updated CLAUDE.md technical debt section: removed 3 already-resolved items (Newyorkable,
  publish controller extraction, SolutionsController auth).
- All 762 specs pass (1 pre-existing flaky: `PagesController#live_search`).

## Bugs Found & Fixed

### Row height jump on first letter (2026-03-04)
- `.letter` was in document flow; `line-height: 145%` pushed `<td>` height on first keystroke
- Fix: absolutely position `.letter` + flexbox centering. Works at all breakpoints since
  `height: 100%` inherits the cell size regardless of font-size changes.

### Focus jumps to end of filled word (2026-03-04)
- `next_empty_cell_in_word()` recursed to `is_word_end()` when no empty cells → landed on last cell
- Fix: check `in_directional_finished_word()` first; if true, use `next_cell()` instead

## Patterns
- Service objects follow class-method pattern: `ServiceName.action(args)` with
  `private_class_method` for helpers. Transaction wraps the pipeline. See `NytPuzzleImporter`
  and `CrosswordPublisher`.
