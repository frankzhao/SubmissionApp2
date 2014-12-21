class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :submission
      t.text :text, :null => false
      t.string :mark
      t.binary :attachment, :limit => 10.megabyte
      t.integer :parent_id, default: 0

      t.timestamps
    end
  end
end
