//Key Constants for keyboard controls
var UP = 38;
var RIGHT = 39;
var DOWN = 40;
var LEFT = 37;
var COMMAND = 91;
var ENTER = 13;
var SPACE = 32;
var DELETE = 8;
var SHIFT = 16;
var TAB = 9;
var BACKSPACE = 8;
var PAGE_NAV_KEYS = [UP, RIGHT, DOWN, LEFT, SPACE];

//Global variables for crossword control
var selected;
var select_across = true;
var counter = 1;

//Document load events and event triggers
$(function(){
  number_cells();
  selected = $('.cell:not(.void)').first();
  cell_highlight(selected);
  $('#crossword').focus();

  $(document).on('keydown', crossword_keypress);

  $('#crossword').on('click', 'td.cell', function(){ cell_highlight($(this)); });
  $('.clue_column').on('click', '.clue', function(){ highlight_clue_cell($(this)); });

});

//Intelligently sets the numbers of each cell in the crossword by calling the number_cell function
function number_cells(){
  counter = 1;
  var $cells = $('.cell:not(.void)');
  $.each($cells, function(index, value){
    number_cell($(value));
  });
  counter = 1;
}

//Numbers cells if they are the lefmost or topmost cell in a word
function number_cell($cell){
  if(!$cell.has_above() || !$cell.has_left()){
    $cell.set_number(counter);
    $cell.attr('data-cell', counter); //no idea why this won't work when I use the .data() method...
    counter += 1;
  }
}

//selects the given cell and the word in which it appears
function cell_highlight($cell){
  if($cell.hasClass('cell') && !$cell.hasClass('void')){
    unhighlight_all();
    selected = $cell;
    $cell.addClass('selected');
    word_highlight();
  }
}

function highlight_clue_cell($clue){
  var $cell = $(".cell[data-cell='" + $clue.attr('clue_num') + "']").first();
  select_across = $clue.closest('.clues').attr('id') == 'across';
  cell_highlight($cell);
}

function highlight_next_word(){
  var clue = $('.clue.selected_clue');
  var next_clue = clue.next().first();
  if(next_clue.hasClass('clue')){
    console.log( solve_app.debug_mode ?  'next_clue has class clue': '' );
    highlight_clue_cell(next_clue);
  } else {
    highlight_clue_cell(clue.parent().parent().siblings('.clue_column').first().children().children().first());
  }
}

//highlights the word for a given cell
function word_highlight(){
  $('.selected_word').removeClass('selected_word');
  var $cell = $('.selected');
  var selected_word_letters = select_across ? $cell.get_across_word_cells() : $cell.get_down_word_cells();
  $.each(selected_word_letters, function(index, value){
    value.addClass('selected_word');
  });
  var select_start = select_across ? $cell.get_across_start_cell() : $cell.get_down_start_cell();
  corresponding_clue(select_start).addClass('selected_clue');
  scroll_to_selected();
}

//Unhighlights all cells and clues
function unhighlight_all(){
  selected = null;
  $('.selected').removeClass('selected');
  $('.selected_word').removeClass('selected_word');
  $('.selected_clue').removeClass('selected_clue');
}

//Takes a cell as a parameter and returns its corresponding clue
function corresponding_clue($cell){
  var dir = select_across ? '.across_clue' : '.down_clue';
  var num = $cell.get_number();
  return $("" + dir +"[clue_num=" + num + "]");
}

//
function scroll_to_selected(){
  var $sel_clue = $('.selected_clue');
  var $clues = $sel_clue.closest('ol');
  var top = $clues.scrollTop() + $sel_clue.position().top - $clues.height()/2 + $sel_clue.height()/2;
  // console.log('Clues div has top at ' + $clues.scrollTop() + ' and selected clue is ' + $sel_clue.position().top + ' from the top. The div height is ' + $clues.height()/2 + ' and the clue height is ' + $sel_clue.height()/2 + ' so we scrollTo ' + top)
  $clues.stop().animate({scrollTop: top}, 'fast');
}

function selected_word(){
  var letters = '';
  $.each($('.selected_word'), function(index, value){
    letters += $(value).get_letter();
  });
  return letters;
}

//Keyboard Function triggered by
function crossword_keypress(e){
  if(!(e.ctrlKey || e.altKey || e.metaKey )){
    var key = e.which;

    switch (key){
      case UP:
        if(selected && selected.cell_above()){
          cell_highlight(selected.cell_above());
        }
        break;
      case RIGHT:
        if(selected && selected.cell_to_right()){
          cell_highlight(selected.cell_to_right());
        }
        break;
      case DOWN:
        if(selected && selected.cell_below()){
          cell_highlight(selected.cell_below());
        }
        break;
      case LEFT:
        if(selected && selected.cell_to_left()){
          cell_highlight(selected.cell_to_left());
        }
        break;
      case TAB:
        unhighlight_all();
        break;
      case SHIFT:
        break;
      case DELETE:
        break;
      case SPACE:
        select_across = !select_across;
        cell_highlight($('.selected'));
        break;
      default:
        if(selected){
          console.log( solve_app.debug_mode ?  'Typing letter': '' );
          var letter = String.fromCharCode(key);
          if(letter != selected.get_letter()){
            selected.set_letter(String.fromCharCode(key));
            solve_app.update_unsaved();
          }
          console.log( solve_app.debug_mode ?  'highlighting cell': '' );
          cell_highlight(selected.next_empty_cell());
        }
    }
  }
}

function get_letters(){
  var letters = '';
  var $cells = $('.cell');
  $.each($cells, function(index, value){
    letters += $(value).hasClass('void') ? '_'  : $(value).get_letter() ;
  });
  return letters;
}

//Prevents backspace from going to previous window, prevents arrow keys and space from moving around page
document.onkeydown = suppressBackspaceAndNav;
document.onkeypress = suppressBackspaceAndNav;
function suppressBackspaceAndNav(evt) {
  evt = evt || window.event;
  var target = evt.target || evt.srcElement;
  if (evt.keyCode == BACKSPACE && !/input|textarea/i.test(target.nodeName)) {
    selected.delete_letter();
    solve_app.update_unsaved();
    return false;
  }
  if ( _.contains(PAGE_NAV_KEYS, evt.keyCode) && !/input|textarea/i.test(target.nodeName) ) {
    return false;
  }
}