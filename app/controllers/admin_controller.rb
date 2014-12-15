class AdminController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_admin

  def index
    log = File.join(Rails.root, "log", "#{ Rails.env }.log")
    @lines = `tail -100 #{ log }`.split(/\n/).reverse
    respond_to do |format|
      format.html{ render }
      format.json{ render(:json => @lines) }
    end
  end
  
  def form
    enroll_convenor(params[:convenor][:uid])
    redirect_to '/admin'
  end
  
  private
  
  def enroll_convenor(uid)
    uid = sanitize_uid(uid)
    ldap_user = AnuLdap.find_by_uni_id(uid)
    if !ldap_user.nil?
      conv = Convenor.create(:uid => uid, :firstname => ldap_user[:given_name], :surname => ldap_user[:surname])
      fjfjfs
    else
      flash_message :error, "The convenor <#{uid}> could not be found on the LDAP server."
    end
  end

  def sanitize_uid(str)
    str.gsub(/\r/, '').gsub(/^$\n/, '')
  end
end
