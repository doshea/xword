function draw_letters($row) {
  var cols = 15;
  var key = $row.data("key");
  var hidden_canvas = $("canvas#letters_" + key).get(0);
  if (!hidden_canvas) {
    hidden_canvas = $("<canvas class='hidden-canvas' id='letters_" + key + "'>");
    console.log("Made a hidden canvas!");
    $row.children(":first-child").append(hidden_canvas);
    var main_canvas = $("canvas[id^='crossword']");
    var left_corner_x = main_canvas.offset().left + 1;
    var left_corner_y = main_canvas.offset().top + 1;
    hidden_canvas.width(main_canvas.width());
    hidden_canvas.height(main_canvas.height());
    hidden_canvas.offset({
      top: left_corner_y,
      left: left_corner_x
    });

    var temp_context = hidden_canvas.get(0).getContext("2d");
    var letters = $row.data("letters");
    temp_context.font = "bold 10px Helvetica Neue";
    var letter_array = [];
    while (letters.length > 0) {
      letter_array.push(letters.substr(0, cols));
      letters = letters.substr(cols);
    }
    letter_array.each(function(string, row) {
      string.each(function(char, col) {
        if (char !== " " && char !== "_") {
          var x = ((col === 0) ? 2.5 : 3.5 + 10 * col) * 2;
          var y = (row === 0) ? 7.5 : 10 + 10 * row;
          temp_context.fillText(char, x, y);
        }
      });
    });
  }
}

$("tbody").on("click", "tr td:not(.delete-td)", function(e) {
  e.preventDefault();
  window.location = $(this).parent().data("link");
});

$("tbody tr").each(function(index, el) {
  draw_letters($(el));
});
