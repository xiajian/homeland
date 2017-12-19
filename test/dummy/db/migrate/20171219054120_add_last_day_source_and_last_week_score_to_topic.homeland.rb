# This migration comes from homeland (originally 20171219013506)
class AddLastDaySourceAndLastWeekScoreToTopic < ActiveRecord::Migration[5.0]
  def change
    add_column :homeland_topics, :last_day_score, :integer
    add_column :homeland_topics, :last_week_score, :integer
  end
end
