# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = Admin.create(:firstname => "admin", :password => "admin", :uid => "u0000000")
convenor = Convenor.create(:firstname => "A", :surname => "Convenor", :password => "pass", :uid => "u0000001")
student = Student.create(:firstname => "Thomas", :surname => "Jenkins", :password => "pass", :uid => "u0000002")
