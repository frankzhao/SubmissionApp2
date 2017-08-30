class CreateGroupRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :group_roles do |t|
      t.integer :group_id, null: false
      t.integer :user_id, null: false
      t.string :role, null: false

      t.timestamps
    end
  end
end
