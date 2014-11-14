class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :name, :null => false
      t.datetime :due_date
      t.text :description
      t.timestamps
    end
  end
end
