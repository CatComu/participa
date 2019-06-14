#= require select2
#= require select2_impl


get_territory_holder = ->
  $.get "/api/v1/locations/" + $("#group_location_type").val(), (data) ->
    $("#group_territory_holder").append("<option value=\"\"></option>")
    $.each data, (i, item) ->
      $("#group_territory_holder").append("<option value=\"" + $("#group_location_type").val() + "-" + item.id + "\">" + item.name + "</option>")
      territory_holder_id = $('#js-territory_holder_val').html()
      if (territory_holder_id != "")
        $('#group_territory_holder').val(territory_holder_id).trigger('change');

$(document).ready ->
  if $("#group_has_location").is(':checked')
    $('#territory_form').show()
    get_territory_holder()
  else
    $('#territory_form').hide()

  $("#group_has_location").change ->
    $('#territory_form').toggle()
    $("#group_location_type").val(null).trigger('change')

  $("#group_location_type").change ->
    $("#group_territory_holder").val(null).trigger('change')
    $("#group_territory_holder").children("option").remove()
    get_territory_holder()
    