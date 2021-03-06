class ApplicationController < ActionController::Base
  include AuthenticationHelper
  include FlashHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :configure_permitted_paramaters, if: :devise_controller?
  
  def after_sign_in_path_for(resource)
    root_path
  end
  
  protected

  def configure_devise_params
    devise_parameter_sanitizer.permit(:sign_up) {|u| u.permit(:uid, :password)}
  end

  def configure_permitted_paramaters
    devise_parameter_sanitizer.permit(:sign_in) {|u| u.permit(:uid, :password, :remember_me)}
    devise_parameter_sanitizer.permit(:sign_up) {|u| u.permit(:uid, :password)}
  end
end
