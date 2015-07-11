class AddUserIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :user_id, :id
  end
end
