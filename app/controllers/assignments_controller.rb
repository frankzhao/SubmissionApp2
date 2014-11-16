class AssignmentsController < ApplicationController
  def new
    if params[:course_id] && Course.find_by_id(params[:course_id])
      @course = Course.find_by_id(params[:course_id])
    else
      flash_message :error, "The course with ID=" + params[:course_id].to_s + " was not found."
      redirect_to '/courses'
    end
  end

  def create
  logmsg params.to_s

    course = params[:course_id]
    name = params[:assignment_name]
    date_due = params[:date_due]
    type = params[:type]
    text = params[:text]

    # Parse due date
    if date_due
      begin
        date_due = DateTime.strptime(date_due, '%d/%m/%Y %H:%M')
      rescue ArgumentError
        flash_message :error, "Incorrect format for due date."
      end
    end

    if name
      assignment = Assignment.create(:name => name, :due_date => date_due,
                                     :description => text, :kind => type)
    else
    end

    if course && assignment && Course.find_by_id(course)
      # Add assignment to the course
      Course.find_by_id(course).assignments << assignment
    else
      flash_message :error, "Could not find course with ID=" + course.to_s
    end

    redirect_to '/courses/' + course.to_s
  end

  def edit
  end

  def show
    if params[:id] && Assignment.find_by_id(params[:id])
      @assignment = Assignment.find_by_id(params[:id])
      @course = @assignment.course
      @submissions = current_user.submissions_for_assignment(@assignment)
    else
      flash_message :error, "Could not find assignment with ID=" + params[:id]
      redirect_to '/'
    end
  end

  def index
  end

  def destroy
  end
end
