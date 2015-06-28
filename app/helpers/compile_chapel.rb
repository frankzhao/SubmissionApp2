module CompileChapel
  # Chapel compilation module
  
  module_function
  def run(submission, tests)
    comments = ""
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")

    # Write the submission
    folder = "#{Rails.root}/tmp/compilations"
    libraries = "#{Rails.root}/Library/Chapel"

    `mkdir -p #{folder}`
    submission_contents = submission.plaintext.gsub("\r\n","\n").gsub("\r","\n")
    File.open("#{folder}/#{hash}.chpl","w") { |f| f.write(submission_contents) }
    
    command = "chpl -o #{folder}/#{hash} #{folder}/#{hash}.chpl 2>&1"
    chpl_result = `#{command}`
    
    result = File.exist?("#{folder}/#{hash}")

    if result
      comments += "<span class=\"glyphicon glyphicon-ok good\"></span><span class=\"good\">Your submission compiled successfully.</span>\n\n"
    else
      comments += "<span class=\"warn\">Your submission did not compile successfully.</span>\n\n#{gnat_result}"
    end
    
    comments += "Running tests...\n"
    
    command = "timeout 3 #{folder}/#{hash} 2>&1"
    chpl_result = `#{command}`
    comments += chpl_result.strip
    
    testresult = TestResult.create(submission_id: submission.id, result: comments)
    
    # clean up files
    `rm #{folder}/#{hash}* 2>/dev/null`
  end
end