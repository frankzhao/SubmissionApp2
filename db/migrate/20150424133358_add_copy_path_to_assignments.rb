class AddCopyPathToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :copy_path, :string, default: nil
  end
end
