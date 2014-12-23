class CreateCoursesUsers< ActiveRecord::Migration
  def change
    create_table :courses_users, :id => false do |t|
      t.references :course
      t.references :user
      t.belongs_to :convenor
      t.references :student
    end

    add_index :courses_users, [:course_id, :user_id]
    add_index :courses_users, :user_id
    add_index :courses_users, [:course_id, :convenor_id]
    add_index :courses_users, :convenor_id
    add_index :courses_users, [:course_id, :student_id]
    add_index :courses_users, :student_id
  end
end
