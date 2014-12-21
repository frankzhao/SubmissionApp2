module CompileHaskell
  def run(submission, tests)
    comments = ""
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
      comments += "Your submission compiled successfully.\n"
    else
      comments += "Your submission did not compile successfully. \n#{ghc_result}"
    end
    
    # run tests
    if result
      for test in tests
        command = "timeout 3 ghc -i.:#{libraries}" + " -XSafe #{folder}/#{hash}.hs 2>&1 -e " +
                  "\"#{test.gsub('"','\"')}\""
        ghc_result = `command`
        comment += test + ": " + ghc_result
      end
    end
    
    # clean up files
    `rm #{folder}/#{hash}.o`
    `rm #{folder}/#{hash}.hi`
    `rm #{folder}/#{hash}.hs`
    `rm #{folder}/#{hash}`
    
    jfjfjf
  end
end