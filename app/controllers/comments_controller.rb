class CommentsController < ApplicationController
  before_filter :require_logged_in

  def create
    submission = Submission.find(params[:comment][:submission_id])
    comment = Comment.create(
      submission_id: submission.id,
      text: params[:comment][:text],
      user_id: params[:comment][:user_id]
    )
    
    # file uploads
    if params[:comment][:attachment]
      comment.attachment = params[:comment][:attachment]
      comment.save!
    end
    
    redirect_to submission_path(submission)
  end

  def destroy
    comment = Comment.find(params[:id])
    submission = Submission.find(comment.submission_id)
    comment.destroy
    redirect_to submission_path(submission)
  end
end
