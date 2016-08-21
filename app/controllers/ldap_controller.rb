require 'anu-ldap'
class LdapController < ApplicationController
  def show
    @user = AnuLdap.find_by_uni_id(params[:id])
  end
end
