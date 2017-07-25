module Ldap
  class SanitizeService < BaseService
    def execute
      @uid.gsub(/\r/, '').gsub(/^$\n/, '').split(/\n/).reject(&:empty?)
    end
  end
end