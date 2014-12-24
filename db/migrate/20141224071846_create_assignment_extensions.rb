class CreateAssignmentExtensions < ActiveRecord::Migration
  def change
    create_table :assignment_extensions do |t|
      t.datetime :due_date
      t.belongs_to :assignment
      t.belongs_to :user

      t.timestamps
    end
  end
end
