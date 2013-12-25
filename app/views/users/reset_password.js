$('input.fade-on-submit').attr('disabled', true);
$('.fade-on-submit').animate({opacity: 0}, 500, function(){
  $('#email-sent').fadeIn(300);  
});
