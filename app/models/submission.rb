class Submission < ApplicationRecord
  belongs_to :assignment
  belongs_to :user
  has_many :comments
  has_one :test_result
  
  SUPPORTED_TYPES = ["plaintext","zip"]
  
  def zipfile_path
    file_path + ".zip"
  end
  
  def plaintext_path
    file_path + ".txt"
  end
  
  def submission_path
    user = self.user
    id = self.id
    timestamp = self.created_at
    Rails.root.to_s + "/public/uploads/#{sanitize_str(assignment.name)}"
  end
  
  def file_path
    user = self.user
    id = self.id
    timestamp = self.created_at
    Rails.root.to_s + "/public/uploads/#{sanitize_str(assignment.name)}/" +
      self.pretty_filename
  end
  
  def pretty_filename
    user = self.user
    id = self.id
    timestamp = self.created_at
    user.uid + "_" +
    sanitize_str(user.full_name) + "_" +
    sanitize_str(assignment.name) + "_" +
    sanitize_str(id) + "_" +
    sanitize_str(timestamp)
  end
  
  def plaintext
    read_attribute(:plaintext).force_encoding("UTF-8")
  end
  
  def peer_reviewed?
    return false unless !self.peer_review_user_id.nil?
    user = User.find(self.peer_review_user_id)
    !self.comments.select{|c| c.user ==  user}.empty?
  end
  
  def reviewed_by?(user)
    !self.comments.select{|c| c.user ==  user}.empty?
  end
  
  def comments_by(user)
    self.comments.select{|c| c.user ==  user}
  end
  
  # Compilation tests ---
  def compile_haskell
    if self.assignment.tests
      tests = self.assignment.tests.split("\n")
    end

    CompileHaskell.run(self, tests)
  end
  handle_asynchronously :compile_haskell, :run_at => Proc.new { Time.now }
  
  def compile_ada
    if self.assignment.tests
      tests = self.assignment.tests
      tests = tests.split("\n")
    end
    
    CompileAda.run(self, tests)
  end
  handle_asynchronously :compile_ada, :run_at => Proc.new { Time.now }
  
  def compile_chapel
    if self.assignment.tests
      tests = self.assignment.tests
      tests = tests.split("\n")
    end
    
    CompileChapel.run(self, tests)
  end
  handle_asynchronously :compile_chapel, :run_at => Proc.new { Time.now }
  
  def compile_arm_gnu
    CompileArmGnu.run(self, tests)
  end
  handle_asynchronously :compile_arm_gnu, :run_at => Proc.new { Time.now }
  
  def compile_custom
    tests = nil
    CompileCustom.run(self, tests)
  end
  handle_asynchronously :compile_custom, :run_at => Proc.new { Time.now }
  
  # PDF and other output formats ---
  
  def make_pdf
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
    system "mkdir -p /tmp/pdf/#{hash}"
    count = 0
    
    regex = self.assignment.pdf_regex
    if regex.nil?
      regex = Regexp.new("^$")
    else
      regex = Regexp.new(regex)
    end
    
    if self.kind == "zipfile"
      puts "Creating PDF of ZIP submission"
      begin
        Zip::File.open(self.zipfile_path) do |zipfile|
          for file in zipfile.sort
            if (file.name =~ /\/\./ || file.name =~ /MACOSX|DS_Store/) || file.name =~ Regexp.new(regex)
              puts "Skipping: " + file.name
              next
            end
            count = count + 1
            if file.name =~ /pdf/
              File.open("/tmp/pdf/#{hash}/#{count}.pdf", "wb") do |f|
                f.write(file.get_input_stream.read)
              end
            else
              if file.file?
                escaped_body = file.get_input_stream.read
                escaped_body = escaped_body.force_encoding('UTF-8').scrub('?')
                File.open("/tmp/pdf/#{hash}/#{count}.tex", "w") do |f|
                  f.write <<-FILE
