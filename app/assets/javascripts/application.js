//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require date
//= require chart.min
//= require_self
//= require_tree .

function hide (e) {
  $(e).fadeOut(200);
}

ready = function () {
  /* Hide sidebar */
  $(".sidebar .menu-icon-container").click(
    function () {
      $("#sidebar").addClass("hidden");
      $("#content .menu-icon-container").removeClass("hidden");
      $("#content").removeClass("col-md-9").addClass("col-md-12");
      $(this).addClass("hidden")
    }
  );

  /* Show sidebar */
  $("#content .menu-icon-container").click(
    function () {
      $("#sidebar").removeClass("hidden");
      $(".sidebar .menu-icon-container").removeClass("hidden");
      $("#content").removeClass("col-md-12").addClass("col-md-9");
      $(this).addClass("hidden")
    }
  );
}

$(document).ready(ready);
$(document).on('page:load', ready);
