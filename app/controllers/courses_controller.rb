class CoursesController < ApplicationController

  before_action :require_logged_in
  before_action :require_convenor_or_admin, :only => [:new, :create, :destroy, :edit]
  before_action :set_course, only: [:edit, :update, :show, :destroy, :groups]
  before_action :require_part_of_course, only: [:show]

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

    enroll_service = ::Courses::EnrollService.new(@course,
                                           students: student_uids,
                                           tutors: tutor_uids,
                                           convenors: convenor_uids)

    if current_user.is_convenor?
      enroll_service.add_convenor(current_user.uid)
    end

    enroll_service.execute
    generate_flash_for_enrollment(enroll_service)

    ::Courses::AssignmentService.new(@course).execute

    redirect_to courses_path
  end

  def edit
    @course = Course.find(params[:id])
    respond_with @course
  end

  def update
    @course.update_attributes(course_params)

    enroll_service = ::Courses::EnrollService.new(@course,
                                           students: student_uids,
                                           tutors: tutor_uids,
                                           convenors: convenor_uids)

    enroll_service.execute
    generate_flash_for_enrollment(enroll_service)

    ::Courses::AssignmentService.new(@course).execute

    respond_with @course
  end

  def show
  end

  def destroy
    @course.destroy
    respond_with @course
  end
  
  def groups
    @groups = @course.groups
  end
  
  private

  def generate_flash_for_enrollment(service)
    [:convenors, :students, :tutors].each do |type|
      service.errors[type].each do |id|
        flash_message :error, "The #{type.to_s.singularize} <#{id}> could not be found on the LDAP server."
      end

      count = service.success_count[:type]
      flash_message :success, "Sucessfully enrolled #{count} #{type}." unless count == 0
    end
  end

  def course_id
    params.require(:id)
  end

  def set_course
    @course = Course.find(course_id)
  end

  def require_part_of_course
    unless @course.users.include?(current_user)
      flash_message :error, "You don't have permission to access that."
      redirect_to root_path
    end
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
