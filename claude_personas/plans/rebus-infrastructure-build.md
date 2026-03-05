# Rebus Cell Support — Builder Implementation Plan

**Status**: Ready for build
**Reviewed by**: Planner (review corrections integrated below)
**Build order**: 1 → 2 → 3 → 4+5 → 6 → 7+9 → 8+10 → 11 → 12
**Estimated scope**: ~12 files modified, ~4 new test contexts, 1 migration

---

## Task 1 · Migration

**New file**: `db/migrate/TIMESTAMP_add_rebus_map_to_crosswords_and_solutions.rb`

```ruby
class AddRebusMapToCrosswordsAndSolutions < ActiveRecord::Migration[8.1]
  def change
    add_column :crosswords, :rebus_map, :jsonb, default: {}, null: false
    add_column :solutions,  :rebus_map, :jsonb, default: {}, null: false
  end
end
```

**Verify**: `rails db:migrate`, `Crossword.new.rebus_map == {}`, `bundle exec rspec` green.

---

## Task 2 · Crossword model

**File**: `app/models/crossword.rb`

### 2a. New helpers (add after line 54, after `nonvoid_letter_count`)

```ruby
def rebus?
  rebus_map.present?
end

# Full answer at 0-based cell index. Multi-char for rebus, single char otherwise.
def answer_at(i)
  rebus_map[i.to_s] || letters[i]
end
```

### 2b. `cell_mismatches` (lines 85–97) — add `rebus_answers:` keyword

Replace the method entirely:

```ruby
def cell_mismatches(letters_param, indices: nil, rebus_answers: {})
  if indices
    letters_param.each_with_index.filter_map do |v, i|
      pos = indices[i]
      next if pos.nil? || pos < 0 || pos >= letters.length
      [pos, v != answer_at(pos)]
    end.to_h
  else
    letters_param.split('').each_with_index.to_h do |v, i|
      if rebus_answers.key?(i.to_s)
        [i, rebus_answers[i.to_s] != answer_at(i)]
      elsif rebus_map.key?(i.to_s) && v != ' ' && v != '_'
        # S1 fix: user typed something but didn't provide full rebus answer — incorrect
        [i, true]
      else
        [i, (v != ' ') && (v != '_') && (v != letters[i])]
      end
    end
  end
end
```

### 2c. `get_mismatches` (lines 77–80) — add `rebus_answers:` keyword

Replace the method:

```ruby
def get_mismatches(solution_letters, rebus_answers: {})
  raise ArgumentError, "Expected #{letters.length} chars, got #{solution_letters.length}" unless solution_letters.length == letters.length
  if rebus? && rebus_answers.any?
    (0...letters.length).filter_map do |i|
      expected = answer_at(i)
      actual = expected.length > 1 ? (rebus_answers[i.to_s] || solution_letters[i]) : solution_letters[i]
      i if actual != expected
    end
  else
    letters.chars.each_with_index.filter_map { |letter, i| i if letter != solution_letters[i] }
  end
end
```

### 2d. `update_cells_from_letters` (lines 400–424) — M1 review fix

Keep variable name `letter` (lines 404, 406). Add `full_answer`. Only change lines 412–413:

```ruby
# Line 404 stays: letter = letters[i]
# Line 406 stays: if [' ', '_'].include? letter
# After line 404, add:
full_answer = answer_at(i)

# Line 412: change from
if cell.letter != letter
  cell.letter = letter
# to
if cell.letter != full_answer
  cell.letter = full_answer
```

Exact edit — replace lines 400–424:

```ruby
def update_cells_from_letters
  Cell.transaction do
    cells.each_with_index do |cell, i|
      changed = false
      letter = letters[i]
      full_answer = answer_at(i)

      if [' ', '_'].include? letter
        if !cell.is_void?
          cell.is_void!
          changed = true
        end
      else
        if cell.letter != full_answer
          cell.letter = full_answer
          cell.is_not_void!
          changed = true
        end
      end
      if changed
        cell.save
      end
    end
  end
  self
end
```

### 2e. `set_contents` (lines 169–180) — add `new_rebus_map:` keyword

Replace:

