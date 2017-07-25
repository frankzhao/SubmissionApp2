module Ldap
  class BaseService
    def initialize(uid, opts = {})
      @uid = uid
      @opts = opts
    end
  end
end