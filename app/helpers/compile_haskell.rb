module CompileHaskell
  def run(submission, tests)
    comments = ""
    score = 0
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
    # write file
    folder = "#{Rails.root}/tmp/compilations"
    libraries = "#{Rails.root}/Library"
    
    `mkdir -p #{folder}`
    File.open("#{folder}/#{hash}.hs","w") { |f| f.write(submission.plaintext + "\nmain = undefined\n") }
    
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
        command = "timeout 3 ghc -i.:#{libraries}" + " -XSafe #{folder}/#{hash}.hs 2>&1 -e " +
                  "\"#{test.gsub('"','\"')}\""
        ghc_result = `#{command}`
        comments += "<li>" + test + ": " + ghc_result + "</li>"
        
        # Score
        if ghc_result == "True"
          score += 1
        end
      end
      comments += "</ol>"
      comments += "Your submission passed #{score}/#{tests.length} tests.\n"
      
      if score == tests.length
        comments += "<span class=\"glyphicon glyphicon-star good\"><span class=\"good\">All tests passed. Well done!</span>"
      else
        comments += "</span><span class=\"warn\">Your submission did not pass all test cases. Please try again.</span>"
      end
    end
    
    testresult = TestResult.create(submission_id: submission.id, result: comments)
    
    # clean up files
    `rm #{folder}/#{hash}.o`
    `rm #{folder}/#{hash}.hi`
    `rm #{folder}/#{hash}.hs`
    `rm #{folder}/#{hash}`
  end
end