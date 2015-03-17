class CreateTimeEntries < ActiveRecord::Migration
  def change
    create_table :time_entries do |t|
      t.date :date
      t.datetime :startTime
      t.datetime :stopTime
      t.references :user, index: true

      t.timestamps
    end
  end
end