```ruby
def set_contents(letters_string, new_rebus_map: nil)
  if letters_string.length == area
    self.letters = letters_string
    self.rebus_map = new_rebus_map if new_rebus_map
    if save
      update_cells_from_letters
    else
      raise 'Save failed!'
    end
  else
    raise ArgumentError
  end
end
```

**Verify**: `bundle exec rspec` — all existing specs pass.

---

## Task 3 · Solution model

**File**: `app/models/solution.rb`

### 3a. `check_completion` (lines 34–41) — add rebus entry check

Replace:

```ruby
def check_completion
  return true unless crossword
  if letters == crossword.letters && rebus_entries_match? && !is_complete?
    self.is_complete = true
    self.solved_at   = Time.current
  end
  true
end
```

Add private method (after the existing `private` on line 43):

```ruby
def rebus_entries_match?
  return true unless crossword.rebus?
  crossword.rebus_map.all? { |idx, answer| rebus_map[idx] == answer }
end
```

### 3b. `percent_correct` (lines 64–79)

Replace the `sum` accumulation loop (lines 72–75):

```ruby
current_letters.each_char.with_index do |char, index|
  next if char == '_'
  if crossword.rebus? && crossword.rebus_map.key?(index.to_s)
    sum += 1 if rebus_map[index.to_s] == crossword.rebus_map[index.to_s]
  else
    sum += 1 if char == cw_letters[index]
  end
end
```

### 3c. `fill_letters` (lines 87–94)

Add rebus_map reset after the letters reset:

```ruby
def fill_letters
  return unless crossword
  if letters.length != crossword.letters.length
    Rails.logger.warn("[Solution#fill_letters] id=#{id} length mismatch — re-initializing letters")
    self.letters = crossword.letters.gsub(/[^_]/, " ")
    self.rebus_map = {}
    save
  end
end
```

**Verify**: `bundle exec rspec` — all existing specs pass.

---

## Task 4 · NytPuzzleImporter

**File**: `app/services/nyt_puzzle_importer.rb`

### 4a. `normalize_grid` (lines 36–40) — return `[letters_string, rebus_map]`

```ruby
def self.normalize_grid(pz)
  grid = pz['grid'] || pz[:grid]
  rebus_map = {}
  grid.each_with_index do |el, i|
    if el.length > 1
      rebus_map[i.to_s] = el
      grid[i] = el[0]
    end
  end
  [grid.join('').gsub('.', '_'), rebus_map]
end
```

### 4b. `import` (line 16) — destructure

```ruby
letters, rebus_map = normalize_grid(pz)
```

### 4c. `create_crossword` (line 54) — accept and pass rebus_map

Add `rebus_map: {}` keyword parameter. Change line 65:

```ruby
def self.create_crossword(pz, title:, letters:, date:, rebus_map: {})
  # ... existing code ...
  crossword.set_contents(letters, new_rebus_map: rebus_map.presence)
  # ... rest unchanged
```

And update the call in `import`:

```ruby
crossword = create_crossword(pz, title: title, letters: letters, date: pz_date, rebus_map: rebus_map)
```

**Verify**: `bundle exec rspec spec/services/nyt_puzzle_importer_spec.rb`

---

## Task 5 · CrosswordPublisher

**File**: `app/services/crossword_publisher.rb`

### `apply_letters` (lines 48–53)

Replace:

```ruby
def self.apply_letters(crossword, ucw)
  rebus_map = {}
  letters_string = ucw.letters.each_with_index.map do |l, i|
    if l.nil?
      '_'
    elsif l.length > 1
      rebus_map[i.to_s] = l
      l[0]
    else
      l
    end
  end.join

  crossword.set_contents(letters_string, new_rebus_map: rebus_map.presence)
  crossword.number_cells
end
```

**Verify**: `bundle exec rspec spec/services/crossword_publisher_spec.rb`

---

## Task 6 · Controllers

### `CrosswordsController` (`app/controllers/crosswords_controller.rb`)

**`check_cell` (line 141)** — pass rebus_answers:

```ruby
def check_cell
  indices = params[:indices]&.map(&:to_i)
  rebus_answers = params[:rebus_answers]&.to_unsafe_h || {}
  @mismatches = @crossword.cell_mismatches(params[:letters], indices: indices, rebus_answers: rebus_answers)
  respond_to do |f|
    f.json { render json: { mismatches: @mismatches } }
    f.js   # Legacy: check_cell.js.erb
  end
end
```

