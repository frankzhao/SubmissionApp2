module Ldap
  class SanitizeService < BaseService
    def execute
      @uid.gsub(/\r/, '').gsub(/^$\n/, '')
    end
  end
end