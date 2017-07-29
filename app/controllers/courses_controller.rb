class CoursesController < ApplicationController

  before_action :require_logged_in
  before_action :require_convenor_or_admin, :only => [:new, :create, :destroy, :edit]
  before_action :set_course, only: [:edit, :update, :show, :destroy, :groups]

  respond_to :html

  def index
    if current_user.is_admin?
      @courses = Course.all
    else
      @courses = current_user.courses
    end
  end

  def new
    @course = Course.new
  end

  def create
    course = Course.create!(course_params)

    service = ::Courses::EnrollService.new(@course,
                                           students: student_uids,
                                           tutors: tutor_uids,
                                           convenors: convenor_uids)

    if current_user.is_convenor?
      service.add_convenor(current_user.uid)
    end

    service.execute

    for u in course.users
      u.assignments << c.assignments
    end

    redirect_to courses_path
  end

  def edit
    @course = Course.find(params[:id])
    respond_with @course
  end

  def update
    @course.update_attributes(course_params)

    service = ::Courses::EnrollService.new(@course,
                                           students: student_uids,
                                           tutors: tutor_uids,
                                           convenors: convenor_uids)

    service.execute

    for u in @course.users
      u.assignments << @course.assignments
    end

    respond_with @course
  end

  def show
    @all_students = @course.get_student_roles
    @population = @all_students.count
    @all_assignments = @course.assignments
    @groups = @course.groups
    if !@course.users.include?(current_user) && !current_user.is_staff?
      flash_message :error, "You don't have permission to access that."
      redirect_to root_path
    end
  end

  def destroy
    @course.destroy
    respond_with @course
  end
  
  def groups
    @groups = @course.groups
  end
  
  private

  def course_id
    params.require(:id)
  end

  def set_course
    @course = Course.find(course_id)
  end

  def course_params
    params.require(:code)
    params.require(:name)
    params.require(:description)
    params.permit(:code, :name, :description)
  end

  def student_uids
    params.require(:students)
  end

  def convenor_uids
    params.require(:convenors)
  end

  def tutor_uids
    params.require(:tutors)
  end
end