\\nonstopmode
\\documentclass[a4paper, 8pt]{article}
\\usepackage[usenames]{color}
\\usepackage{hyperref}
\\usepackage{listings}
\\lstset{breaklines=true}
\\lstset{numbers=left, numberstyle=\\scriptsize\\ttfamily, numbersep=10pt, captionpos=b}
\\lstset{basicstyle=\\small\\ttfamily}
\\lstset{framesep=4pt}
\\oddsidemargin 0in
\\textwidth 6in
\\topmargin -0.5in
\\textheight 9in
\\columnsep 0.25in
\\newsavebox{\\spaceb}
\\newsavebox{\\tabb}
\\savebox{\\spaceb}[1ex]{~}
\\savebox{\\tabb}[4ex]{~}
\\newcommand{\\hsspace}{\\usebox{\\spaceb}}
\\newcommand{\\hstab}{\\usebox{\\tabb}}
\\newcommand{\\conceal}[1]{}
\\begin{document}
\\textbf{#{file.name.gsub(/(?<foo>[$%_\\])/, '\\\\\k<foo>')}}\\\\
\\textbf{#{self.user.full_name.strip}}\ \ \\textbf{#{self.user.uid}}
\\begin{lstlisting}
#{escaped_body}
\\end{lstlisting}
\\end{document}
FILE
                end
                system("pdflatex -output-directory=/tmp/pdf/#{hash} /tmp/pdf/#{hash}/#{count}.tex")
              end
            end
          end
        end
      rescue
        puts "Error opening zip file - Submission ID: #{self.id}"
      end
    elsif kind == "plaintext"
      File.open(self.plaintext_path, 'r') do |file|
        escaped_body = file.read
        File.open("/tmp/pdf/#{hash}/#{hash}.tex", "wb") do |f|
          f.write <<-FILE
\\nonstopmode
\\documentclass[a4paper, 8pt]{article}
\\usepackage[usenames]{color}
\\usepackage{hyperref}
\\usepackage{listings}
\\lstset{breaklines=true}
\\lstset{numbers=left, numberstyle=\\scriptsize\\ttfamily, numbersep=10pt, captionpos=b}
\\lstset{basicstyle=\\small\\ttfamily}
\\lstset{framesep=4pt}
\\oddsidemargin 0in
\\textwidth 6in
\\topmargin -0.5in
\\textheight 9in
\\columnsep 0.25in
\\newsavebox{\\spaceb}
\\newsavebox{\\tabb}
\\savebox{\\spaceb}[1ex]{~}
\\savebox{\\tabb}[4ex]{~}
\\newcommand{\\hsspace}{\\usebox{\\spaceb}}
\\newcommand{\\hstab}{\\usebox{\\tabb}}
\\newcommand{\\conceal}[1]{}
\\begin{document}
\\textbf{#{self.pretty_filename.gsub(/(?<foo>[$%_\\])/, '\\\\\k<foo>')}}\\\\
\\textbf{#{self.user.full_name.strip}}\ \ \\textbf{#{self.user.uid}}
\\begin{lstlisting}
#{escaped_body}
\\end{lstlisting}
\\end{document}
FILE
        end
        system("pdflatex -output-directory=/tmp/pdf/#{hash} /tmp/pdf/#{hash}/#{hash}.tex")
      end
    end

    #files_string = "/tmp/pdf/#{hash}/*.pdf"
    files_list = `ls /tmp/pdf/#{hash}/*.pdf`
    files_string = files_list.split("\n").sort_by { |x| x[/\d+\.pdf/].to_i }.join(" ")
    `echo \"#{files_string}\" > /Users/frank/Desktop/test.txt`
    system("gs -q -sPAPERSIZE=a4 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=/tmp/pdf/#{self.pretty_filename}.pdf #{files_string}")
    "/tmp/pdf/#{hash}/#{self.pretty_filename}.pdf"
    system("rm -rf /tmp/pdf/#{hash}")
    return "/tmp/pdf/#{self.pretty_filename}.pdf"
  end
  
  def make_pdf_with_comments
    hash = Digest::SHA1.hexdigest("#{rand(10000)}#{Time.now}")
    system "mkdir -p /tmp/pdf/#{hash}"
    count = 0
    if kind == "plaintext"
      File.open(self.plaintext_path, 'r') do |file|
        escaped_body = file.read
        File.open("/tmp/pdf/#{hash}/#{hash}.tex", "wb") do |f|
          f.write <<-FILE
\\nonstopmode
\\documentclass[a4paper, 8pt]{article}
\\usepackage[usenames]{color}
\\usepackage{hyperref}
\\usepackage{listings}
\\lstset{breaklines=true}
\\lstset{numbers=left, numberstyle=\\scriptsize\\ttfamily, numbersep=10pt, captionpos=b}
\\lstset{basicstyle=\\small\\ttfamily}
\\lstset{framesep=4pt}
\\oddsidemargin 0in
\\textwidth 6in
\\topmargin -0.5in
\\textheight 9in
\\columnsep 0.25in
\\newsavebox{\\spaceb}
\\newsavebox{\\tabb}
\\savebox{\\spaceb}[1ex]{~}
\\savebox{\\tabb}[4ex]{~}
\\newcommand{\\hsspace}{\\usebox{\\spaceb}}
\\newcommand{\\hstab}{\\usebox{\\tabb}}
\\newcommand{\\conceal}[1]{}
\\begin{document}
\\textbf{#{self.pretty_filename.gsub(/(?<foo>[$%_\\])/, '\\\\\k<foo>')}}\\\\
\\textbf{#{self.user.full_name.strip}}\ \ \\textbf{#{self.user.uid}}
\\begin{lstlisting}
#{escaped_body}
\\end{lstlisting}
\\end{document}
FILE
        end
        system("pdflatex -output-directory=/tmp/pdf/#{hash} /tmp/pdf/#{hash}/#{hash}.tex")
      end
    end
    
    # Add any attached comments
    if self.comments.present?
      for comment in self.comments
        if comment.attachment.present?
          comment_file = comment.attachment
          if comment_file.file.filename =~ /.pdf$/
            contents = comment_file.read
            File.open("/tmp/pdf/#{hash}/#{comment_file.file.filename}", "wb") do |f|
              f.write(contents)
            end
          end
        end
      end
    end

    #files_string = "/tmp/pdf/#{hash}/*.pdf"
    files_list = `ls /tmp/pdf/#{hash}/*.pdf`
    files_string = files_list.split("\n").sort_by { |x| x[/\d+\.pdf/].to_i }.join(" ")
    `echo \"#{files_string}\" > /Users/frank/Desktop/test.txt`
    system("gs -q -sPAPERSIZE=a4 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=/tmp/pdf/#{self.pretty_filename}.pdf #{files_string}")
    "/tmp/pdf/#{hash}/#{self.pretty_filename}.pdf"
    system("rm -rf /tmp/pdf/#{hash}")
    return "/tmp/pdf/#{self.pretty_filename}.pdf"
  end
  
  private
  
  def to_utf8(str)
    str = str.encode("UTF-8")
    return str if str.valid_encoding?
    str = str.force_encoding("BINARY")
    str.encode("UTF-8", invalid: :replace, undef: :replace)
  end
end
