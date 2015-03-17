class AddIndexToReports < ActiveRecord::Migration
  def change
    add_index :reports, [:date, :user_id], unique: true
  end
end
