class UsersController < ApplicationController
  before_action :require_logged_in
  before_action :set_user, only: :show
  before_action :check_user_privilege, only: :show

  def me
    @user = current_user

    if @user.is_admin?
      load_admin_content
    else
      load_user_content
    end

    render 'show'
  end

  def show
    load_user_content
  end

  private

  def user_id
    params.require(:id)
  end

  def set_user
    @user = User.find(user_id)
  end

  def load_user_content
    @courses = @user.courses.latest
    @course_assignments = @user.assignments.group_by(&:course)
    @assignments = @user.assignments.uniq
  end

  def load_admin_content
    @courses = Course.latest
    @course_assignments = Assignment.all.group_by(&:course)
    @assignments = Assignment.all
  end

  def check_user_privilege
    unless current_user.is_staff? or current_user == @user
      flash_message :error, "You don't have permission to access that."
      redirect_to root_path
    end
  end
end
