#= require cocoon

hideSingleRemoveLink = ->
  if $('.doc-remove-link:visible').length == 1
    $('.doc-remove-link').hide()

showMultipleRemoveLinks = ->
  if $('.doc-remove-link').length > 1
    $('.doc-remove-link').show()

$ ->
  hideSingleRemoveLink()

  $('#doc-field-container').on 'cocoon:after-insert', showMultipleRemoveLinks

  $('#doc-field-container').on 'cocoon:after-remove', hideSingleRemoveLink
