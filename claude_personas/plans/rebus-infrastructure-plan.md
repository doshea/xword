# Rebus Cell Support — Implementation Plan

**Status**: Reviewed, ready for Builder
**Review**: `claude_personas/plans/rebus-infrastructure-review.md`

## Build Order

1 → 2 → 3 → 4+5 → 6 → 7+9 → 8+10 → 11 → 12

Run `bundle exec rspec` after each task to verify backward compatibility.

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

---

## Task 2 · Crossword model
**File**: `app/models/crossword.rb`

### 2a. Add helpers (after `nonvoid_letter_count`):
```ruby
def rebus?
  rebus_map.present?
end

def answer_at(i)
  rebus_map[i.to_s] || letters[i]
end
```

### 2b. Modify `cell_mismatches` (lines 85–97):
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
        # User typed something but didn't provide full rebus answer
        [i, true]
      else
        [i, (v != ' ') && (v != '_') && (v != letters[i])]
      end
    end
  end
end
```

### 2c. Modify `get_mismatches` (lines 77–80):
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

### 2d. Modify `update_cells_from_letters` (lines 400–424):
**⚠️ REVIEW FIX M1**: Keep variable name `letter`, add `full_answer`:
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

### 2e. Modify `set_contents` (lines 169–180):
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

---

## Task 3 · Solution model
**File**: `app/models/solution.rb`

### 3a. Modify `check_completion` (lines 34–41):
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

Add private method:
```ruby
private

def rebus_entries_match?
  return true unless crossword.rebus?
  crossword.rebus_map.all? { |idx, answer| rebus_map[idx] == answer }
end
```

### 3b. Modify `percent_correct` (lines 64–79):
```ruby
def percent_correct
  return { numerator: 0, denominator: 0, percent: 0.0 } unless crossword
  current_letters = self.letters
  cw_letters = self.crossword.letters

  letter_count = self.crossword.nonvoid_letter_count
  return { numerator: 0, denominator: 0, percent: 0.0 } if letter_count.zero?

  sum = 0
  current_letters.each_char.with_index do |char, index|
    next if char == '_'
    if crossword.rebus? && crossword.rebus_map.key?(index.to_s)
      sum += 1 if rebus_map[index.to_s] == crossword.rebus_map[index.to_s]
    else
      sum += 1 if char == cw_letters[index]
    end
  end

  percent = ((sum.to_f/letter_count)*100).round(2)
  {numerator: sum, denominator: letter_count, percent: percent}
end
```

### 3c. Modify `fill_letters` (lines 87–94):
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

---

## Task 4 · NytPuzzleImporter
**File**: `app/services/nyt_puzzle_importer.rb`

### 4a. Modify `normalize_grid` (lines 36–40):
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

### 4b. Modify `import` (line 16):
```ruby
letters, rebus_map = normalize_grid(pz)
```

### 4c. Modify `create_crossword` (line 54):
Add `rebus_map:` keyword parameter, use it in `set_contents`:
```ruby
def self.create_crossword(pz, title:, letters:, date:, rebus_map: nil)
  # ... existing create! call unchanged ...
  crossword.set_contents(letters, new_rebus_map: rebus_map)
  # ... rest unchanged ...
end
```

Update caller in `import`:
```ruby
crossword = create_crossword(pz, title: title, letters: letters, date: pz_date, rebus_map: rebus_map.presence)
```

---

## Task 5 · CrosswordPublisher
**File**: `app/services/crossword_publisher.rb`

### Modify `apply_letters` (lines 48–53):
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

---

## Task 6 · Controllers

### CrosswordsController (`app/controllers/crosswords_controller.rb`)

**check_cell** (line 141):
```ruby
def check_cell
  indices = params[:indices]&.map(&:to_i)
  rebus_answers = params[:rebus_answers]&.to_unsafe_h || {}
  @mismatches = @crossword.cell_mismatches(params[:letters], indices: indices, rebus_answers: rebus_answers)
  # ... respond_to unchanged
end
```

**check_completion** (line 150):
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
  # ... rest unchanged from line 151
end
```

**admin_reveal_puzzle** (line 208):
```ruby
def admin_reveal_puzzle
  result = { letters: @crossword.letters }
  result[:rebus_map] = @crossword.rebus_map if @crossword.rebus?
  render json: result
end
```

**reveal** (line 222):
```ruby
letter = @crossword.answer_at(i)   # was: @crossword.letters[i]
```

### SolutionsController (`app/controllers/solutions_controller.rb`)

**update** (line 32):
```ruby
@solution.letters = params[:letters]
@solution.rebus_map = params[:rebus_map]&.to_unsafe_h || {} if params.key?(:rebus_map)
```

**get_incorrect** (line 48):
```ruby
rebus_answers = params[:rebus_answers]&.to_unsafe_h || {}
@mismatches = @solution.crossword.get_mismatches(params[:letters], rebus_answers: rebus_answers)
```

---

## Task 7 · JS serialization
**File**: `app/assets/javascripts/crosswords/crossword_funcs.js`

