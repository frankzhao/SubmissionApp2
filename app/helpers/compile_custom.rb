module CompileCustom
  # Custom compilation module
  # Compiles using a custom command
  
  module_function
  def run(submission, tests)
    if submission.kind == "plaintext"
      comments = ""
      hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
      
      # Write file
      folder = "#{Rails.root}/tmp/compilations/#{hash}"
      `mkdir -p #{folder}`
      File.open("#{folder}/#{hash}.sub","w") { |f| f.write(submission.plaintext.gsub("\r\n","\n").gsub("\r","\n")) }
      
      # Compile
      command = submission.assignment.custom_command.gsub("$filename","#{hash}.sub")
      result = `timeout 3 #{command} 2>&1`
      
      comments += "#{result}"
      
      testresult = TestResult.create(submission_id: submission.id, result: comments)
    
      # clean up files
      `rm #{folder}/#{hash}* 2>/dev/null`
    elsif submission.kind == "zip"
      # TODO
    end
  end
end