class NotificationsController < ApplicationController
	before_filter :require_logged_in

	respond_to :json

  def dismiss
  	notification = Notification.find(params[:id])

  	if !notification.nil?
  		notification.dismiss!
  		render :json => "", :status => 200
  	else
  		render :json => { :error => "Unable to find Notification"}, :status => 404
  	end
  end

  def list
  	render :json => { "list" => current_user.notifications }
  end
end