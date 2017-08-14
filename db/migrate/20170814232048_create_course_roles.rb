class CreateCourseRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :course_roles do |t|
      t.integer :course_id, null: false
      t.integer :user_id, null: false
      t.string :role, null: false

      t.timestamps
    end
  end
end
