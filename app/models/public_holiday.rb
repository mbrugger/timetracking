class PublicHoliday < ActiveRecord::Base
  validates :date, presence: true

  has_paper_trail skip: [:created_at, :updated_at]

end
