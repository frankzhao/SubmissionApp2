//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require bootstrap.min
//= require date
//= require chart.min
// require websocket_rails/main
//= require nprogress
//= require nprogress-turbolinks
//= require_self
//= require_tree .

function hide (e) {
  $(e).fadeOut(200);
}

NProgress.configure({
  showSpinner: false
});

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

