/* 
Custom jQuery Functions for Cells
-----------------------
These functions are used by both the in-site crossword solver and editor. While they can
technically be called by any jQuery object, they are intended to be called by the td.cell
elements of the table#crossword
*/

(function( $ ) {

  $.fn.get_row = function() {return this.data('row');};
  $.fn.get_col = function() {return this.data('col');};
  $.fn.is_void = function(){return this.hasClass('void');};

  $.fn.in_top_row = function() {return $(this).get_row() == 1;};
  $.fn.in_bottom_row = function() {return this.get_row() == $('#crossword').data('rows');};
  $.fn.in_left_col = function() {return this.get_col() == 1;};
  $.fn.in_right_col = function() {return this.get_col() == $('#crossword').data('cols');};

  $.fn.get_row_beginning = function(){var row = parseInt(this.get_row());return $('.cell[data-row=' + row + '][data-col=1]');}
  $.fn.get_row_end = function(){var row = parseInt(this.get_row());return $('.cell[data-row=' + row + '][data-col='+ $('#crossword').data('cols')+']');}
  $.fn.get_col_beginning = function(){var col = parseInt(this.get_col());return $('.cell[data-row=1][data-col='+ col +']');}
  $.fn.get_col_end = function(){var col = parseInt(this.get_col());return $('.cell[data-row=' + $('#crossword').data('rows') + '][data-col='+col+']');}

  // Return booleans indicating whether there is a cell adjacent to the one calling the function and whether it is non-void
  // TODO: Determine whether this is redundant with the "cell_to_left" series of functions
  $.fn.has_above = function(){if(this.in_top_row()){return false;} else {var row = parseInt(this.get_row());var col = parseInt(this.get_col());var above = $(".cell[data-row='" + (row - 1) + "'][data-col='"+ col +"']");return !above.is_void();}};
  $.fn.has_below = function(){if(this.in_bottom_row()){return false;} else {var row = parseInt(this.get_row());var col = parseInt(this.get_col());var below = $(".cell[data-row='" + (row + 1) + "'][data-col='"+ col +"']");return !below.is_void();}};
  $.fn.has_left = function(){if(this.in_left_col()){return false;} else {var row = parseInt(this.get_row());var col = parseInt(this.get_col());var left = $(".cell[data-row='" + row + "'][data-col='"+ (col-1) +"']");return !left.is_void();}};
  $.fn.has_right = function(){if(this.in_right_col()){return false;} else {var row = parseInt(this.get_row());var col = parseInt(this.get_col());var right = $(".cell[data-row='" + row + "'][data-col='"+ (col+1) +"']");return !right.is_void();}};

  // Returns the jQuery object of the adjacent cell
  $.fn.cell_to_left = function() {if(this.in_left_col()){return false;}  else {var left_cell = this.prevAll('.cell:not(.void)').first(); if(left_cell.get(0)){return left_cell}else{return false}}};
  $.fn.cell_to_right = function() {if(this.in_right_col()){return false;}  else {var right_cell = this.nextAll('.cell:not(.void)').first(); if(right_cell.get(0)){return right_cell}else{return false}}};
  $.fn.cell_above = function() {if( this.in_top_row() ){return false;} else {var row = parseInt(this.get_row());var col = parseInt(this.get_col());var above = $(".cell[data-row='" + (row - 1) + "'][data-col='"+ col +"']");if(!above.is_void()){return above;} else {return above.cell_above();}}};
  $.fn.cell_below = function() {if( this.in_bottom_row() ){return false;} else {var row = parseInt(this.get_row());var col = parseInt(this.get_col());var below = $(".cell[data-row='" + (row + 1) + "'][data-col='"+ col +"']");if (!below.is_void()){return below;} else {return below.cell_below();}}};

  $.fn.previous_cell = function(){return cw.select_across ? this.cell_to_left() : this.cell_above();}
  $.fn.next_cell = function(){ return cw.select_across ? this.cell_to_right() : this.cell_below();}
  $.fn.is_word_start = function(){return !(cw.select_across ? this.has_left() : this.has_above());}
  $.fn.is_word_end = function(){return !(cw.select_across ? this.has_right() : this.has_below());}

  $.fn.get_down_word_cells = function() {return this.get_down_start_cell().down_word_from_start();};
  $.fn.get_down_start_cell = function() {if( !this.has_above() ){return this;} else {return this.cell_above().get_down_start_cell();}};
  $.fn.get_down_end_cell = function() {if( !this.has_below() ){return this;} else {return this.cell_below().get_down_end_cell();}};
  $.fn.down_word_from_start = function() {if( !this.has_below() ){return [this];} else {return [this].concat(this.cell_below().down_word_from_start());}};
  $.fn.get_down_word = function(){return $.map( this.get_down_word_cells(), function(el, i){return el.text();}).join('');};

  $.fn.get_across_word_cells = function() {return this.get_across_start_cell().across_word_from_start();};
  $.fn.get_across_start_cell = function() {if( !this.has_left() ){return this;} else {return this.cell_to_left().get_across_start_cell();}};
  $.fn.get_across_end_cell = function() {if( !this.has_right() ){return this;} else {return this.cell_to_right().get_across_end_cell();}};
  $.fn.across_word_from_start = function() {if( !this.has_right() ){return [this];} else {return [this].concat(this.cell_to_right().across_word_from_start());}};
  $.fn.get_across_word = function(){return $.map( this.get_across_word_cells(), function(el, i){return el.text();}).join('');};

  $.fn.get_word_cells = function(){return (cw.select_across ? this.get_across_word_cells() : this.get_down_word_cells());};
  $.fn.word_from_start = function(){return (cw.select_across ? this.across_word_from_start() : this.down_word_from_start());};
  $.fn.get_start_cell = function(){return (cw.select_across ? this.get_across_start_cell() : this.get_down_start_cell());};
  $.fn.get_end_cell = function(){return (cw.select_across ? this.get_across_end_cell() : this.get_down_end_cell());};

  // Both a td.cell's number (if any) and its letter are stored as child divs, and these functions get and set these values
  $.fn.get_number = function(){var letter = this.children('.cell-num').text(); return letter.length > 0 ? letter : ' '};
  $.fn.set_number = function(number){this.children('.cell-num').text(number);};
  $.fn.get_letter = function(){var letter = this.children('.letter').first().text().replace(/\n/g,'').replace(/  +/g,''); return letter.length > 0 ? letter: ' '};
  $.fn.set_letter = function(letter, original){this.children('.letter').first().text(letter);if((typeof team_app != 'undefined')){if(original){team_app.send_team_cell(this, letter);} else {this.check_finisheds();}}}

  $.fn.is_last_letter_of_puzzle = function(){var word_cells = (cw.select_across ?  this.get_across_word_cells() : this.get_down_word_cells()); var last_index = word_cells.length - 1; return this[0] == word_cells[last_index][0];}
  $.fn.is_empty_cell = function(){return ((this.get_letter() == '') || (this.get_letter() == ' ') || (this.get_letter().replace(/\n/g,'').replace(/  +/g,' ') == ' '));};

  $.fn.corresponding_across_clue = function(){return this.data('id') ? $(".across-clue[data-cell-id=" + this.data('id') + "]") : $(".across-clue[data-cell-num=" + this.data('cell') + "]");}
  $.fn.corresponding_down_clue = function(){return this.data('id') ? $(".down-clue[data-cell-id=" + this.data('id') + "]") : $(".down-clue[data-cell-num=" + this.data('cell') + "]");}
  $.fn.corresponding_clue = function(){return cw.select_across ? this.corresponding_across_clue() : this.corresponding_down_clue();}

  // Highlights this cell as the current cell in which the user is typing, unhighlights all other cells, and highlights the word this cell is in
  $.fn.highlight = function(){if (this.hasClass('cell') && !this.is_void()){cw.unhighlight_all(); cw.selected = this; this.addClass('selected'); cw.word_highlight();}}

  // 
  $.fn.in_finished_across_word = function(){var cells = this.get_across_word_cells(); var is_finished = true; for (i = 0; i < cells.length; i++){if(cells[i].is_empty_cell()){is_finished = false; break;}} return is_finished;};
  $.fn.in_finished_down_word = function(){var cells = this.get_down_word_cells(); var is_finished = true; for (i = 0; i < cells.length; i++){if(cells[i].is_empty_cell()){is_finished = false; break;}} return is_finished;};
  $.fn.in_finished_word = function(){var cells = this.get_word_cells(); var is_finished = true; for (i = 0; i < cells.length; i++){if(cells[i].is_empty_cell()){is_finished = false; break;}} return is_finished;};
  $.fn.in_directional_finished_word = function(){return (cw.select_across ? this.in_finished_across_word() : this.in_finished_down_word());}

  // These functions are a bit unusual as they only function for the starting cells of words
  $.fn.check_finisheds = function(){if(this.in_finished_across_word()){this.get_across_start_cell().corresponding_across_clue().addClass('crossed-off');}if(this.in_finished_down_word()){this.get_down_start_cell().corresponding_down_clue().addClass('crossed-off');}}
  $.fn.uncheck_unfinisheds = function(){this.get_across_start_cell().corresponding_across_clue().removeClass('crossed-off'); this.get_down_start_cell().corresponding_down_clue().removeClass('crossed-off');}

  $.fn.next_empty_cell_in_word = function(){
    return ((this.is_word_end() || this.is_empty_cell()) ? this : this.next_cell().next_empty_cell_in_word());
  }

  $.fn.next_empty_cell = function(){
    if(this.is_last_letter_of_puzzle()){
      if(this.is_empty_cell()){
        return this;
      } else {
        cw.highlight_next_word();
        if($('.selected').get_number() != 1){
          return $('.selected').is_empty_cell() ? $('.selected') : $('.selected').next_empty_cell();
        }
      }
    } else {
      var next = this.next_cell();
      return (next.is_empty_cell() ? next : next.next_empty_cell());
    }
  }
})( jQuery );