class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.text :kind
      t.text :plaintext
      t.belongs_to :user
      t.belongs_to :assignment
      t.boolean :finalised, default: false
      t.integer :peer_review_user_id
      t.timestamps
    end
  end
end
