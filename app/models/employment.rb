class Employment < ActiveRecord::Base
  belongs_to :user
  validates :startDate, presence: true
  validates :weeklyHours, numericality: { only_integer: false, allow_blank: false}

  has_paper_trail skip: [:created_at, :updated_at]

  after_initialize do
    if self.new_record?
      set_default_values
    end
  end

  def migrated_employment?
    return !self.migrated_employment.nil? && self.migrated_employment == true
  end

private
  def set_default_values
  end
end
