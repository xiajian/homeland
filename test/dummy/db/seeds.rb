# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if Homeland::Node.count == 0
  root_names = %w(Support Bug Dev Meta Feature Releases Faq HowTo)
  root_names.each do |name|
    Homeland::Node.create(name: name, description: name)
  end
end

# 随机造一些用户
100.times { User.create!({:email => Faker::Internet.email, :password => "111111", :password_confirmation => "111111" }) }

# Topic 的数据创建完成
Homeland::Node.all.each do |node|
  100.times do
    user_id = rand(1..100)
    title = Faker::Book.title
    body = Faker::Markdown.emphasis

    Homeland::Topic.create!(user_id: user_id, node_id: node.id, title: title, body: body)
  end
end

# Reply 的数据, 随机造的数据
Homeland::Topic.find_each do |topic|
  rand(10).times do
    user_id = rand(1..100)
    body = Faker::Markdown.emphasis

    Homeland::Reply.create!(user_id: user_id, topic_id: topic.id, body: body)
  end
end

# PV 的数据，其实也可以随机造一些的， 目前，已经不重要的了，已经有数据了

