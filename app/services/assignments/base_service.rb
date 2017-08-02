module Assignments
  class BaseService
    def initialize(course, opts = {})
      @course = course
      @opts = opts
    end
  end
end