require "anu-ldap"

module ApplicationHelper
  def require_logged_in
    unless current_user
      flash[:errors] = ["You don't have permission to access that page."]
      redirect_to root_path
    end
  end
  
  def require_convenor_or_admin
    unless current_user.is_admin_or_convenor?
      flash[:errors] = ["You have to be a convener or admin to see that."]
      redirect_to root_path
    end
  end

  def require_admin
    unless current_user.is_admin?
      flash[:errors] = ["You have to be an admin to see that. This incident will be reported."]
      redirect_to root_path
    end
  end
  
  def require_staff
    unless current_user.is_staff?
      flash[:errors] = ["You don't have permission to access that."]
      redirect_to root_path
    end
  end
  
  def require_owner(resource)
    unless resource.user == current_user
      flash[:errors] = ["You don't have permission to access that."]
      redirect_to root_path
    end
  end
  
  def require_owner_or_staff(resource)
    unless (resource.user == current_user) || current_user.is_staff?
      flash[:errors] = ["You don't have permission to access that."]
      redirect_to root_path
    end
  end
  
  def require_submission_privileges(resource)
    unless (resource.peer_review_user_id == current_user.id) || ((resource.user == current_user) || current_user.is_staff?)
      flash[:errors] = ["You don't have permission to access that."]
      redirect_to root_path
    end
  end

  def url_prefix
    if ENV['RAILS_RELATIVE_URL_ROOT'].strip == '/'
      ''
    else
      ENV['RAILS_RELATIVE_URL_ROOT'].strip
    end
  end
  
  # Group assignment views
  def group_assignment_path(group, assignment)
    url_prefix + "/assignments/#{assignment.id}/group/#{group.id}"
  end

  # Multiple flash messages
  def flash_message(type, text)
    flash[type] ||= []
    flash[type] << text
  end

  def flash_errors
    flashes = []
    flash.each do |type, messages|
      if messages.is_a?(String)
        flashes << render(partial: 'layouts/flash',
          locals: {:type => type, :message => messages})
      else
        messages.each do |m|
          flashes << render(partial: 'layouts/flash',
            locals: {:type => type, :message => m}) unless m.blank?
        end
      end
    end
    flashes.join('').html_safe
  end

  def title(page_title)
    content_for :title, page_title.to_s + " | SubmissionApp2"
  end
end
