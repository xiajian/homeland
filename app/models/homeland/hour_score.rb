module Homeland
  class HourScore < ApplicationRecord
    class << self

      def prof(&block)
        start_time = Time.now

        if block_given?
          result = block.call
        end

        cost_time = Time.now - start_time

        puts "Cost Time is: #{cost_time} s"

        result
      end

      def get_page_view_count_and_reply_count(topic_id)
        pv =  {}
        self.where(topic_id: topic_id).each do |hour_score|
          tmp_time = get_time_by_seq(hour_score.hour_seq)
          puts tmp_time
          tmp_v = Homeland::PageView.get_count_by_time_and_topic tmp_time, topic_id
          tmp_p = Homeland::Reply.get_count_by_time_and_topic tmp_time, topic_id

          pv["#{hour_score.hour_seq}"] = "#{tmp_v}/#{tmp_p}"
        end
        pv
      end

      # 这里利用Unix时间戳，来计算出当前时间的序列
      def get_hour_seq(time)
        time.to_i / 3600
      end

      #
      def get_time_by_seq(hour_seq)
        Time.at hour_seq * 3600
      end

      # score = (v0 + p0 * 3) * 24 + (v1 + p1 * 3) * 23 + … + (v23 + p23 * 3) * 1
      # 1. 根据时间，得出当前的时间在全年中所属的序列号 X， 以及 当前年份 Year
      # 2. 计算 tmp_v0 = 24 * (v0 + p0*3 )  注： 这里有两次查询
      # 3. 根据序号 查询，X-1， X-23 是否在于数据库中，将不存在的序列号数组求出来，然后，针对这些不存在的序列，去执行求值，并将数据存放到数据库中
      # 4. 此时，将所有的 X-1，X -23 数据取出，求值，并于 tmp_v0 相加，并赋值给 total
      # 5. 最后，将total 的值写入到对应的 topic 的 last_day_score 字段中
      # Homeland::HourScore.get_score_by_time Time.now, 2
      def get_score_by_time(time, topic_id)
        current_seq = get_hour_seq time
        total = 0

        # 做一个临界条件的判断
        tmp_base = if time.to_i % 3600 > 0
                     begin_at = time.at_beginning_of_hour
                     v0 = Homeland::PageView.get_count begin_at, time, topic_id
                     p0 = Homeland::Reply.get_count begin_at, time, topic_id
                     24 * (v0 + 3 * p0)
                   else
                     0
                   end

        total += tmp_base

        hour_seqs = ((current_seq-23)..(current_seq - 1)).to_a

        exist_seqs = Homeland::HourScore.where(hour_seq: hour_seqs, topic_id: topic_id).pluck(:hour_seq)

        no_exist_seqs = hour_seqs - exist_seqs

        hour_scores = []
        no_exist_seqs.each do |seq|
          tmp_time = get_time_by_seq(seq)
          tmp_v = Homeland::PageView.get_count_by_time_and_topic tmp_time, topic_id
          tmp_p = Homeland::Reply.get_count_by_time_and_topic tmp_time, topic_id

          score_base = tmp_v + 3 * tmp_p
          day_seq = Homeland::DayScore.get_day_seq(tmp_time)

          hour_scores << self.new(topic_id: topic_id, hour_seq: seq, score_base: score_base, day_seq: day_seq)
        end

        self.import hour_scores

        self.where(hour_seq: hour_seqs, topic_id: topic_id).each do |hour_score|
          total += (24 - (current_seq - hour_score.hour_seq)) * hour_score.score_base
        end

        total
      end

      # 备注: 800 条数据，第一次跟新 82.029876 s， 第二次更新:  6.101894 s，之后的更新记录都是增量的变化的。
      # 800 条数据，增量更新花了 5.748294s
      def update_topic_last_day_score
        prof do
          time = Time.now
          candidate_ids = Homeland::Topic.get_candidate_hot_ids
          Homeland::Topic.where(id: candidate_ids).each do |topic|
            topic.last_day_score = get_score_by_time time, topic.id
            topic.save
          end

          nil
        end
      end
    end
  end
end
