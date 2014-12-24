def logmsg(str)
  puts "=== " + str + " ==="
end

def sanitize_str(str)
  str = str.to_s
  str.strip!
  str.strip!
  str.gsub!(/^.*(\\|\/)/, '') # remove slashes etc
  str.gsub!(/[^0-9A-Za-z.\-]/, '_') # remove non-ascii
  return str
end

class String
  def to_bool
    return true if self =~ (/^(true|t|yes|y|1)$/i)
    return false if self.empty? || self =~ (/^(false|f|no|n|0)$/i)

    raise ArgumentError.new "invalid value: #{self}"
  end
end