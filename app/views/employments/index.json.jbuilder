json.array!(@employments) do |employment|
  json.extract! employment, :id
  json.url employment_url(employment, format: :json)
end
