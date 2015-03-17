class AddMitgratedEmploymentToEmployments < ActiveRecord::Migration
  def change
    add_column :employments, :migrated_employment, :boolean
  end
end
