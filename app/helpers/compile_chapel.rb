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
        chpl_result = `#{command}`
        comments += "<li>" + test.first + ": " + chpl_result.strip + "</li>"
        
        # Score
        if test.last.strip == chpl_result.strip
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
      chpl_result = `#{command}`
      comments += "Program output: " + chpl_result.strip
    end
    
    testresult = TestResult.create(submission_id: submission.id, result: comments)
    
    # clean up files
    `rm #{folder}/#{hash}* 2>/dev/null`
  end
end