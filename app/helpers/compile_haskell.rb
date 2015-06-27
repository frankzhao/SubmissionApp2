module CompileHaskell
  module_function
  def run(submission, tests)
    comments = ""
    score = 0
    #hash = (0...8).map { (65 + rand(26)).chr }.join
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
    # write file
    folder = "#{Rails.root}/tmp/compilations"
    libraries = "#{Rails.root}/Library/Haskell"
    
    `mkdir -p #{folder}`
    File.open("#{folder}/#{hash}.hs","w") { |f| f.write(submission.plaintext.gsub("\r\n","\n").gsub("\r","\n") + "\nmain = undefined\n") }
    
    # check compilation, include files in /Library
    command = "ghc -XSafe #{folder}/#{hash}.hs -i.:#{libraries} 2>&1"
    ghc_result = `#{command}`

    result = File.exist?("#{folder}/#{hash}")
    
    if result
      comments += "<span class=\"glyphicon glyphicon-ok good\"></span><span class=\"good\">Your submission compiled successfully.</span>\n\n"
    else
      comments += "<span class=\"warn\">Your submission did not compile successfully.</span>\n\n#{ghc_result}"
    end
    
    # run tests
    if result && !tests.nil?
      comments += "Running tests...\n<ol>"
      for test in tests
        command = "timeout 3 ghc -i.:#{libraries}" + " #{folder}/#{hash}.hs 2>&1 -e " + "\"#{test.gsub('"','\"')}\""
        ghc_result = `#{command}`
        comments += "<li>" + test.strip + ": " + ghc_result.strip + "</li>"

        # Score
        if ghc_result.strip == "True"
          score += 1
        end
      end
      comments += "</ol>"
      comments += "Your submission passed #{score}/#{tests.length} tests.\n"
      
      if score == tests.length
        comments += "<span class=\"glyphicon glyphicon-star good\"></span><span class=\"good\">All tests passed. Well done!</span>"
      else
        comments += "</span><span class=\"warn\">Your submission did not pass all test cases. Please try again.</span>"
      end
    end
    
    testresult = TestResult.create(submission_id: submission.id, result: comments)
    
    # clean up files
    `rm #{folder}/#{hash}* 2>/dev/null`
  end
end