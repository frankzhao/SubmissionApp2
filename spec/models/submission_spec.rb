require 'spec_helper'

RSpec.describe Submission, :type => :model do
  describe "methods" do
    before(:each) do
      User.delete_all
      Submission.delete_all
      Assignment.delete_all
      Course.delete_all
      
      student = Student.create(
        :firstname => "Thomas",
        :surname => "Jenkins",
        :password => "pass",
        :uid => "u0000002")
      course = Course.create(
        code: "COMP1100",
        name: "Introduction to Programming and Algorithms",
        description: "A truly great course")
      assignment = Assignment.create(
        name: "Test assignment",
        due_date: "2421-02-11 14:00:00",
        description: "Submission instructions here",
        kind: "plaintext")
      group = Group.create(name: "Tuesday 9-11")
      submission = Submission.new
      submission.user = student
      submission.assignment = assignment
      submission.update_attributes(
        kind: "plaintext",
        plaintext: "submission contents"
      )
      
      course.students << student
      course.assignments << assignment
      course.groups << group
      group.students << student
    end
    
    it "ensures user ownership" do
      student = User.first
      submission = Submission.first
      expect(submission.user).to eq(student)
    end

    it "ensures group ownership" do
      student = User.first
      submission = Submission.first
      expect(student.groups).to eq(submission.user.groups)
    end
    
    it "ensures assignment ownership" do
      assignment = Assignment.first
      submission = Submission.first
      expect(submission.assignment).to eq(assignment)
      expect assignment.submissions.include?(submission)
    end
    
    it "ensures course ownership" do
      course = Course.first
      submission = Submission.first
      assignment = Assignment.first
      expect(submission.assignment.course).to eq(course)
      expect course.assignments.first.submissions.include?(submission)
    end
    
    it "ensures comments can be added" do
      user = User.first
      submission = Submission.first
      comment = Comment.new
      comment.user = user
      comment.submission = submission
      comment = Comment.create!(
        text: "comment text")
      expect submission.comments.include?(comment)
      expect !submission.comments.select{|c| c.user == user}.nil?
    end
  end

end