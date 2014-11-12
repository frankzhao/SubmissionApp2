class CreateConvenors < ActiveRecord::Migration
  def change
    create_table :convenors do |t|

      t.timestamps
    end
  end
end
