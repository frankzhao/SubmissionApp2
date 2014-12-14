module CompileHaskell
  def run(submission, tests)
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
    # write file
    folder = "#{Rails.root}/tmp/compilations"
    `mkdir -p #{folder}`
    File.open("#{folder}/#{hash}.hs","w") { |f| f.write(submission.plaintext + "\nmain = undefined\n") }
    
    # check compilation, include files in /Library
    command = "ghc -XSafe #{folder}/#{hash}.hs -i.:#{Rails.root}/Library 2>&1"
    result = `#{command}`
    result = result.split(/\n/)[3..-1]
    # run tests
  end
end