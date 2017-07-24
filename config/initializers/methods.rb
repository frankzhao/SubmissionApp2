require 'zip'

def logmsg(str)
  puts "=== " + str + " ==="
end

def sanitize_str(str)
  str = str.to_s.strip
  str = str.gsub(/\^.*(\\|\/)/, '') # remove slashes etc
  str = str.gsub(/[^0-9A-Za-z.\-]/, '_') # remove non-ascii
  return str
end

class String
  def to_bool
    return true if self =~ (/^(true|t|yes|y|1)$/i)
    return false if self.empty? || self =~ (/^(false|f|no|n|0)$/i)

    raise ArgumentError.new "invalid value: #{self}"
  end
end

class Regexp
  def +(regex)
    Regexp.new self.to_s + regex.to_s
  end
end

def unzip(file, dest)
  Zip::File.open(file) do |zip_file|
   zip_file.each do |f|
     path = File.join(dest, f.name)
     FileUtils.mkdir_p(File.dirname(path))
     zip_file.extract(f, path) unless File.exist?(path)
   end
 end
end

def unzip_to_hash(file, blacklist)
  filehash = {}
  Zip::File.open(file) do |zip_file|
   zip_file.each do |f|
     unless f.directory? || f.symlink?
       if (f.name !~ /MACOSX|DS_Store/) && (f.name !~ blacklist)
         contents = f.get_input_stream.read
         filehash[f.name] = contents
       end
     end
   end
 end
 
 return filehash
end