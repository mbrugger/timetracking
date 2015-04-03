class LeaveDay < ActiveRecord::Base
  belongs_to :user
  validates :date, presence: true

  has_paper_trail skip: [:created_at, :updated_at]

  def self.leave_day_types
    return ["leave_day", "sick_day", "absent_day", "comp_time", "comp_time_old"]
  end

  def localized_leave_day_type
    I18n.t(leave_day_type, :scope => 'models.leave_days.types')
  end

  def self.localized_leave_day_types
    print "localizing leave day types: \n"
    tmp = LeaveDay.leave_day_types.map { |type| [ I18n.t("models.leave_days.types.#{type}"), type] }
    print "#{tmp.inspect}\n"
    return tmp
  end
end
