$ ->
  positions = $('#user_position_ids').html()
  $('#user_group_id').change ->
    group = $('#user_group_id :selected').text().replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    options = $(positions).filter("optgroup[label=" + group + "]")
    if options
      $('#user_position_ids').html(options)
    else
      $('#user_position_ids').empty()

