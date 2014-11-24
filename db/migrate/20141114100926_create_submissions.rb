class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text :type
      t.integer :submitted_by_user_id
      t.belongs_to :user
      t.belongs_to :assignment
      t.timestamps
    end
  end
end
