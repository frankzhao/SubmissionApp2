class AdminController < ApplicationController
  before_action :require_logged_in
  before_action :require_admin

  def index
    @convenors = Convenor.all.includes(:courses)
    @lines = ::Logs::RetrieveService.new.execute
    respond_to do |format|
      format.html{ render }
      format.json{ render(:json => @lines) }
    end
  end
  
  def form
    @convenor = Convenor::EnrollService.new(convenor_id).execute

    unless @convenor
      flash_message :error, "The convenor <#{convenor_id}> could not be found on the LDAP server."
    end

    redirect_to admin_path
  end
  
  def become
    sign_in(:user, User.find_by_uid(params[:id]))
    redirect_to root_url
  end
  
  private

  def convenor_id
    params.require(:convenor).require(:uid)
  end
end
