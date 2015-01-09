function NotificationSetup()
{
	setInterval(NotificationUpdate, 60000);
	NotificationUpdate();
}

function NotificationUpdate()
{
	$.get( "/users/notifications", function(data) {
		var list = data.list;

		if(list.length == 0) {
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
			link.innerText = list[i].text;
			link.onclick = function() {
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
	var id = parseInt(e.id.match(/(\d)+/));

	$.ajax({
		url: "/users/notifications",
		type: "DELETE",
		data: {
			"id" : id,
			"authenticity_token" : AUTH_TOKEN
		}
	});
  
  NotificationUpdate();
}

NotificationSetup();