**`check_completion` (line 150)** — add rebus verification:

```ruby
def check_completion
  letters_match = (@crossword.letters == params[:letters])
  rebus_match = if @crossword.rebus?
                  ra = params[:rebus_answers]&.to_unsafe_h || {}
                  @crossword.rebus_map.all? { |idx, answer| ra[idx] == answer }
                else
                  true
                end
  @correctness = letters_match && rebus_match
  # ... rest of method unchanged from line 151 onwards
```

**`admin_reveal_puzzle` (line 208)** — include rebus_map:

```ruby
def admin_reveal_puzzle
  result = { letters: @crossword.letters }
  result[:rebus_map] = @crossword.rebus_map if @crossword.rebus?
  render json: result
end
```

**`reveal` (line 222)** — return full answer:

Change line 222:
```ruby
letter = @crossword.answer_at(i)  # was: @crossword.letters[i]
```

And change line 223:
```ruby
next if letter == '_' || (letter.is_a?(String) && letter.length == 1 && letter == '_')
```

Actually simpler — `answer_at(i)` returns either a single char or multi-char string. The void check is fine since `answer_at(i)` for void cells returns `'_'` from `letters[i]`:

```ruby
letter = @crossword.answer_at(i)
next if letter == '_'
```

### `SolutionsController` (`app/controllers/solutions_controller.rb`)

**`update` (lines 31–39)** — persist rebus_map (G1 fix: always overwrite):

```ruby
def update
  @solution.letters = params[:letters]
  @solution.rebus_map = params[:rebus_map]&.to_unsafe_h || {} if params.key?(:rebus_map)
  @save_counter = params[:save_counter]
  @solution.save
  respond_to do |f|
    f.json { render json: { save_counter: @save_counter } }
    f.js   # Legacy: update.js.erb
  end
end
```

**`get_incorrect` (line 48)** — pass rebus_answers:

```ruby
def get_incorrect
  unless @solution.crossword
    head :not_found
    return
  end
  rebus_answers = params[:rebus_answers]&.to_unsafe_h || {}
  @mismatches = @solution.crossword.get_mismatches(params[:letters], rebus_answers: rebus_answers)
  if @mismatches.empty?
    @solution.update(is_complete: true)
  end
  head :ok
end
```

**Verify**: `bundle exec rspec` — full suite green.

---

## Task 7 · JS serialization

**File**: `app/assets/javascripts/crosswords/crossword_funcs.js`

### 7a. Fix `get_puzzle_letters` (lines 74–81)

Replace:

```javascript
get_puzzle_letters: function() {
  var letters = '';
  var $cells = $(".cell");
  $.each($cells, function(index, cell) {
    var $cell = $(cell);
    if ($cell.hasClass("void")) {
      letters += "_";
    } else {
      var content = $cell.get_letter();
      letters += content[0];  // first char only (rebus cells store multi-char)
    }
  });
  return letters;
},
```

### 7b. Add `get_puzzle_data` (after `get_puzzle_letters`)

```javascript
// Returns { letters, rebus_map } — letters is flat string (first char per cell),
// rebus_map is { "index": "full_content" } for multi-char cells.
get_puzzle_data: function() {
  var letters = '';
  var rebus_map = {};
  var $cells = $(".cell");
  $.each($cells, function(index, cell) {
    var $cell = $(cell);
    if ($cell.hasClass("void")) {
      letters += "_";
    } else {
      var content = $cell.get_letter();
      if (content.length > 1) {
        rebus_map[index.toString()] = content;
        letters += content[0];
      } else {
        letters += content;
      }
    }
  });
  return { letters: letters, rebus_map: rebus_map };
},
```

### 7c. Add `applyRebusClasses` helper (S2 fix — shared by set_letter and reveal_puzzle)

Add to `window.cw` object:

```javascript
// Apply rebus font-size classes based on content length.
// Shared by set_letter (cell_funcs.js) and reveal_puzzle (solve_funcs.js).
applyRebusClasses: function($cell, content) {
  $cell.removeClass('rebus-2 rebus-3 rebus-4');
  if (content.length === 2) $cell.addClass('rebus-2');
  else if (content.length === 3) $cell.addClass('rebus-3');
  else if (content.length >= 4) $cell.addClass('rebus-4');
},
```

