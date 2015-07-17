ready = ->
  $("#assignment_custom_compilation").change ->
    $("#custom-command-field").toggleClass("hidden")
    $("#compilation-tests").toggleClass("hidden")

  $("#assignment_custom_command").on "input", ->
    $("#custom-command-well").removeClass("hidden")
    $("#custom-command-well").text($("#assignment_custom_command").val())
    
$(document).ready(ready);
$(document).on('page:load', ready);