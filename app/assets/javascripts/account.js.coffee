window.account =
  ready: ->
    $('.slide-close').on('click', (e)->
      e.preventDefault()
      $(this).parent().slideUp()
    )

$(document).ready(account.ready)