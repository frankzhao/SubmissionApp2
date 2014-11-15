class LdapController < ApplicationController
  def query
   render :json => AnuLdap.find_by_uni_id(params[:uid])
  end
end