**File**: `app/assets/javascripts/crosswords/solve_funcs.js`

### 7d. `save_solution` (line 137) — send rebus_map

Replace lines 137–143:

```javascript
var puzzleData = cw.get_puzzle_data();
var counter = solve_app.save_counter;
$.ajax({
  dataType: 'json',
  type: 'PUT',
  url: "/solutions/" + solve_app.solution_id,
  data: { letters: puzzleData.letters, rebus_map: puzzleData.rebus_map, save_counter: counter },
```

### 7e. `check_puzzle` (line 339) — send rebus_answers

Replace line 339:

```javascript
var puzzleData = cw.get_puzzle_data();
```

And the data param:

```javascript
data: { letters: puzzleData.letters, rebus_answers: puzzleData.rebus_map },
```

### 7f. `check_completion` (line 352) — send rebus_answers

Replace lines 352–356:

```javascript
var puzzleData = cw.get_puzzle_data();
var data = { letters: puzzleData.letters, rebus_answers: puzzleData.rebus_map };
if (!solve_app.anonymous) {
  data['solution_id'] = solve_app.solution_id;
}
```

### 7g. `reveal_puzzle` (lines 430–438) — apply rebus_map overlay + CSS classes (S2 fix)

Replace the success handler:

```javascript
success: function(data) {
  var letters = data.letters;
  var rebusMap = data.rebus_map || {};
  var $cells = $('.cell');
  $cells.each(function(index) {
    var $cell = $(this);
    if (!$cell.hasClass('void')) {
      var content = rebusMap[index.toString()] || letters[index];
      $cell.children('.letter').first().text(content);
      cw.applyRebusClasses($cell, content);
    }
  });
  // Clear any check flags from previous checks
  $cells.removeClass('flagged incorrect correct cell-flash');
  // Cross off all clues (all words are now complete)
  solve_app.check_all_finished();
  // Mark as unsaved — auto-save will fire within 5s
  solve_app.update_unsaved();
  cw.flash('Puzzle revealed!', 'success');
},
```

**File**: `app/assets/javascripts/crosswords/cell_funcs.js`

### 7h. `set_letter` (lines 239–248) — add rebus CSS classes

Replace:

```javascript
$.fn.set_letter = function(letter, original) {
  this.children(".letter").first().text(letter);
  cw.applyRebusClasses(this, letter);
  if (typeof team_app !== 'undefined') {
    if (original) {
      team_app.send_team_cell(this, letter);
    } else {
      this.check_finisheds();
    }
  }
};
```

---

## Task 8 · JS input — rebus mode toggle

**File**: `app/assets/javascripts/crosswords/crossword_funcs.js`

### 8a. Add rebus state (after line 5, after `editing: false`)

```javascript
rebus_mode: false,
INSERT: 45,
```

### 8b. Modify ESCAPE case (line 158–160)

Replace:

```javascript
case cw.ESCAPE:
  e.preventDefault();
  if (cw.rebus_mode) {
    cw.rebus_mode = false;
    $('#crossword').removeClass('rebus-active');
  } else {
    cw.unhighlight_all();
  }
  break;
```

### 8c. Modify ENTER case (line 162–164)

Replace:

```javascript
case cw.ENTER:
  e.preventDefault();
  if (cw.rebus_mode) {
    cw.rebus_mode = false;
    $('#crossword').removeClass('rebus-active');
    if (!cw.selected.is_word_end()) {
      cw.selected.next_cell().highlight();
    }
  } else {
    cw.selected.next_empty_cell().highlight();
  }
  break;
```

### 8d. Add INSERT case (after SHIFT case, line 167)

```javascript
case cw.INSERT:
  cw.rebus_mode = !cw.rebus_mode;
  $('#crossword').toggleClass('rebus-active', cw.rebus_mode);
  break;
```

### 8e. Modify default case (lines 174–196) — rebus mode appends instead of replacing

Replace the default case:

