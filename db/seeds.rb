# Creations
admin = Admin.create(:firstname => "admin", :password => "admin", :uid => "u0000000")
convenor = Convenor.create(:firstname => "A", :surname => "Convenor", :password => "pass", :uid => "u0000001")
student = Student.create(:firstname => "Thomas", :surname => "Jenkins", :password => "pass", :uid => "u0000002")
c = Course.create(code: "COMP1100", name: "Introduction to Programming and Algorithms",
             description: "A truly great course")
assignment = Assignment.create(name: "Test assignment", due_date: "2421-02-11 14:00:00",
                     description: "Submission instructions here", kind: "plaintext")
group = Group.create(name: "Tuesday 9-11")

# Enrollments
c.students << student
c.convenors << convenor
c.assignments << assignment
student.courses << c
for u in c.users
  u.assignments << assignment
end

group.students << student
c.groups << group
