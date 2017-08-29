module Convenors
  class EnrollService < BaseService
    def execute
      ldap_user = ::Ldap::LookupService.new(@uid).execute

      if ldap_user
        ::User.create!(uid: @uid, firstname: ldap_user[:given_name], surname: ldap_user[:surname], convenor: true)
      end
    end
  end
end