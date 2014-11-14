class CoursesController < ApplicationController
  def new
    if not user_signed_in?
      render '/public/403.html'
    end
  end

  def create
    course_code = params[:course_code]
    course_name = params[:name]
    description = params[:description]
    students    = params[:students]
    tutors      = params[:tutors]
    convenors   = params[:convenors]

    # Create the course
    c = Course.create(
      :code => course_code,
      :name => course_name,
      :description => description)

    # Enrol staff and students

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
