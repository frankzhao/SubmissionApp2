class SubmissionsController < ApplicationController
  before_filter :require_logged_in
  respond_to :html

  def new
    @submission = Submission.new
    @assignment = Assignment.find(params[:assignment_id])
    @most_recent_submission = current_user.recent_submission_for(@assignment)
    @course = @assignment.course
    if @assignment.kind == "plaintext"
      render 'new_plaintext'
    elsif @assignment.kind = "zip"
      render 'new_zip'
    end
  end

  def create
    @submission = Submission.new(kind: "plaintext", plaintext: params[:plaintext])
    current_user.submissions << @submission
    @submission.user = current_user
    @assignment = Assignment.find(params[:assignment_id])
    @assignment.submissions << @submission
    @submission.assignment = @assignment
    redirect_to assignment_path(@assignment)
  end

  def edit
  end

  def show
    @submission = Submission.find(params[:id])
    @assignment = @submission.assignment
  end

  def index
  end

  def destroy
  end
end
