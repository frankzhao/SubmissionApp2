class AddRegexFieldsToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :pdf_regex, :string
    add_column :assignments, :zip_regex, :string
    add_column :assignments, :custom_command, :string
    add_column :assignments, :custom_compilation, :boolean, default: false
  end
end
