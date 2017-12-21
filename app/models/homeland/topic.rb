module Homeland
  class Topic < ActiveRecord::Base
    include Homeland::Concerns::SoftDelete
    include Homeland::Concerns::Markup
    include Homeland::Concerns::UserDelegates

    self.per_page = Homeland.config.per_page

    belongs_to :user, class_name: Homeland.config.user_class.to_s
    belongs_to :last_reply_user, class_name: Homeland.config.user_class.to_s
    belongs_to :node, class_name: 'Homeland::Node', counter_cache: true
    has_many :replies, class_name: 'Homeland::Reply'

    validates :user_id, :title, :body, :node_id, presence: true

    scope :recent, -> { order('id desc') }
    scope :latest, -> { order('last_active_mark desc, id desc') }
    scope :features, -> { where('replies_count >= 20').latest }

    extend OrderAsSpecified

    class << self

      # mysql 特定的处理
      def last_day_hot
        # ids = self.order(last_day_score: :desc).limit(100).pluck(:id)
        ids = $redis.zrevrange(Homeland::HourScore::LAST_DAY_HOT_TOPIC_KEY, 0, 99)

        #self.where(id: ids).order("FIELD ('id', #{ids.join(',')})")
        self.where(id: ids).order_as_specified(id: ids)
      end

      def last_week_hot
        # ids = self.order(last_week_score: :desc).limit(100).pluck(:id)
        ids = $redis.zrevrange(Homeland::DayScore::LAST_WEEK_HOT_TOPIC_KEY, 0, 99)

        # self.where(id: ids).order("FIELD ('id', #{ids.join(',')})")
        self.where(id: ids).order_as_specified(id: ids)
      end

      def get_candidate_hot_ids
        # most_reply_topic_ids = Homeland::Topic.find_by_sql('select a.id, (select count(*) from `homeland_replies` b where a.id = b.topic_id) reply_cnt from  `homeland_topics` a ORDER BY reply_cnt desc limit 3000').pluck(:id)
        most_reply_topic_ids = Homeland::Topic.order(replies_count: :desc).limit(900).pluck(:id)

        most_pv_topic_ids = Homeland::Topic.find_by_sql('select a.id, (select count(*) from `homeland_page_views` b where a.id = b.topic_id) pv_cnt from  `homeland_topics` a ORDER BY pv_cnt desc limit 300').pluck(:id)

        most_pv_topic_ids + most_reply_topic_ids
      end
    end

    before_create :set_last_active_mark
    def set_last_active_mark
      self.last_active_mark = Time.now.to_i
    end

    def activity_at
      self.replied_at || self.updated_at || self.created_at
    end
  end
end
