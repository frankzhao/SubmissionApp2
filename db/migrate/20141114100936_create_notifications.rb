class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text :text
      t.boolean :seen
      t.timestamps
    end
  end
end
