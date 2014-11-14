class CreateLabgroups < ActiveRecord::Migration
  def change
    create_table :labgroups do |t|
      t.string :name, :null => false
      t.timestamps
    end
  end
end
