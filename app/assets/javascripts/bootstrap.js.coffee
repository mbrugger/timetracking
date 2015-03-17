jQuery ->
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()

ready = ->
  $('select#date_filter_year').on "change", ->
    $('input#year').val @value
    $('form#date_filter').submit()
    return

$(document).ready(ready)
$(document).on('page:load', ready)
