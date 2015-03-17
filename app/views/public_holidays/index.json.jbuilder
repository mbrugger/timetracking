json.array!(@public_holidays) do |public_holiday|
  json.extract! public_holiday, :id
  json.url public_holiday_url(public_holiday, format: :json)
end
