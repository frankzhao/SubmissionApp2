class CreateGroupsUsers < ActiveRecord::Migration
  def change
    create_table :groups_users, :id => false do |t|
      t.references :group
      t.references :user
      t.references :student
    end

    add_index :groups_users, [:group_id, :user_id]
    add_index :groups_users, :user_id
    add_index :groups_users, [:group_id, :student_id]
    add_index :groups_users, :student_id
  end
end
