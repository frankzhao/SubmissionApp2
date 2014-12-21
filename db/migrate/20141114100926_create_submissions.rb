class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text :kind
      t.integer :submitted_by_user_id
      t.text :plaintext
      t.belongs_to :user
      t.belongs_to :assignment
      t.text :status
      t.boolean :finalised, default: false
      t.timestamps
    end
  end
end
