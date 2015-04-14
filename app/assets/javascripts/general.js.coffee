ready = ->
  $(".alert").bind 'click', (ev) =>
    $(".alert").fadeOut()

$(document).ready(ready)
$(document).on('page:load', ready)
