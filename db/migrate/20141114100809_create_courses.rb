class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name, :null => false
      t.string :code, :null => false
      t.timestamps
    end
  end
end
