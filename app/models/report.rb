class Report < ActiveRecord::Base
  belongs_to :user

  validates :balance, presence: true
  validates :correction, numericality: { only_integer: true, allow_blank: true, message: "must be in format hh:mm"}

  has_paper_trail skip: [:created_at, :updated_at]
end
