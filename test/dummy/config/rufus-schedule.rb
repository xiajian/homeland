require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '5s' do
  puts 'Hello... Rufus'
end

scheduler.join