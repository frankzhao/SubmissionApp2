require 'spec_helper'

RSpec.describe User, :type => :model do
  
  # HAHA
	it "returns true" do
    true
	end
  
  describe "student" do
    before(:each) do
      User.delete_all
      Student.create(:firstname => "Thomas", :surname => "Jenkins", :password => "pass", :uid => "u0000002")
    end
    
    it "should not have any courses" do
      s = User.first
      expect(s.courses.nil?)
    end
    
    it "should not have additional privileges" do
      s = User.first
      expect(!s.is_admin_or_convenor?)
      expect(!s.is_tutor?)
      expect(!s.is_staff?)
    end
  end

end