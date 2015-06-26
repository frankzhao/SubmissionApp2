class WebsocketController < WebsocketRails::BaseController
  def initialize_session
    # perform application setup here
    # controller_store[:message_count] = 0
    message = "Executing..."
  end
  
  def testevent
    sleep(5)
    send_message :event, {message: Time.now.to_s}
  end
end