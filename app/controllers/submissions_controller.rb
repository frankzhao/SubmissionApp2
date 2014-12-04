class SubmissionsController < ApplicationController
  before_filter :require_logged_in
  respond_to :html

  def new
    @submission = Submission.new
    @assignment = Assignment.find(params[:assignment_id])
    @course = @assignment.course
    if @assignment.kind == "plaintext"
      render 'new_plaintext'
    elsif @assignment.kind = "zip"
      render 'new_zip'
    end
  end

  def create
  end

  def edit
  end

  def show
  end

  def index
  end

  def destroy
  end
end
