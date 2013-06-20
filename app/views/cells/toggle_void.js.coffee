#Strangely enough, this file has embedded Ruby but does not require the .erb file extension
#In fact, the .erb extension will prevent Rails from recognizing this file. Weird...

# AJAX re-renders the cell and its mirror, then once both are re-rendered the cells are re-numbered
update_cell = $("<%=j @cell.is_void? ? render(partial: 'cells/partials/void_cell', locals: {cell: @cell}) : render(partial: 'cells/partials/cell', locals: {cell: @cell}) %>")
update_mirror_cell = $("<%=j @mirror_cell.is_void? ? render(partial: 'cells/partials/void_cell', locals: {cell: @mirror_cell}) : render(partial: 'cells/partials/cell', locals: {cell: @mirror_cell}) %>")
$.when(
  $(".cell[data-id=<%=@cell.id %>]").after(update_cell).remove(),
  $(".cell[data-id=<%=@mirror_cell.id %>]").after(update_mirror_cell).remove()
).then number_cells()


# // AJAX re-renders the cell and its mirror, then once both are re-rendered the cells are re-numbered
# var update_cell = $("<%=j @cell.is_void? ? render(partial: 'cells/partials/void_cell', locals: {cell: @cell}) : render(partial: 'cells/partials/cell', locals: {cell: @cell}) %>");
# var update_mirror_cell = $("<%=j @mirror_cell.is_void? ? render(partial: 'cells/partials/void_cell', locals: {cell: @mirror_cell}) : render(partial: 'cells/partials/cell', locals: {cell: @mirror_cell}) %>");
# $.when(
#   $(".cell[data-id=<%=@cell.id %>]").after(update_cell).remove(),
#   $(".cell[data-id=<%=@mirror_cell.id %>]").after(update_mirror_cell).remove()
# ).then(number_cells());