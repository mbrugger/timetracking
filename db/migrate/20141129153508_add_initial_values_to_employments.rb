class AddInitialValuesToEmployments < ActiveRecord::Migration
  def change
    add_column :employments, :leave_days, :integer
    add_column :employments, :working_hours_balance, :integer
  end
end
