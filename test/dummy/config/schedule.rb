# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

require 'yaml'

set :output, 'log/whenever_cron.log'


every 1.minute do
  command '/bin/date'
end

every 10.minutes do
  runner 'Homeland::HourScore.update_topic_last_day_score'
end

every 1.hour do
  runner 'Homeland::DayScore.update_topic_last_week_score'
end