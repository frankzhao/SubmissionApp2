class CreateGroupsUsers < ActiveRecord::Migration
  def change
    create_table :groups_users, :id => false do |t|
      t.references :group
      t.references :user
      t.references :student
      t.references :convenor
      t.references :tutor
    end

    add_index :groups_users, [:group_id, :user_id]
    add_index :groups_users, :user_id
    add_index :groups_users, [:group_id, :student_id]
    add_index :groups_users, :student_id
    add_index :groups_users, [:group_id, :convenor_id]
    add_index :groups_users, :convenor_id
    add_index :groups_users, [:group_id, :tutor_id]
    add_index :groups_users, :tutor_id
  end
end
