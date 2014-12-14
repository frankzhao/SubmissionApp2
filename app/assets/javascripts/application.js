//= require jquery
//= require bootstrap.min
//= require jquery_ujs
//= require prettify/prettify
//= require date
//= require chart.min
//= require turbolinks
//= require_tree .

function hide (e) {
  $(e).fadeOut(200);
}

ready = function () {
  prettyPrint();
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
