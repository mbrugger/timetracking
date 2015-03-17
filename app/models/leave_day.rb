class LeaveDay < ActiveRecord::Base
  belongs_to :user
  validates :date, presence: true

  has_paper_trail skip: [:created_at, :updated_at]

  def self.leave_day_types
    return [["Leave Day", "leave_day"], ["Sick Day", "sick_day"], ["Absent Day", "absent_day"], ["Compensatory Time-off", "comp_time"], ["Compensatory Time-off(old)", "comp_time_old"]]
  end
end
