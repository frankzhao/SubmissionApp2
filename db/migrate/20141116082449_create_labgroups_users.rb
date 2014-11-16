class CreateLabgroupsUsers < ActiveRecord::Migration
  def change
    create_table :labgroups_users, :id => false do |t|
      t.references :labgroup
      t.references :user
    end

    add_index :labgroups_users, [:labgroup_id, :user_id]
    add_index :labgroups_users, :user_id
  end
end