### 7a. Fix `get_puzzle_letters` (lines 74–81):
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
      letters += content[0]; // First char only (truncate rebus)
    }
  });
  return letters;
},
```

### 7b. Add `get_puzzle_data` (after `get_puzzle_letters`):
```javascript
get_puzzle_data: function() {
  var letters = '';
  var rebus_map = {};
  $.each($(".cell"), function(index, cell) {
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

### 7c. Update callers in solve_funcs.js

**save_solution** (~line 137):
```javascript
var puzzleData = cw.get_puzzle_data();
// In $.ajax data:
data: { letters: puzzleData.letters, rebus_map: puzzleData.rebus_map, save_counter: counter },
```

**check_puzzle** (~line 339):
```javascript
var puzzleData = cw.get_puzzle_data();
// In $.ajax data:
data: { letters: puzzleData.letters, rebus_answers: puzzleData.rebus_map },
```

**check_completion** (~line 352):
```javascript
var puzzleData = cw.get_puzzle_data();
var data = { letters: puzzleData.letters, rebus_answers: puzzleData.rebus_map };
```

### 7d. Update `reveal_puzzle` (~line 431):
**⚠️ REVIEW FIX S2**: Add rebus CSS classes
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
      // Apply rebus font sizing
      $cell.removeClass('rebus-2 rebus-3 rebus-4');
      if (content.length === 2) $cell.addClass('rebus-2');
      else if (content.length === 3) $cell.addClass('rebus-3');
      else if (content.length >= 4) $cell.addClass('rebus-4');
    }
  });
  // ... rest unchanged (clear flags, check_all_finished, etc.)
```

---

## Task 8 · JS input — rebus mode toggle
**File**: `app/assets/javascripts/crosswords/crossword_funcs.js`

### 8a. Add to `window.cw` object:
```javascript
rebus_mode: false,
INSERT: 45,
```

### 8b. Modify keypress `default:` case (~line 174):
When `cw.rebus_mode` is true: append character, don't advance.
When false: existing behavior unchanged.

### 8c. Modify ESCAPE case (~line 158):
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

### 8d. Add INSERT case (after ESCAPE):
```javascript
case cw.INSERT:
  e.preventDefault();
  cw.rebus_mode = !cw.rebus_mode;
  $('#crossword').toggleClass('rebus-active', cw.rebus_mode);
  break;
```

### 8e. Modify backspace — BOTH delete_letter implementations
**⚠️ REVIEW FIX S3**: Both files need this.

**solve_funcs.js** `delete_letter`:
```javascript
$.fn.delete_letter = function(original) {
  if (this.is_empty_cell()) {
    // ... existing logic unchanged
  } else {
    if (cw.rebus_mode) {
      var current = this.get_letter().trim();
      if (current.length > 1) {
        this.set_letter(current.slice(0, -1), original);
        solve_app.update_unsaved();
        return;
      }
    }
    this.children(".letter").first().empty();
    // ... existing team broadcast logic unchanged
  }
};
```

**edit_funcs.js** `delete_letter`: Same rebus check pattern.

### 8f. Modify ENTER case (~line 162):
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

### 8g. Modify `set_letter` in cell_funcs.js (~line 239):
```javascript
$.fn.set_letter = function(letter, original) {
  this.children(".letter").first().text(letter);
  // Rebus font sizing
  this.removeClass('rebus-2 rebus-3 rebus-4');
  if (letter.length === 2) this.addClass('rebus-2');
  else if (letter.length === 3) this.addClass('rebus-3');
  else if (letter.length >= 4) this.addClass('rebus-4');
  // ... existing team broadcast code unchanged
};
```

---

## Task 9 · CSS

### Design tokens (`_design_tokens.scss`):
```scss
--font-size-rebus-2: 0.55em;
--font-size-rebus-3: 0.42em;
--font-size-rebus-4: 0.35em;
```

### Crossword styles (`crossword.scss.erb`):
```scss
.cell {
  &.rebus-2 .letter { font-size: var(--font-size-rebus-2); }
  &.rebus-3 .letter { font-size: var(--font-size-rebus-3); }
  &.rebus-4 .letter { font-size: var(--font-size-rebus-4); }
}

table#crossword.rebus-active .cell.selected {
  box-shadow: inset 0 0 0 2px var(--color-accent);
}
```

---

## Task 10 · Views

### Solve partial (`_solve_crossword.html.haml`, line 11):
```haml
- if @solution
  - sol_content = @solution.rebus_map[i.to_s] || @solution.letters[i]
  .letter{class: ("rebus-#{[sol_content.to_s.length, 4].min}" if sol_content.to_s.length > 1)}= sol_content
```

### Show template (`show.html.haml`, after line 15):
```haml
  solve_app.has_rebus = #{@crossword.rebus?.to_json}
```

---

## Task 11 · Editor wiring
**File**: `app/assets/javascripts/crosswords/edit_funcs.js`

In `ready()`:
```javascript
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

**crossword_factory.rb** — `:rebus` trait on `:predefined_five_by_five`:
**⚠️ REVIEW FIX M2**: Don't modify letters string!
```ruby
trait :rebus do
  after(:create) do |cw|
    cw.update!(rebus_map: { '0' => 'AM' })
    cw.cells.order(:index).first.update!(letter: 'AM')
  end
end
```

**solution_factory.rb** — `:with_rebus` trait:
```ruby
trait :with_rebus do
  after(:build) { |s| s.rebus_map = s.crossword.rebus_map.dup if s.crossword&.rebus? }
end
```

### Model specs — new contexts

**crossword_spec.rb**: `#answer_at`, `#rebus?`, `#cell_mismatches` with rebus, `#get_mismatches` with rebus
**solution_spec.rb**: `#check_completion` with rebus, `#percent_correct` with rebus, `#fill_letters` resets rebus_map

### Request specs — new context in check_functions_spec.rb

Rebus puzzle tests for: check_cell, check_puzzle with rebus_answers, check_completion with rebus_answers, reveal returns full content

### Service specs

**nyt_puzzle_importer_spec.rb**: Update rebus test to verify preservation
**crossword_publisher_spec.rb**: Add multi-char UCW letters → rebus_map extraction test
