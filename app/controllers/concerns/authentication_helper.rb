module AuthenticationHelper
  extend ActiveSupport::Concern

  def require_logged_in
    unless current_user
      flash[:errors] = ["You don't have permission to access that page."]
      redirect_to root_path
    end
  end

  def require_convenor_or_admin
    unless current_user.is_admin_or_convenor?
      flash[:errors] = ["You have to be a convenor or admin to see that."]
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
end