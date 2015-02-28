class CreateAssignmentsUsers < ActiveRecord::Migration
  def change
    create_table :assignments_users do |t|
      t.references :user
      t.references :assignment
    end
    
    add_index :assignments_users, [:assignment_id, :user_id]
    add_index :assignments_users, :user_id
  end
end
