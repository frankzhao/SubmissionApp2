module Convenor
  class EnrollService < BaseService
    def execute
      ldap_user = ::Ldap::LookupService.new(@uid).execute

      if ldap_user
        ::Convenor.create!(uid: @uid, firstname: ldap_user[:given_name], surname: ldap_user[:surname])
      end
    end
  end
end