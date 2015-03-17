class CreateLeaveDays < ActiveRecord::Migration
  def change
    create_table :leave_days do |t|
      t.date :date
      t.string :description
      t.string :leave_day_type
      t.references :user, index: true

      t.timestamps
    end
  end
end
