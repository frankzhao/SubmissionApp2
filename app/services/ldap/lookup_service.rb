module Ldap
  class LookupService < BaseService
    def execute
      @uid = SanitizeService.new(@uid).execute

      ::AnuLdap.find_all_by_uni_id(@uid).flatten
    end
  end
end