```javascript
default:
  if (cw.selected) {
    var letter = String.fromCharCode(key);
    if (key === cw.HYPHEN) letter = '-';
    if (cw.rebus_mode) {
      // Rebus mode: append character to current cell, don't advance
      var current = cw.selected.get_letter().trim();
      var newContent = (current === '' || current === ' ') ? letter : current + letter;
      if (cw.editing) {
        cw.selected.set_letter(newContent, true);
        edit_app.update_unsaved();
      } else {
        cw.selected.set_letter(newContent, true);
        solve_app.update_unsaved();
      }
    } else {
      // Normal mode: replace and advance (existing behavior)
      if (letter !== cw.selected.get_letter()) {
        if (cw.editing) {
          cw.selected.set_letter(letter, true);
          edit_app.update_unsaved();
        } else {
          var check_for_finish = cw.selected.is_empty_cell();
          cw.selected.set_letter(letter, true);
          if (check_for_finish) cw.selected.check_finisheds();
          solve_app.update_unsaved();
        }
      }
      if (!cw.selected.is_word_end()) {
        if (cw.selected.in_directional_finished_word()) {
          cw.selected.next_cell().highlight();
        } else {
          cw.selected.next_empty_cell_in_word().highlight();
        }
      }
    }
  }
```

### 8f. Modify `suppressBackspaceAndNav` (lines 248–261) — rebus-aware backspace (S3 fix)

Replace the backspace section:

```javascript
suppressBackspaceAndNav: function(evt) {
  evt = evt || window.event;
  var target = evt.target || evt.srcElement;
  if (evt.keyCode === cw.BACKSPACE && !/input|textarea/i.test(target.nodeName)) {
    if (!cw.selected) return false;
    if (cw.rebus_mode) {
      // In rebus mode: remove last character, or delete entirely if only 1 char
      var content = cw.selected.get_letter().trim();
      if (content.length > 1) {
        var newContent = content.slice(0, -1);
        cw.selected.set_letter(newContent, true);
        if (cw.editing) edit_app.update_unsaved();
        else solve_app.update_unsaved();
      } else {
        var check_for_unfinish = !cw.selected.is_empty_cell();
        cw.selected.delete_letter(true);
        if (check_for_unfinish) cw.selected.uncheck_unfinisheds();
      }
    } else {
      var check_for_unfinish = !cw.selected.is_empty_cell();
      cw.selected.delete_letter(true);
      if (check_for_unfinish) cw.selected.uncheck_unfinisheds();
    }
    return false;
  }
  if (cw.PAGE_NAV_KEYS.includes(evt.keyCode) && !/input|textarea/i.test(target.nodeName)) {
    return false;
  }
}
```

**File**: `app/assets/javascripts/crosswords/edit_funcs.js`

### 8g. Edit `delete_letter` (lines 312–324) — S3 fix: rebus-aware

Replace:

```javascript
$.fn.delete_letter = function(letter) {
  if (cw.rebus_mode) {
    var content = this.get_letter().trim();
    if (content.length > 1) {
      this.set_letter(content.slice(0, -1), true);
      edit_app.update_unsaved();
      return;
    }
  }
  if (this.is_empty_cell()) {
    if (!this.is_word_start()) {
      if (!this.previous_cell().is_empty_cell()) {
        this.previous_cell().delete_letter(true);
      }
      this.previous_cell().highlight();
      return false;
    }
  } else {
    this.children(".letter").first().empty();
  }
};
```

---

## Task 9 · CSS

**File**: `app/assets/stylesheets/_design_tokens.scss`

Add after line 166 (after `--font-mono`):

```scss
// Rebus cell font sizes — scaled down to fit multi-char content
--font-size-rebus-2: 0.55em;
--font-size-rebus-3: 0.42em;
--font-size-rebus-4: 0.35em;
```

**File**: `app/assets/stylesheets/crossword.scss.erb`

Add rebus cell styles (find the `.cell` block and add inside it, or add at end):

```scss
// Rebus cells — shrink font to fit multi-character content
.cell {
  &.rebus-2 .letter { font-size: var(--font-size-rebus-2); }
  &.rebus-3 .letter { font-size: var(--font-size-rebus-3); }
  &.rebus-4 .letter { font-size: var(--font-size-rebus-4); }
}

// Rebus mode indicator — highlight selected cell border when composing multi-char entry
table#crossword.rebus-active .cell.selected {
  box-shadow: inset 0 0 0 2px var(--color-accent);
}
```

