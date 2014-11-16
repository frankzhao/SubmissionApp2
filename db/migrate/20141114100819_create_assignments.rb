class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :name, :null => false
      t.datetime :due_date
      t.text :description
      t.string :kind, :null => false
      t.timestamps
    end
    
    add_column :assignments, :course_id, :integer
    add_index :assignments, :course_id
  end
end
