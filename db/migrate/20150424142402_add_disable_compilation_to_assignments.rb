class AddDisableCompilationToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :disable_compilation, :boolean, default: false
  end
end
