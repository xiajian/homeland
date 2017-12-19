module Homeland
  class PageView < ApplicationRecord

    class << self
      def get_count_by_time_and_topic(time, topic_id)
        begin_at = time.at_beginning_of_hour
        end_at = time.at_end_of_hour
        get_count begin_at, end_at, topic_id
      end

      def get_count_by_day_and_topic(time, topic_id)
        begin_at = time.at_beginning_of_day
        end_at = time.at_end_of_day
        get_count begin_at, end_at, topic_id
      end

      def get_count(begin_at, end_at, topic_id)
        Homeland::PageView.where("created_at > ? AND created_at < ? AND topic_id = ?", begin_at, end_at, topic_id).count
      end
    end
  end
end
