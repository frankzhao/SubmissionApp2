class NotificationsController < ApplicationController
	before_action :require_logged_in

	respond_to :js

  def dismiss
  	notification = Notification.find(params[:id])

  	if !notification.nil?
      current_user.notifications.delete(notification)
      notification.destroy
  		render :json => {link: notification.link}, :status => 200
  	else
  		render :json => { :error => "Unable to find Notification"}, :status => 404
  	end
  end

  def list
  	render :json => { "list" => current_user.notifications }
  end
end