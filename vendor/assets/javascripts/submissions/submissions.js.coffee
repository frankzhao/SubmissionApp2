# Websocket code for submissions (if websocket compatible)
# Otherwise this will fall back to AJAX

dispatcher = new WebSocketRails('/websocket')
	
success = (response) ->
  alert 'Success: ' + response.message

failure = (response) ->
  alert 'Failure: ' + response.message

channel = dispatcher.subscribe('submissions')
channel.bind('compile', (log) ->
  result = log.result.replace(/\n/g,"<br/>")
  $('.results').html(result)
)

compilationResults = ->
  id = parseInt($("#submission-id").text())
  $.ajax "/submissions/check_result",
    type: "POST"
    data:
      id: id
      authenticity_token: AUTH_TOKEN
    success: (response) ->
      result = response.result
      if (result)
        console.log(result)
        result = result.replace(/\n/g,"<br/>")
        $(".results").html(result)
      
$(document).ready(compilationResults);