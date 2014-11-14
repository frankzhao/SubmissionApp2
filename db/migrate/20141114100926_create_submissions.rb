class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text :type
      t.integer :submitted_by_user_id
      t.timestamps
    end
    
    add_column :submissions, :user_id, :integer
    add_index :submissions, :user_id
    add_column :submissions, :assignment_id, :integer
    add_index :submissions, :assignment_id
  end
end
