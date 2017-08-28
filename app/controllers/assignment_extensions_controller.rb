class AssignmentExtensionsController < ApplicationController
  before_action :require_logged_in
  before_action :require_convenor_or_admin
  before_action :set_assignment, except: [:destroy]
  
  def new
    @assignment_extension = AssignmentExtension.new
  end
  
  def create
    student = User.find_by_uid(params[:uid])
    
    # Parse due date
    due_date = Chronic.parse(params[:assignment_extension][:due_date], :endian_precedence => [:little, :median])

    unless due_date
      flash_message :error, "Incorrect format for due date."
      return redirect_to new_assignment_extension_path(assignment.id)
    end
    
    AssignmentExtension.create(
      assignment: @assignment,
      due_date: due_date,
      user_id: student.id
    )
    
    # Notify
    Notification.create_and_distribute("You have been granted an extension for #{@assignment.name} until #{due_date.strftime('%d/%m/%Y %I:%M%p')}", assignment_path(@assignment), [student])
    
    redirect_to assignment_path(@assignment)
  end

  def destroy
    @assignment_extension = AssignmentExtension.find(params[:id])
    @assignment_extension.destroy
    
    redirect_to assignment_path(@assignment_extension.assignment)
  end

  private

  def set_assignment
    @assignment = Assignment.find(assignment_id)
  end

  def assignment_id
    params.require(:assignment_id)
  end
end
