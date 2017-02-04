class CommentsController < ApplicationController
  before_action :require_logged_in

  def create
    submission = Submission.find(params[:comment][:submission_id])
    comment = Comment.create(
      submission_id: submission.id,
      text: params[:comment][:text],
      user_id: params[:comment][:user_id],
      hidden: params[:comment][:hidden],
      visible: !!!(params[:comment][:hidden])
    )
    assignment = submission.assignment
    
    # file uploads
    if params[:comment][:attachment]
      comment.attachment = params[:comment][:attachment]
      comment.save!
    end
    
    if params[:comment][:no_redirect]
      if params[:comment][:no_redirect].to_bool
        redirect_to :back
      end
    else
      redirect_to submission_path(submission)
    end
    
    unless !comment.visible
      Notification.create_and_distribute("New comment on your submission for: " + assignment.name, submission_path(submission), [submission.user])
    end  
  end

  def destroy
    comment = Comment.find(params[:id])
    submission = Submission.find(comment.submission_id)
    comment.destroy
    redirect_to submission_path(submission)
  end

end
