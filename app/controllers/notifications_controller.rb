class NotificationsController < ApplicationController
	before_action :require_logged_in

  def index
    @notifications = current_user.notifications
    render json: { list: @notifications }
  end

  def destroy
  	notification = current_user.notifications.find(params[:id])

  	if notification
      current_user.notifications.delete(notification)
      notification.destroy

  		render json: { link: notification.link }, status: 200
  	else
  		render json: { :error => "Unable to find Notification"}, status: 404
  	end
  end
end