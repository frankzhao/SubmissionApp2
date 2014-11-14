class CoursesController < ApplicationController
  def new
  end

  def create
  end

  def edit
  end

  def show
  end

  def index
    if user_signed_in?
      if current_user.is_admin?
        @courses = Course.all
      else
        @courses = current_user.courses
      end
    else
      render '/public/403.html'
    end
  end

  def destroy
  end
end
