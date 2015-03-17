# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if User.count == 0
  user = User.create([{name: 'admin', role:'admin', email: 'admin@example.com', password: 'admin1234'}]).first
  puts "created user #{user.email} with password #{user.password}"
end
