(function(){window.new_cw={form_spinner:null,spin_opts:{lines:10,length:15,width:4,radius:6,corners:1,rotate:0,direction:1,color:"#000",speed:1,trail:60,shadow:!1,hwaccel:!1,className:"spinner",zIndex:2e9,top:"auto",left:"auto"},clever_processes:["Reticulating splines","barfing"],ready:function(){return $("form").on("submit",new_cw.generate_puzzle_overlay),$("#crossword_rows, #crossword_cols").on("change",new_cw.regenerate_preview),$("#preview-crossword").on("mousedown",".preview-cell",function(){return $(this).toggleClass("void")}),new_cw.hide_extra_cells()},generate_puzzle_overlay:function(){return $("#body .row:not(.row-bookend)").first().children().animate({opacity:0},"slow",function(){var e;if(!new_cw.form_spinner)return console.log("hello2"),e=$(".spin-target").get(0),new_cw.form_spinner=new Spinner(new_cw.spin_opts).spin(e),$("<h2>").text("Generating Puzzle").prependTo($(".spin-target")),$("<h6>").text(new_cw.clever_processes[0]).appendTo($(".spin-target"))})},regenerate_preview:function(){return $(".preview-cell").show(),new_cw.hide_extra_cells()},hide_extra_cells:function(){var e,r,n;return n=$("#crossword_rows").val(),e=$("#crossword_cols").val(),r=$(".preview-cell").filter(function(){return $(this).data("col")>e||$(this).data("row")>n}),r.hide()}},$(document).ready(new_cw.ready)}).call(this);