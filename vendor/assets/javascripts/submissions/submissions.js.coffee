dispatcher = new WebSocketRails('localhost:3000/websocket')
# dispatcher.on_open = (data) ->
#   alert('Connection established ' + data)
	
success = (response) ->
  alert 'Success: ' + response.message

failure = (response) ->
  alert 'Failure: ' + response.message
#
#
# object_to_send = { data: 'test' }
#
# addtodom = (data) ->
#   $('.page-header').text(data)
#
# dispatcher.trigger('event','test',success,failure)
# dispatcher.bind('event', (data) ->
#   $('.page-header').text(data.message)
# ) 'compilation_js'

channel = dispatcher.subscribe('submissions')
channel.bind('compile', (log) ->
  result = log.result.replace("\n","<br><br>")
  $('.results').html(result)
)

# dispatcher.trigger('submissions.compile','test',success,failure)
#
# dispatcher.bind('submissions.compilation_results', (response) ->
#   alert(response.message)
# )