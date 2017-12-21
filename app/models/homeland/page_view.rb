module Homeland
  class PageView < ApplicationRecord

    class << self

      def get_page_view_key(time, topic_id)
        "pv_#{time.strftime('%Y%m%d')}_#{topic_id}"
      end

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

      def update_page_view(topic_id)
        time = Time.now
        index = time.hour
        key = "pv_#{time.strftime('%Y%m%d')}_#{topic_id}"

        update_redis_key_value_by_hash key, index
      end

      # 这里解释一下，为何没有没有使用 Hash, 转而是用的是 list
      def update_redis_key_value_by_list(key)
        time = Time.now
        hour = time.hour

        if $redis.exists(key)
          count = $redis.lindex(key, hour).to_i
          $redis.lset key, hour, count + 1
        else
          # 如果不存在，先创建，然后，在设置具体的值
          $redis.multi do
            24.times { $redis.rpush key, 0 }
            $redis.expire key, 8.days.to_i
          end
          $redis.lset key, hour, 1
        end
      end

      def update_redis_key_value_by_hash(key, index)
        if (flag = $redis.exists(key)) && $redis.hexists(key, index)
          $redis.hincrby key, index, 1
        else
          $redis.hsetnx key, index, 1
          $redis.expire key, 8.days.to_i unless flag
        end
      end

      # 获取每小时的数据
      def get_hour_page_view_by_time_and_topic(time, topic_id)
        key = get_page_view_key time, topic_id
        index = time.hour

        $redis.exists(key) && $redis.hexists(key, index) ? $redis.hget(key, index).to_i : 0
      end

      # 获取的每天的 pv 数
      def get_day_page_view_by_time_and_topic(time, topic_id)
        key = get_page_view_key time, topic_id

        $redis.exists(key) ? $redis.hvals(key).map(&:to_i).sum : 0
      end
    end
  end
end
