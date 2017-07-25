module Logs
  class RetrieveService
    def execute
      log = ::File.join(::Rails.root, "log", "#{::Rails.env}.log")
      `tail -100 #{ log }`.split(/\n/).reverse
    end
  end
end