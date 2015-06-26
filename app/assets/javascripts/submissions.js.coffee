dispatcher = new WebSocketRails('localhost:3000/websocket')
# dispatcher.on_open = (data) ->
# 	alert('Connection established ' + data)
	
success = (response) ->
  alert 'Wow it worked: ' + response.message

failure = (response) ->
  alert 'That just totally failed: ' + response.message


object_to_send = { data: 'test' }

addtodom = (data) ->
	$('.page-header').text(data)

dispatcher.trigger('event','test',success,failure)
dispatcher.bind('event', (data) ->
	$('.page-header').text(data.message)
)