class CreateEmployments < ActiveRecord::Migration
  def change
    create_table :employments do |t|
      t.date :startDate
      t.date :endDate
      t.float :weeklyHours
      t.references :user, index: true

      t.timestamps
    end
  end
end
