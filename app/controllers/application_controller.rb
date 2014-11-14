class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_paramaters, if: :devise_controller?
  
  protected

  # Sign in and sign out paths
  def after_sign_in_path_for(resource)
    # go to course list
    '/courses'
  end

  def after_sign_out_path_for(resource)
    # go to sign in page
    'devise/sessions#new'
  end

  def configure_devise_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:uid, :password)}
  end

  def configure_permitted_paramaters
    devise_parameter_sanitizer.for(:sign_in) {|u| u.permit(:uid, :password, :remember_me)}
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:uid, :password)}
  end
end
