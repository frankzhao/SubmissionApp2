function NotificationSetup()
{
	//setInterval(NotificationUpdate, 60000);
	NotificationUpdate(false);
}

function NotificationUpdate(link)
{ 
	$.get( "/users/notifications", function(data) {
		var list = data.list;
    
    if (list == null) {
      return
    }

		if(list.length === 0) {
			$("#notification-badge").addClass("hidden");
			return
		}

		$("#notification-list").empty();

		for(var i = 0; i < list.length; i++) {
			var container = document.createElement('li');
			var link = document.createElement('a');

			container.className = "notification";
			link.id = 'notification_' + list[i].id;
			link.href = list[i].link;
      link.textContent = list[i].text;
			link.innerText = list[i].text;
			link.onclick = function(e) {
        e.preventDefault();
				NotificationDismiss(this);
			};

			container.appendChild(link);

			$("#notification-list").append(container);
		}

		$("#notification-badge").removeClass("hidden");
		$("#notification-badge").text(list.length);
	});
}

function NotificationDismiss(e)
{
	var id = parseInt(e.id.match(/(\d)+/igm)[0]);
  var link = e.href

	$.ajax({
		url: "/users/notifications",
		type: "DELETE",
		data: {
			"id" : id,
			"authenticity_token" : AUTH_TOKEN
		},
    success: function(data) {
      window.location = data.link;
    }
	});
  NotificationUpdate(link);
}

NotificationSetup();
