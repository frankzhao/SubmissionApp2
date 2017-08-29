class AddConvenorAndAdminBooleanToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :convenor, :boolean, default: false, null: false
    add_column :users, :admin, :boolean, default: false, null: false

    Admin.find_each do |a|
      a.admin = true
      a.save!
    end

    Convenor.find_each do |c|
      c.convenor = true
      c.save!
    end
  end
end
