class TimeEntry < ActiveRecord::Base
  belongs_to :user
   validates :date, presence: true
   validates :startTime, presence: true
   validate :stop_time_cannot_be_before_start_time

   has_paper_trail skip: [:created_at, :updated_at]

   after_initialize do
     if self.new_record?
       set_default_values
     end
   end

   def stop_time_cannot_be_before_start_time
     if !self.stopTime.nil? && !self.startTime.nil?
       if self.stopTime < self.startTime
         errors.add(:stopTime, "can not be before start time")
       end
     end
   end

   def duration
     if self.stopTime
       (self.stopTime-self.startTime).to_i
     elsif self.date == Date.today
       (Time.zone.now.tv_sec - self.startTime.tv_sec).to_i
     else
       nil
     end
   end

 private
   def set_default_values
     #self.startTime = DateTime.now
   end
end
