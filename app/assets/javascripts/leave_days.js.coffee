# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready = ->
  $("#leave_day_datepicker").datepicker
    weekStart: 1
    format: "dd/mm/yyyy"
    multidate: true
    daysOfWeekDisabled: "0,6"
    todayBtn: "linked"
  $("#leave_day_single_datepicker").datepicker
    weekStart: 1
    format: "dd/mm/yyyy"
    daysOfWeekDisabled: "0,6"
    todayBtn: "linked"

$(document).ready(ready)
$(document).on('page:load', ready)
