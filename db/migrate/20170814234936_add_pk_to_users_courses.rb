class AddPkToUsersCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses_users, :id, :primary_key
  end
end
