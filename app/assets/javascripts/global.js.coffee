window.global =
  ready: ->
    $('body').on('click', '.fi-magnifying-glass', global.submit_closest_form)
    $('#top_search').on('keyup', '#query', global.live_search)

  submit_closest_form: ->
    $(this).closest('form').submit()

  live_search: ->
    query = $('#query').val()
    settings =
      dataType: 'script'
      type: 'GET'
      url: "/live_search"
      data: {query: query}
    $.ajax(settings)

$(document).ready(global.ready)