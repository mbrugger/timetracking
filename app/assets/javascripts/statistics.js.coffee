# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
updateContent = (date) ->
  base_url = $("#base-url").val()
  $.get base_url + '/content/',
    date: date
  , (data) ->
    $("#statistics-leave-days-content").html data
    return

ready = ->
  $("#statistics_leave_days_day_datepicker").datepicker(
    weekStart: 1
    format: "dd/mm/yyyy"
    todayBtn: "linked"
    autoclose: true
    ).on "changeDate", (e) ->
      updateContent e.format()
      return

$(document).ready(ready)
$(document).on('page:load', ready)
