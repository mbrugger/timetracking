class AddDisableValidationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :validate_working_days, :boolean, default: true
  end
end
