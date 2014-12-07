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