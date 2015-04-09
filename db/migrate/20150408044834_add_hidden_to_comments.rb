class AddHiddenToComments < ActiveRecord::Migration
  def change
    add_column :comments, :hidden, :boolean, default: false
    add_column :comments, :visible, :boolean, default: true
  end
end
