App.messages = App.cable.subscriptions.create('MessagesChannel',
  received: (data) ->
    $('#messages').removeClass 'hidden'
    $('#messages').append @renderMessage(data)
  renderMessage: (data) ->
    '<p> <b>' + data.user + ': </b>' + data.message + '</p>'
)