class AddTimeoutToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :timeout, :integer, default: 3
  end
end
