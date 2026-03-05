# P2-3: Service Object Test Coverage

**Status:** Reviewed
**Risk tier:** 3 (confidence for future changes)
**Effort:** ~250-300 lines across 4 new spec files

---

## Summary

3 service objects and 1 model have zero dedicated specs. Some behavior is exercised
indirectly through request specs (changelog filtering, NYT API passthrough), but the
core logic — categorization, date parsing, UTF-8 handling, GitHub API calls, clue number
calculation — has no unit-level coverage.

---

## 1. GithubChangelogService — `spec/services/github_changelog_service_spec.rb`

**Current coverage:** Partial. `skip_commit?` tested in `pages_changelog_spec.rb` (lines 200-218).
Categorization, prefix stripping, pagination parsing, fetch flow, auth header injection,
and error handling are tested only through request integration tests (fragile coupling).

**What to test (class methods — all `self.` methods):**

### `.fetch(page:)`
- Returns hash with `{ commits:, page:, per_page:, total_pages: }` on success
- Returns `nil` on HTTP failure (non-2xx response)
- Returns `nil` on exception (timeout, network error) — catches `StandardError`
- Uses `Rails.cache.fetch` with `changelog_page_N` key (verify caching behavior)

### `.skip_commit?(message)` — already tested, but move to unit spec
- Skips persona memory, CLAUDE.md, merge commits, review plans
- Does NOT skip real commits

### `categorize(message)` (private, but test via `.fetch` output or use `send`)
- `"Fix ..."` → `:fix`
- `"Add ..."` → `:feature`
- `"Rebuild/Modernize/Refactor/Extract ..."` → `:improve`
- `"Polish/Pixel/Visual/Clean ..."` → `:polish`
- Anything else → `:update`
- **Edge case:** `"Add request specs for login"` → `:update` (spec/test keyword overrides "Add")
- **Edge case:** `"Fix rspec deprecation warnings"` → `:fix` (fix + spec → fix wins because of `!message.match?(/\bfix\b/i)`)

### `strip_category_prefix(message, category)` (private)
- Strips "Fix " from `:fix` messages → capitalizes remainder
- Strips "Add " from `:feature` messages
- Strips "Rebuild/Modernize/Refactor/Extract " from `:improve` messages
- Strips "Polish/Pixel-perfect polish:/Visual/Clean " from `:polish` messages
- Does NOT strip anything for `:update` category
- Capitalizes first character after stripping

### `parse_last_page(link_header)` (private)
- Parses `page=37` from GitHub Link header → returns `37`
- Returns `nil` when header is `nil`
- Returns `nil` when header has no `rel="last"` match

### Auth header injection
- Includes `basic_auth` when `GITHUB_USERNAME` and `GITHUB_PASSWORD` env vars present
- Omits `basic_auth` when env vars are blank

### Commit processing
- Extracts only first line of multi-line messages
- SHA is truncated to 7 characters
- Date is parsed to `Date` object
- Filtered commits (matching SKIP_PATTERNS) are excluded from results

**Stubbing:** `HTTParty.get` (same pattern as `pages_changelog_spec.rb`)

**Estimated size:** ~100 lines

---

## 2. NytPuzzleFetcher — `spec/services/nyt_puzzle_fetcher_spec.rb`

**Current coverage:** Zero unit specs. Used in `api_spec.rb` but only as a stub target —
the actual methods are never exercised.

**What to test:**

### `.parse_puzzle_date(pz)`
- Parses date from title string: `{ 'title' => 'NY Times, Mon, Jan 01, 2024' }` → `Date.new(2024, 1, 1)`
- Falls back to `date` field when title doesn't parse: `{ 'title' => 'Untitled', 'date' => '01/15/2024' }` → `Date.new(2024, 1, 15)`
- Works with symbol keys (`:title`, `:date`) — used by `NytGithubRecorder.smart_record`
- Raises `ArgumentError` when neither title nor date parses (no rescue for second attempt)

### `.from_github(date, format)`
- Constructs correct URL: `https://raw.githubusercontent.com/doshea/nyt_crosswords/master/YYYY/MM/DD.json`
- Uses zero-padded month and day
- Passes `timeout: 10` to HTTParty
- Defaults to today's date
- Calls `ensure_utf8` on response

### `.from_xwordinfo(date, format)`
- Constructs correct URL: `http://www.xwordinfo.com/JSON/Data.aspx?date=M/D/YYYY`
- Does NOT zero-pad month/day (different from `from_github`)
- Passes `timeout: 10`
- Calls `ensure_utf8` on response

