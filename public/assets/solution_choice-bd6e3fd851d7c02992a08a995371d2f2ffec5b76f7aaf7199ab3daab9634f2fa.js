(function(){var t;t=function(t){var e,n,a,i,o,r,c,d,s;if(e=15,a=t.data("key"),n=$("canvas#letters_"+a).get(0),!n){for(n=$("<canvas class='hidden-canvas' id='letters_"+a+"'>"),console.log("Made a hidden canvas!"),t.children(":first-child").append(n),d=$('canvas[id^="crossword"]'),i=d.offset().left+1,o=d.offset().top+1,n.width(d.width()),n.height(d.height()),n.offset({top:o,left:i}),s=n.get(0).getContext("2d"),c=t.data("letters"),s.font="bold 10px Helvetica Neue",r=[];c.length>0;)r.push(c.substr(0,e)),c=c.substr(e);return r.each(function(t,e){return t.each(function(t,n){var a,i;if(" "!==t&&"_"!==t)return a=2*(0===n?2.5:3.5+10*n),i=0===e?7.5:10+10*e,s.fillText(t,a,i)})})}},$("tbody").on("click","tr td:not(.delete-td)",function(t){return t.preventDefault(),window.location=$(this).parent().data("link")}),$("tbody tr").each(function(e,n){return t($(n))})}).call(this);