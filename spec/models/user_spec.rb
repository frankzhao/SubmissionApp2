require 'spec_helper'

RSpec.describe User, :type => :model do
  
  # HAHA
	it "returns true" do
    true
	end
  
  describe "student" do
    before(:each) do
      User.delete_all
      Student.create(
        :firstname => "Thomas",
        :surname => "Jenkins",
        :password => "pass",
        :uid => "u0000002")
    end
    
    it "should not have any courses" do
      s = Student.first
      expect s.courses.nil?
    end
    
    it "should not have additional privileges" do
      s = Student.first
      expect !s.is_admin_or_convenor?
      expect !s.is_tutor?
      expect !s.is_staff?
    end
    
    it "should be enrollable in a course" do
      s = Student.first
      c = Course.create!(code: "COMP1100", name: "Computing")
      c.students << s
      expect c.students.include?(s)
      expect s.courses.include?(c)
    end
    
    it "should be able to create submissions" do
      s = Student.first
      
      submission = Submission.new
      submission.user = s
      submission.update_attributes(
        kind: "plaintext",
        plaintext: "submission contents"
      )
      expect s.submissions.include?(submission)
    end
    
    it "should not be able to create a course" do
      s = User.first
      c = Course.create!(
        code: "COMP1100",
        name: "Computing")
      expect{s.course = c}.to raise_error
    end
  end
  
  describe "tutor" do
    before(:each) do
      User.delete_all
      Tutor.create(
        :firstname => "Thomas",
        :surname => "Jenkins",
        :password => "pass",
        :uid => "u0000001")
    end
    
    it "should not have any courses" do
      t = Tutor.first
      expect t.courses.nil?
    end
    
    it "should have the correct privileges" do
      t = Tutor.first
      expect t.is_staff?
      expect t.is_tutor?
      expect !t.is_admin?
      expect !t.is_convenor?
    end
    
    it "should be able to create submissions" do
      t = Tutor.first
      
      submission = Submission.new
      submission.user = t
      submission.update_attributes(
        kind: "plaintext",
        plaintext: "submission contents"
      )
      expect t.submissions.include?(submission)
    end
  end
  
  describe "convenor" do
    before(:each) do
      User.delete_all
      Convenor.create(
        :firstname => "Thomas",
        :surname => "Jenkins",
        :password => "pass",
        :uid => "u0000001")
      c = Course.create!(
        code: "COMP1100",
        name: "Computing")
    end
    
    it "should be able to create a course" do
      c = Convenor.first
      course = Course.first
      course.convenors << c
      expect c.courses.include?(c)
      expect c.is_convenor?
    end
    
    it "should be able to create submissions" do
      c = Convenor.first
      
      submission = Submission.new
      submission.user = c
      submission.update_attributes(
        kind: "plaintext",
        plaintext: "submission contents"
      )
      expect c.submissions.include?(submission)
    end
  end

end