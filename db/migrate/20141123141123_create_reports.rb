class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.date :date
      t.integer :balance
      t.integer :workingHours
      t.integer :correction
      t.string :correctionReason
      t.references :user, index: true

      t.timestamps
    end
  end
end
