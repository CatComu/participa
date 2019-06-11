#= require select2
#= require select2_impl
$(document).ready ->
  if $("#group_has_location").is(':checked')
    $('#territory_form').show()
  else
    $('#territory_form').hide()
  $("#group_has_location").change ->
    $('#territory_form').toggle()
    $("#group_location_type").val(null).trigger('change')

  $("#group_location_type").change ->
    $("#group_territory_holder").val(null).trigger('change')
    $("#group_territory_holder").children("option").remove()
    $.get "/api/v1/locations/" + $("#group_location_type").val(), (data) ->
      $("#group_territory_holder").append("<option value=\"\"></option>")
      $.each data, (i, item) ->
        $("#group_territory_holder").append("<option value=\"" + $("#group_location_type").val() + "-" + item.id + "\">" + item.name + "</option>")

