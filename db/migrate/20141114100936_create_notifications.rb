class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text :text
      t.string :link
      t.boolean :seen, default: false
      t.belongs_to :user

      t.timestamps
    end
  end
end
