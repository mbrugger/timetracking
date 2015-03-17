class AddIndexToLeaveDays < ActiveRecord::Migration
  def change
    add_index :leave_days, [:date, :user_id], unique: true
  end
end
