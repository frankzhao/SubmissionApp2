module CompileAda
  # Ada compilation module
  # Unit tests can be specified with the "shouldbe" keyword
  # e.g "commandline_param shouldbe 6"
  
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
    
    # Parse the tests
    test_array = []
    for test in tests
      test_array << test.split("shouldbe").map(&:strip)
    end
    
    score = 0
    if result && !tests.empty?
      comments += "Running tests...\n<ol>"
      
      for test in test_array
        command = "timeout 3 #{folder}/#{hash} #{test.first} 2>&1"
        gnat_result = `#{command}`
        comments += "<li>" + test.first + ": " + gnat_result.strip + "</li>"
        
        # Score
        if test.last.strip == gnat_result.strip
          score = score + 1
        end
      end
      comments += "</ol>"
      comments += "Your submission passed #{score}/#{test_array.length} tests.\n"
      
      if score == test_array.length
        comments += "<span class=\"glyphicon glyphicon-star good\"></span><span class=\"good\">All tests passed. Well done!</span>"
      else
        comments += "</span><span class=\"warn\">Your submission did not pass all test cases. Please try again.</span>"
      end
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