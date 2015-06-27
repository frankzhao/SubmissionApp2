module CompileAda
  module_function
  def run(submission, tests)
    comments = ""
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")

    # Write the submission
    folder = "#{Rails.root}/tmp/compilations"
    libraries = "#{Rails.root}/Library/Ada"

    `mkdir -p #{folder}`
    submission_contents = submission.plaintext.gsub("\r\n","\n").gsub("\r","\n")
    File.open("#{folder}/#{hash}.adb","w") { |f| f.write(submission_contents) }
    
    command = "gnatmake #{folder}/#{hash}.adb -aI#{libraries} -aO#{libraries} -D #{folder} -o #{folder}/#{hash} 2>&1"
    gnat_result = `#{command}`
    
    result = File.exist?("#{folder}/#{hash}")

    if result
      comments += "<span class=\"glyphicon glyphicon-ok good\"></span><span class=\"good\">Your submission compiled successfully.</span>\n\n"
    else
      comments += "<span class=\"warn\">Your submission did not compile successfully.</span>\n\n#{gnat_result}"
    end
    
    if result && !tests.empty?
      comments += "Running tests...\n<ol>"
      
      for test in tests
        command = "timeout 3 #{folder}/#{hash} #{test} 2>&1"
        gnat_result = `#{command}`
        comments += "<li>" + test.strip + ": " + gnat_result.strip + "</li>"
      end
      comments += "</ol>"
    else
      command = "timeout 3 #{folder}/#{hash} #{test} 2>&1"
      gnat_result = `#{command}`
      comments += "Program output: " + gnat_result.strip
    end
    
    testresult = TestResult.create(submission_id: submission.id, result: comments)
    
    # clean up files
    `rm #{folder}/#{hash}* 2>/dev/null`
  end
end