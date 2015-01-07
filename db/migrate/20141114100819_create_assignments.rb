class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.string :name, :null => false
      t.datetime :due_date
      t.text :description
      t.text :tests
      t.string :kind, :null => false
      t.belongs_to :course
      t.belongs_to :user
      t.boolean :peer_review_enabled
      t.timestamps
    end
  end
end
