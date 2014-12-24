class AssignmentExtensionsController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convenor_or_admin
  
  def new
    @assignment = Assignment.find(params[:assignment_id])
    @assignment_extension = AssignmentExtension.new
  end
  
  def create
    student = User.find_by_uid(params[:uid])
    
    # Parse due date
    due_date = Chronic.parse(params[:assignment_extension][:due_date])
    assignment = Assignment.find(params[:assignment_id])
    if !due_date
      flash_message :error, "Incorrect format for due date."
      redirect_to "/assignments/#{assignment.id}/extensions/new"
    end
    
    AssignmentExtension.create(
      assignment_id: params[:assignment_id],
      due_date: due_date,
      user_id: student.id
    )
    
    redirect_to assignment_path(params[:assignment_id])
  end

  def destroy
    @assignment_extension = AssignmentExtension.find(params[:id])
    @assignment_extension.destroy
    
    redirect_to assignment_path(@assignment_extension.assignment)
  end
end
