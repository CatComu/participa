#= require img-viewerjs/dist/viewer
#= require cocoon
#= require bootstrap/modal

hideSingleRemoveLink = ->
  if $('.doc-remove-link:visible').length == 1
    $('.doc-remove-link').hide()

showMultipleRemoveLinks = ->
  if $('.doc-remove-link').length > 1
    $('.doc-remove-link').show()

$ ->
  for element, _index in $('.image-list')
    viewer = new Viewer(element, url: 'data-original')

  hideSingleRemoveLink()

  $('#doc-field-container').on 'cocoon:after-insert', showMultipleRemoveLinks

  $('#doc-field-container').on 'cocoon:after-remove', hideSingleRemoveLink