### `.ensure_utf8(response)` (private)
- Forces UTF-8 encoding when body is ASCII-8BIT
- Leaves already-UTF-8 strings untouched
- Returns the original response object

**Stubbing:** `HTTParty.get`

**Estimated size:** ~60 lines

---

## 3. NytGithubRecorder — `spec/services/nyt_github_recorder_spec.rb`

**Current coverage:** Zero. Used in `scheduler.rake` and `admin_controller.rb`.

**What to test:**

### `.smart_record(puzzle_json)`
- Parses JSON, extracts date via `NytPuzzleFetcher.parse_puzzle_date`, calls `record_on_github`
- Verify it delegates correctly (stub `record_on_github`)

### `.record_date_on_github(date)`
- Fetches from xwordinfo via `NytPuzzleFetcher.from_xwordinfo`, then calls `record_on_github`
- Verify delegation (stub both `from_xwordinfo` and `record_on_github`)

### `.record_on_github(puzzle_json, date)`
- Returns `nil` when `puzzle_json` is nil (guard clause)
- Makes `HTTParty.put` with correct URL structure: `/repos/doshea/nyt_crosswords/contents/YYYY/MM/DD.json`
- Uses zero-padded month/day in URL
- Sends Base64-encoded content in body
- Includes commit message with formatted date
- Uses `basic_auth` from env vars
- Passes `timeout: 10`

**Stubbing:**
- `HTTParty.put` and `HTTParty.get`
- `NytPuzzleFetcher.from_xwordinfo` (for `record_date_on_github`)
- ENV vars for `GITHUB_USERNAME`/`GITHUB_PASSWORD`

**Estimated size:** ~70 lines

---

## 4. UnpublishedCrossword — `spec/models/unpublished_crossword_spec.rb`

**Current coverage:** Zero model spec. Controller spec (`unpublished_crosswords_controller_spec.rb`)
tests `add_potential_word`/`remove_potential_word` through HTTP, and view spec uses
`letters_to_clue_numbers`. No direct unit testing of business logic.

**What to test:**

### `#letters_to_clue_numbers`
This is the most complex method (45 lines of index math). Test with known grid layouts:

- **Simple 3x3 no voids:** All cells filled → numbers assigned at top row and left column starts
- **Grid with voids:** `nil` letters create clue-start positions on adjacent cells
- **Single row:** 1×5 grid → only across clues, one down per column
- **Single column:** 5×1 grid → only down clues, one across per row
- Returns `{ across: [...], down: [...] }` hash

**Note:** Method has `#TODO make this work` comment — verify it actually produces correct
output before writing specs. If it's broken, flag for Builder to fix alongside specs.

### `#add_potential_word(word)`
- Adds word to `potential_words` array and saves
- Returns `false` (not saved) when word already exists (duplicate guard)
- Sorts words by length descending after adding

### `#remove_potential_word(word)`
- Removes word from array and saves
- Handles word not in list (no error — `Array#delete` returns nil)

### `before_create :populate_arrays` (callback)
- Sets `letters` to array of empty strings (size = rows × cols)
- Sets `circles` to string of spaces (size = rows × cols)
- Sets `across_clues` and `down_clues` to arrays of nils (size = rows × cols)

### Crosswordable validations (inherited)
- Valid with 4≤rows≤30, 4≤cols≤30, 3≤title.length≤35
- Invalid outside those bounds

**Stubbing:** None needed — pure model logic

**Estimated size:** ~80 lines

---

## Implementation Order

1. **NytPuzzleFetcher** — smallest, most straightforward, exercises date parsing used by other services
2. **NytGithubRecorder** — depends on NytPuzzleFetcher (good to have those specs first)
3. **GithubChangelogService** — largest but self-contained
4. **UnpublishedCrossword** — model spec, independent of the others

## Patterns to Follow

From existing service specs (`crossword_publisher_spec.rb`, `nyt_puzzle_importer_spec.rb`):
- Top-level `RSpec.describe ServiceName do` (no `type:` for services)
- `let` for test data, `before` for stubs
- Test both happy path and error/edge cases
- `allow(HTTParty).to receive(:get)` for external calls
- `instance_double(HTTParty::Response, ...)` for response objects

## Risks

- **`letters_to_clue_numbers` TODO comment** — the method may be buggy. Builder should manually verify output with a known grid before writing assertions. If broken, fix is in scope.
- **ENV var stubbing** — use `allow(ENV).to receive(:[]).and_call_original` + specific stubs, or `ClimateControl` if available. Check existing patterns first.
- **Cache in GithubChangelogService** — tests must clear cache between runs (`Rails.cache.delete` pattern already used in `pages_changelog_spec.rb`).
