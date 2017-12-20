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

Homeland::HourScore.prof do
  # 随机造一些用户
  users = []

  1000.times { users << User.new(email: Faker::Internet.email, password: "111111", password_confirmation: "111111") }
  User.import users
end

# time is: 133.780887s
Homeland::HourScore.prof do
  # Topic 的数据创建完成
  Homeland::Node.all.each do |node|
    topics = []

    10000.times do
      user_id = rand(1..1000)
      title = Faker::Book.title
      body = Faker::Markdown.emphasis

      topics << Homeland::Topic.new(user_id: user_id, node_id: node.id, title: title, body: body)
    end

    Homeland::Topic.import topics
  end
end

# time is 405.003382 s
Homeland::HourScore.prof do
  # Reply 的数据, 随机造的数据
  Homeland::Topic.find_each do |topic|
    replies = []

    rand(10).times do
      user_id = rand(1..1000)
      body = Faker::Markdown.emphasis

      replies << Homeland::Reply.new(user_id: user_id, topic_id: topic.id, body: body)
    end

    Homeland::Reply.import replies
  end
end

# 批量创建 20.159731 s
Homeland::HourScore.prof do
  # PV 的数据，其实也可以随机造一些的， 目前，已经不重要的了，已经有数据了
  page_views = []

  50000.times do
    page_views << Homeland::PageView.new(topic_id: rand(5000))
  end

  Homeland::PageView.import page_views
end
