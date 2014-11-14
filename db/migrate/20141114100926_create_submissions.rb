class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text :type
      t.integer :submitted_by_user_id
      t.timestamps
    end
  end
end
