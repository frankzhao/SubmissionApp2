class CreateLabgroups < ActiveRecord::Migration
  def change
    create_table :labgroups do |t|
      t.string :name, :null => false
      t.timestamps
    end

    add_column :labgroups, :course_id, :integer
    add_index :labgroups, :course_id
  end
end
