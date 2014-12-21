class CreateTestResults < ActiveRecord::Migration
  def change
    create_table :test_results do |t|
      t.belongs_to :submission
      t.text :result

      t.timestamps
    end
  end
end
