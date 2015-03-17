class AddIndexToPublicHolidays < ActiveRecord::Migration
  def change
    add_index :public_holidays, :date, unique: true
  end
end
