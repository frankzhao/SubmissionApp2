class CreateCoursesUsers < ActiveRecord::Migration
  def change
    create_table :courses_users, :id => false do |t|
      t.references :course
      t.references :user
    end

    add_index :courses_users, [:course_id, :user_id]
    add_index :courses_users, :user_id
  end
end
