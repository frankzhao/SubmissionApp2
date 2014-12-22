class AssignmentsController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convenor_or_admin, :only => [:new, :create, :destroy, :edit]

  def new
    @assignment = Assignment.new
    if params[:course_id] && Course.find_by_id(params[:course_id])
      @course = Course.find_by_id(params[:course_id])
    else
      flash_message :error, "The course with ID=" + params[:course_id].to_s + " was not found."
      redirect_to courses_url
    end
  end

  def create
    course = params[:course_id]
    name = params[:assignment_name]
    date_due = params[:date_due]
    type = params[:type]
    text = params[:text]
    tests = params[:tests]

    if course && Course.find_by_id(course)
      c = Course.find_by_id(course)
      assignment = Assignment.create(:name => name, :due_date => date_due,
                                   :description => text, :kind => type, :tests => tests)
      # Add assignment to the course
      Course.find(course).assignments << assignment
      
      # Distribute and notify assignment to users in the course
      notification = Notification.create_and_distribute("New assignment: " + assignment.name, assignment_path(assignment), c.users)
      for u in c.users
        u.assignments << assignment
      end
    else
      flash_message :error, "Could not find course with ID=" + course.to_s
    end

    # Parse due date
    date_due = Chronic.parse(date_due)
    if !date_due
      flash_message :error, "Incorrect format for due date."
      redirect_to "/assignments/new/#{c.id}"
    end

    redirect_to course_path(course)
  end

  def edit
    @assignment = Assignment.find(params[:id])
    @course = @assignment.course
  end
  
  def update
    @assignment = Assignment.find(params[:id])
    @assignment.update_attributes(
      :name => params[:assignment_name],
      :due_date => DateTime.strptime(params[:date_due], '%d/%m/%Y %H:%M'),
      :kind => params[:assignment][:kind],
      :description => params[:text],
      :tests => params[:tests]
    )
    
    redirect_to assignment_path(@assignment)
  end

  def show
    if params[:id] && Assignment.find_by_id(params[:id])
      @assignment = Assignment.find_by_id(params[:id])
      @course = @assignment.course
      @submissions = current_user.submissions_for(@assignment)
    else
      flash_message :error, "Could not find assignment with ID=" + params[:id]
      redirect_to '/'
    end
  end

  def index
    if current_user.is_admin?
      @assignments = Assignment.all
    else
      @assignments = current_user.assignments
    end
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy
    
    redirect_to '/courses'
  end
  
  def data
    assignment = Assignment.find(params[:id])
    data = assignment.submissions.group("strftime('%Y%m%d %H', created_at)").count
    render :json => {data: data}
  end
  
  # Assignment group views
  def groups
    @assignment = Assignment.find(params[:assignment_id])
    @group = Group.find(params[:group_id])
    @submissions = @assignment.submissions.select{
      |s| s.user.type == "Student" && @group.students.include?(s.user)
    }
    @comment = Comment.new
    
    render 'group_assignment'
  end
end
