module CompileCustom
  # Custom compilation module
  # Compiles using a custom command
  
  module_function
  def run(submission, tests)
    comments = ""
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
    folder = "#{Rails.root}/tmp/compilations/#{hash}"
    `mkdir -p #{folder}`
    
    command = submission.assignment.custom_command
    command = command.gsub("$folder","#{folder}")
    command = command.gsub("$filepath","#{folder}/#{hash}.sub")
    command = command.gsub("$uid", submission.user.uid)

    if submission.kind == "plaintext"
      command = command.gsub("$filename","#{hash}.sub")
      # Write file
      File.open("#{folder}/#{hash}.sub","w") { |f| f.write(submission.plaintext.gsub("\r\n","\n").gsub("\r","\n")) }
    elsif submission.kind == "zipfile"
      command = command.gsub("$filename", submission.zipfile_path.split("/").last)
      unzip(submission.zipfile_path, folder)
    end
    
    # Compile
    timeout = submission.assignment.timeout ? submission.assignment.timeout.to_s : "3"
    result = `timeout #{timeout} bash -c \'#{command} 2>&1\'`

    comments += "#{result}"
    
    if result.downcase.include?("all tests passed")
      comments += "<span class=\"glyphicon glyphicon-star good\"></span><span class=\"good\">All tests passed. Well done!</span>"
    else
      comments += "</span><span class=\"warn\">Your submission did not pass all test cases. Please try again.</span>"
    end
    
    testresult = TestResult.create(submission_id: submission.id, result: comments)
    
    # Clean up files
    `rm -rf #{folder} 2>/dev/null`
  end
end