---

## Task 10 · Views

**File**: `app/views/crosswords/partials/_solve_crossword.html.haml`

Line 11 currently: `.letter= @solution.letters[i] if @solution`

Replace with:

```haml
- if @solution
  - sol_content = @solution.rebus_map&.dig(i.to_s) || @solution.letters[i]
  .letter{class: ("rebus-#{[sol_content.to_s.length, 4].min}" if sol_content.to_s.length > 1)}= sol_content
- else
  .letter
```

**File**: `app/views/crosswords/show.html.haml`

After line 15 (`solve_app.is_complete = ...`), add:

```haml
  solve_app.has_rebus = #{@crossword.rebus?.to_json}
```

---

## Task 11 · Editor wiring

**File**: `app/assets/javascripts/crosswords/edit_funcs.js`

In the `ready()` function (after line 27, after the `.switch-form` handler):

```javascript
// Wire multiletter_mode checkbox to rebus toggle
$('#unpublished_crossword_multiletter_mode').on('change', function() {
  cw.rebus_mode = $(this).is(':checked');
  $('#crossword').toggleClass('rebus-active', cw.rebus_mode);
});
if ($('#unpublished_crossword_multiletter_mode').is(':checked')) {
  cw.rebus_mode = true;
  $('#crossword').addClass('rebus-active');
}
```

---

## Task 12 · Tests

### Factory traits

**File**: `spec/factories/crossword_factory.rb`

