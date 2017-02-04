class UsersController < ApplicationController
  before_action :require_logged_in

  def show
    if params[:id].nil?
      @user = current_user
    else
      @user = User.find_by_id(params[:id])
      unless current_user.is_staff? or current_user == @user
        flash_message :error, "You don't have permission to access that."
        redirect_to '/'
        return
      end

      if @user.nil?
        flash_message :error, "User was not found"
        redirect_to '/'
        return
      end
    end

    if current_user.is_admin?
      @courses = Course.all
      @course_assignments = Assignment.all.group_by(&:course)
      @assignments = Assignment.all
    else
      @courses = @user.courses
      @course_assignments = @user.assignments.group_by(&:course)
      @assignments = @user.assignments.uniq
    end
  end
end
