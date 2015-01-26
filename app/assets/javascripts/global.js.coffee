window.global =
  ready: ->
    $('body').on('click', '.fi-magnifying-glass', global.submit_closest_form)
    $('#top-search').on('keyup', '#query', global.live_search)
    $('#dropdown-login').on 'click', (e)->
      e.stopPropagation()

  submit_closest_form: ->
    $(this).closest('form').submit()

  live_search: ->
    query = $('#query').val()
    if query.length < 3
      $('#live-results').hide()
    else
      settings =
        dataType: 'script'
        type: 'GET'
        url: "/live_search"
        data: {query: query}
      $.ajax(settings)

$(document).ready(global.ready)