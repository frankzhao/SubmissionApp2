class UsersController < ApplicationController
  before_filter :require_logged_in

  def show
    if params[:id] && User.find_by_id(params[:id])
      @user = User.find_by_id(params[:id])
      unless current_user.is_staff? or current_user == @user
        flash_message :error, "Could not find user with ID=" + params[:id]
      end
    else
      flash_message :error, "Could not find user with ID=" + params[:id]
    end

    if current_user.is_admin?
      current_user.courses = Course.all
    end
  end
end
