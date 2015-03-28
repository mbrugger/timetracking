# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
updateReport = (date) ->
  base_url= $("#base-url").val()
  $.get base_url + '/content/' + date.getFullYear() + '/' + (date.getMonth()+1)
  , (data) ->
    $("#report-content").html data
    ready()
    return

ready = ->
  $("#reports-datepicker").datepicker(
    format: "mm/yyyy"
    minViewMode: 1
    autoclose: true
    ).on "changeDate", (e) ->
      updateReport e.date
      return

$(document).ready(ready)
$(document).on('page:load', ready)
