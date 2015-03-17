json.array!(@leave_days) do |leave_day|
  json.extract! leave_day, :id
  json.url leave_day_url(leave_day, format: :json)
end
