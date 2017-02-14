module CompileArmGnu
  # Compilation module for the arm-eabi-non-gcc toolchain
  
  module_function
  def run(submission, tests)
    comments = ""
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")

    # Write the submission
    folder = "#{Rails.root}/tmp/compilations"
    libraries = "#{Rails.root}/Library/ARM GNU"

    `mkdir -p #{folder}`
    submission_contents = submission.plaintext.gsub("\r\n","\n").gsub("\r","\n")
    File.open("#{folder}/#{hash}.S","w") { |f| f.write(submission_contents) }
    
    # TODO
    command = "COMPILE COMMAND"
    compile_result = `#{command}`
    
    result = File.exist?("#{folder}/#{hash}")

    if result
      comments += "<span class=\"glyphicon glyphicon-ok good\"></span><span class=\"good\">Your submission compiled successfully.</span>\n\n"
    else
      comments += "<span class=\"warn\">Your submission did not compile successfully.</span>\n\n#{compile_result}"
    end

  end
end