class AddLanguageToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :lang, :string
  end
end