Add trait inside the `predefined_five_by_five` factory block (M2 fix: DON'T modify letters):

```ruby
trait :rebus do
  after(:create) do |cw|
    cw.update!(rebus_map: { '0' => 'AM' })
    cw.cells.order(:index).first.update!(letter: 'AM')
  end
end
```

**File**: `spec/factories/solution_factory.rb`

Add trait:

```ruby
trait :with_rebus do
  after(:build) { |s| s.rebus_map = s.crossword.rebus_map.dup if s.crossword&.rebus? }
end
```

### Crossword model specs

**File**: `spec/models/crossword_spec.rb`

Add new context inside `describe 'INSTANCE METHODS'`, after the existing `cell_mismatches` context:

```ruby
context 'rebus support' do
  let(:cw) { create(:predefined_five_by_five, :rebus) }
  # letters = 'AMIGOVOLOWANIONIDOSELONER', rebus_map = { '0' => 'AM' }
  # answer_at(0) returns 'AM', answer_at(1) returns 'M'

  describe '#rebus?' do
    it 'returns true for a crossword with rebus entries' do
      expect(cw.rebus?).to be true
    end

    it 'returns false for a crossword without rebus entries' do
      normal = create(:predefined_five_by_five)
      expect(normal.rebus?).to be false
    end
  end

  describe '#answer_at' do
    it 'returns multi-char content for rebus positions' do
      expect(cw.answer_at(0)).to eq 'AM'
    end

    it 'returns single char for normal positions' do
      expect(cw.answer_at(1)).to eq 'M'
    end
  end

  describe '#cell_mismatches with rebus' do
    context 'spot-check mode (with indices)' do
      it 'marks correct when full rebus content matches' do
        result = cw.cell_mismatches(['AM'], indices: [0])
        expect(result[0]).to be false
      end

      it 'marks incorrect when only first char provided' do
        result = cw.cell_mismatches(['A'], indices: [0])
        expect(result[0]).to be true
      end

      it 'marks incorrect when wrong content provided' do
        result = cw.cell_mismatches(['ZZ'], indices: [0])
        expect(result[0]).to be true
      end
    end

    context 'full-puzzle mode (without indices)' do
      it 'uses rebus_answers for rebus positions' do
        result = cw.cell_mismatches(cw.letters, rebus_answers: { '0' => 'AM' })
        expect(result[0]).to be false
      end

      it 'flags incorrect when rebus_answers has wrong content' do
        result = cw.cell_mismatches(cw.letters, rebus_answers: { '0' => 'XY' })
        expect(result[0]).to be true
      end

      it 'flags as incorrect when rebus cell has content but no rebus_answer (S1)' do
        # User typed 'A' in flat string at position 0, but no rebus_answers entry
        result = cw.cell_mismatches(cw.letters)
        expect(result[0]).to be true  # S1: partially-filled rebus = incorrect
      end

      it 'does not flag empty rebus cells' do
        partial = ' ' * cw.letters.length
        result = cw.cell_mismatches(partial)
        expect(result[0]).to be false  # empty space — not flagged
      end
    end
  end

  describe '#get_mismatches with rebus' do
    it 'returns empty when rebus answers match' do
      expect(cw.get_mismatches(cw.letters, rebus_answers: { '0' => 'AM' })).not_to include(0)
    end

    it 'includes rebus position when answers do not match' do
      expect(cw.get_mismatches(cw.letters, rebus_answers: { '0' => 'XY' })).to include(0)
    end
  end
end
```

### Solution model specs

**File**: `spec/models/solution_spec.rb`

Add new context:

```ruby
context 'rebus support' do
  let(:rebus_cw) { create(:predefined_five_by_five, :rebus) }

  describe '#check_completion with rebus' do
    it 'marks complete when letters and rebus entries match' do
      solution = create(:solution, user: user, crossword: rebus_cw,
                        letters: rebus_cw.letters,
                        rebus_map: { '0' => 'AM' })
      expect(solution.is_complete).to be true
      expect(solution.solved_at).to be_present
    end

    it 'does not mark complete when rebus entries do not match' do
      solution = create(:solution, user: user, crossword: rebus_cw,
                        letters: rebus_cw.letters,
                        rebus_map: { '0' => 'XY' })
      expect(solution.is_complete).to be false
    end

    it 'does not mark complete when rebus entries are missing' do
      solution = create(:solution, user: user, crossword: rebus_cw,
                        letters: rebus_cw.letters,
                        rebus_map: {})
      expect(solution.is_complete).to be false
    end
  end

  describe '#percent_correct with rebus' do
    it 'scores matching rebus cells as correct' do
      solution = create(:solution, user: user, crossword: rebus_cw,
                        letters: rebus_cw.letters,
                        rebus_map: { '0' => 'AM' })
      result = solution.percent_correct
      expect(result[:percent]).to eq 100.0
    end

    it 'scores non-matching rebus cells as incorrect' do
      solution = create(:solution, user: user, crossword: rebus_cw,
                        letters: rebus_cw.letters,
                        rebus_map: { '0' => 'XY' })
      result = solution.percent_correct
      expect(result[:percent]).to be < 100.0
    end
  end

  describe '#fill_letters with rebus' do
    it 'resets rebus_map when reinitializing letters' do
      solution = create(:solution, user: user, crossword: rebus_cw,
                        letters: '', rebus_map: { '0' => 'AM' })
      solution.fill_letters
      expect(solution.reload.rebus_map).to eq({})
    end
  end
end
```

### NytPuzzleImporter spec

**File**: `spec/services/nyt_puzzle_importer_spec.rb`

Replace the existing rebus test (lines 55–60):

```ruby
it 'preserves rebus entries in rebus_map' do
  puzzle_hash['grid'][0] = 'AB'
  NytPuzzleImporter.import(puzzle_hash)
  crossword = Crossword.order(:created_at).last
  expect(crossword.letters[0]).to eq 'A'
  expect(crossword.rebus_map).to eq({ '0' => 'AB' })
end
```

### CrosswordPublisher spec

**File**: `spec/services/crossword_publisher_spec.rb`

Add new spec:

```ruby
it 'extracts multi-char letters into rebus_map' do
  ucw.update!(letters: ['AM'] + %w[I G O V O L O W A N I O N I D O S E L O N E R])
  crossword = CrosswordPublisher.publish(ucw)
  expect(crossword.letters[0]).to eq 'A'
  expect(crossword.rebus_map).to eq({ '0' => 'AM' })
end
```

### Request specs — rebus context

**File**: `spec/requests/check_functions_spec.rb`

Add new describe block:

```ruby
# ---------------------------------------------------------------------------
# Rebus puzzle checks
# ---------------------------------------------------------------------------
describe 'rebus puzzle checks' do
  let_it_be(:rebus_cw) { create(:predefined_five_by_five, :rebus) }
  # rebus_map = { '0' => 'AM' }, letters[0] = 'A'

  before { log_in_as(user) }

  describe 'POST /crosswords/:id/check_cell with rebus' do
    it 'marks correct when full rebus content matches via indices' do
      post "/crosswords/#{rebus_cw.id}/check_cell",
           params: { letters: ['AM'], indices: ['0'] },
           headers: json_headers

      body = JSON.parse(response.body)
      expect(body['mismatches']['0']).to be false
    end

    it 'marks incorrect when only first char provided via indices' do
      post "/crosswords/#{rebus_cw.id}/check_cell",
           params: { letters: ['A'], indices: ['0'] },
           headers: json_headers

      body = JSON.parse(response.body)
      expect(body['mismatches']['0']).to be true
    end

    it 'handles full puzzle check with rebus_answers' do
      post "/crosswords/#{rebus_cw.id}/check_cell",
           params: { letters: rebus_cw.letters, rebus_answers: { '0' => 'AM' } },
           headers: json_headers

      body = JSON.parse(response.body)
      expect(body['mismatches']['0']).to be false
    end
  end

  describe 'POST /crosswords/:id/check_completion with rebus' do
    let!(:solution) { create(:solution, user: user, crossword: rebus_cw, letters: rebus_cw.letters.gsub(/[^_]/, ' ')) }

    it 'returns correct when letters and rebus_answers match' do
      post "/crosswords/#{rebus_cw.id}/check_completion",
           params: { letters: rebus_cw.letters, rebus_answers: { '0' => 'AM' }, solution_id: solution.id },
           headers: json_headers

      body = JSON.parse(response.body)
      expect(body['correct']).to be true
    end

    it 'returns incorrect when rebus_answers do not match' do
      post "/crosswords/#{rebus_cw.id}/check_completion",
           params: { letters: rebus_cw.letters, rebus_answers: { '0' => 'XY' }, solution_id: solution.id },
           headers: json_headers

      body = JSON.parse(response.body)
      expect(body['correct']).to be false
    end

    it 'returns incorrect when rebus_answers are missing' do
      post "/crosswords/#{rebus_cw.id}/check_completion",
           params: { letters: rebus_cw.letters, solution_id: solution.id },
           headers: json_headers

      body = JSON.parse(response.body)
      expect(body['correct']).to be false
    end
  end

  describe 'POST /crosswords/:id/reveal with rebus' do
    let!(:solution) { create(:solution, user: user, crossword: rebus_cw, letters: rebus_cw.letters.gsub(/[^_]/, ' ')) }

    before { solution.fill_letters }

    it 'returns full rebus content for rebus cells' do
      post "/crosswords/#{rebus_cw.id}/reveal",
           params: { indices: [0], solution_id: solution.id }

      json = JSON.parse(response.body)
      expect(json['letters']['0']).to eq 'AM'
    end
  end

  describe 'POST /crosswords/:id/admin_reveal_puzzle with rebus' do
    let(:admin) { create(:user, :with_test_password, is_admin: true) }

    before { log_in_as(admin) }

    it 'includes rebus_map in response' do
      post "/crosswords/#{rebus_cw.id}/admin_reveal_puzzle",
           headers: json_headers

      json = JSON.parse(response.body)
      expect(json['rebus_map']).to eq({ '0' => 'AM' })
    end
  end
end
```

---

## Verification Checklist

1. `bundle exec rspec` — all existing specs pass (backward compat)
2. New rebus specs pass (model, request, service)
3. Manual: import an NYT puzzle with rebus → verify `rebus_map` populated, cells show multi-char
4. Manual: create a UCW with `multiletter_mode`, enter multi-char content, publish → verify `rebus_map`
5. Manual: solve a rebus puzzle — check_cell, check_word, check_puzzle, check_completion, reveal
6. Manual: team solve — teammate sees full rebus content in real time
7. Manual: admin reveal on rebus puzzle fills cells with full content + correct font sizing

---

## Risk Notes

- **No data migration needed**: existing rows get `{}` from default. Zero impact on current puzzles.
- **No schema changes to cells table**: `cell.letter` is VARCHAR(255), already holds multi-char.
- **Team broadcast unchanged**: `team_update` passes `letter` param as string — multi-char strings flow through as-is.
- **NYT import is the main entry point for rebus data**: ~5-10% of NYT puzzles have rebus cells.
