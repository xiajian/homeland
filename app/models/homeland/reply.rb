module Homeland
  class Reply < ActiveRecord::Base
    include Homeland::Concerns::SoftDelete
    include Homeland::Concerns::Markup
    include Homeland::Concerns::UserDelegates

    self.per_page = Homeland.config.per_page

    belongs_to :user, class_name: Homeland.config.user_class.to_s
    belongs_to :topic, class_name: 'Homeland::Topic'
    belongs_to :reply_to, class_name: 'Homeland::Reply'

    has_many :replies, class_name: "Homeland::Reply", foreign_key: "reply_to_id"

    validates :user_id, :body, :topic_id, presence: true

    scope :recent, -> { order('id desc') }

    class << self

      def get_reply_cnt_key(time, topic_id)
        "reply_#{time.strftime('%Y%m%d')}_#{topic_id}"
      end

      def get_count_by_time_and_topic(time, topic_id)
        begin_at = time.at_beginning_of_hour
        end_at = time.at_end_of_hour
        get_count(begin_at, end_at, topic_id)
      end

      def get_count_by_day_and_topic(time, topic_id)
        begin_at = time.at_beginning_of_day
        end_at = time.at_end_of_day
        get_count begin_at, end_at, topic_id
      end

      # 获取每小时的回帖数
      def get_hour_reply_by_time_and_topic(time, topic_id)
        key = get_reply_cnt_key time, topic_id
        index = time.hour

        if (flag = $redis.exists(key)) && $redis.hexists(key, index)
          reply_cnt = $redis.hget(key, index).to_i
        else
          reply_cnt = get_count_by_time_and_topic(time, topic_id)

          if reply_cnt > 0
            $redis.hset key, index, reply_cnt
            $redis.expire key, 8.days unless flag
          end
        end

        reply_cnt
      end

      # 获取的每天的回帖数
      def get_day_reply_by_time_and_topic(time, topic_id)
        key = get_reply_cnt_key time, topic_id

        $redis.exists(key) ? $redis.hvals(key).map(&:to_i).sum : get_count_by_day_and_topic(time, topic_id)
      end

      def get_count(begin_at, end_at, topic_id)
        Homeland::Reply.where("created_at > ? AND created_at < ? AND topic_id = ?", begin_at, end_at, topic_id).count
      end
    end

    after_commit :update_topic_last_reply_at, on: [:create, :update]
    after_commit :update_topic_reply_count, on: [:create]
    
    def update_topic_last_reply_at
      return if self.topic.blank?
      self.topic.replied_at = Time.now
      self.topic.last_active_mark = Time.now.to_i
      self.topic.last_reply_user_id = self.user_id
      self.topic.replies_count = self.topic.replies.count
      self.topic.save
    end

    def update_topic_reply_count
      return if self.topic.blank?
      topic_id = self.topic.id
      time = Time.now
      index = time.hour
      key = Reply.get_reply_cnt_key time, topic_id

      Homeland::PageView.update_redis_key_value_by_hash key, index
    end
  end
end
