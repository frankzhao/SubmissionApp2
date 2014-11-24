class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, :null => false
      t.timestamps
    end

    add_column :groups, :course_id, :integer
    add_index :groups, :course_id
  end
end
