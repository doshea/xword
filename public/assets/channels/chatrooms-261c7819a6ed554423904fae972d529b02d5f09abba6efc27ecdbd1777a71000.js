(function(){this.App||(this.App={}),App.cable=ActionCable.createConsumer()}).call(this),function(){}.call(this),function(){App.messages=App.cable.subscriptions.create("MessagesChannel",{received:function(e){return $("#messages").removeClass("hidden"),$("#messages").append(this.renderMessage(e))},renderMessage:function(e){return"<p> <b>"+e.user+": </b>"+e.message+"</p>"}})}.call(this);