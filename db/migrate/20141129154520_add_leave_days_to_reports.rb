class AddLeaveDaysToReports < ActiveRecord::Migration
  def change
    add_column :reports, :leave_days, :integer
  end
end
