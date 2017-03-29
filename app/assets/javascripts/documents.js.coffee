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
  if document.getElementById('images')
    viewer = new Viewer(document.getElementById('images'), url: 'data-original')

  hideSingleRemoveLink()

  $('#doc-field-container').on 'cocoon:after-insert', showMultipleRemoveLinks

  $('#doc-field-container').on 'cocoon:after-remove', hideSingleRemoveLink
