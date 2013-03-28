$(function(){
  $('body').on('click', '.foundicon-search', submit_closest_form);
});

function submit_closest_form(){
  $(this).closest('form').submit();
}