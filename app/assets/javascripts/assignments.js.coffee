ready = ->
  $("#assignment_custom_compilation").change ->
    $("#custom-command-field").toggleClass("hidden")
    $("#compilation-tests").toggleClass("hidden")
    
$(document).ready(ready);
$(document).on('page:load', ready);