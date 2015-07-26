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

updateWorkingDaysStatistics = (start_date, end_date, users) ->
  base_url = $("#base-url").val()
  $.get base_url + '/content/',
    start_date: start_date
    end_date: end_date
    users: users
  , (data) ->
    $("#statistics-working-hours-content").html data
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
  $("#statistics_working_hours_datepicker").datepicker
    weekStart: 1
    format: "dd/mm/yyyy"
    todayBtn: "linked"
  $("#statistics_working_hours_datepicker_refresh").on "click", (e) ->
    updateWorkingDaysStatistics $("#statistics_working_hours_datepicker input")[0].value, $("#statistics_working_hours_datepicker input")[1].value, $("#users-select").val()
  $("#users-select").multiselect(
    enableFiltering: true
    buttonClass: 'btn btn-default btn-sm users-button'
  )

$(document).ready(ready)
$(document).on('page:load', ready)
