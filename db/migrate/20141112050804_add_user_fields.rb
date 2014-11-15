class AddUserFields < ActiveRecord::Migration
  def change
    add_column :users, :type, :string
    add_column :users, :firstname, :string
    add_column :users, :surname, :string
    add_column :users, :has_logged_in_once, :boolean, default: false
  end
end
