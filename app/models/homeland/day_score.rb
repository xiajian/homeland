module Homeland
  class DayScore < ApplicationRecord
    class << self

      def get_day_seq(time)
        time.to_i / (3600 * 24)
      end

      def get_time_by_seq(day_seq)
        Time.at day_seq * 3600 * 24
      end

      # score = ( v0 + p0 * 3 ) * 7 + (v1 + p1 * 3) * 6 + …  + (v6 + p6 * 3 ) * 1
      # 每隔小时跟新一次。
      # 1. 根据时间，计算得出当前时间在全年的天书的序号 X，以及当前年份。
      # 2. 计算 tmp_v0 = 24 * (v0 + p0*3 )  注： 这里有两次查询
      # 3. 根据 Year 以及 序号 查询，X-1， X-6 是否在于数据库中，将不存在的序列号数组求出来
      # 4. 针对这些不存在的序列，去执行求值，并将数据存放到数据库中， 这里有些不同的，其实可以利用 hour_score 中存放的数据，判断根据 day_seq 和 year，获取的记录是否是 24，如果是，直接将 hour_score 的值 sum 一下，存放在其中，如果不是，直接利用公式计算。 注： 两条 SQL
      # 5. 此时，将所有的 X-1，X -23 数据取出，求值，并于 tmp_v0 相加，并赋值给 total
      # 6. 最后，将total 的值写入到对应的 topic 的 last_week_score 字段中
      def get_score_by_time(time, topic_id)
        current_seq = get_day_seq time
        total = 0

        tmp_base = if time.to_i % (3600 * 24) > 0
                     begin_at = time.at_beginning_of_day
                     v0 = Homeland::PageView.get_count begin_at, time, topic_id
                     p0 = Homeland::Reply.get_count begin_at, time, topic_id
                     7 * (v0 + 3 * p0)
                   else
                     0
                   end
        total += tmp_base

        day_seqs = ((current_seq - 6)..(current_seq - 1)).to_a

        exist_seqs = self.where(day_seq: day_seqs, topic_id: topic_id).pluck(:day_seq)
        no_exist_seqs = day_seqs - exist_seqs

        no_exist_seqs.each do |seq|
          tmp_time = get_time_by_seq seq
          tmp_v = Homeland::PageView.get_count_by_day_and_topic tmp_time, topic_id
          tmp_p = Homeland::Reply.get_count_by_day_and_topic tmp_time, topic_id

          score_base = tmp_v + 3 * tmp_p

          self.create!(topic_id: topic_id, day_seq: seq, score_base: score_base)
        end

        self.where(day_seq: day_seqs, topic_id: topic_id).each do |day_score|
          total += (7 - (current_seq - day_score.day_seq)) * day_score.score_base
        end

        total
      end

      # 备注： 8 百多条，第一次更新，使用了 24.471511 s， 第二次更新 4.413085 s, 之后的更新都是增量的，速度回快一些
      def update_topic_last_week_score
        Homeland::HourScore.prof do
          time = Time.now
          Homeland::Topic.find_each do |topic|
            topic.last_week_score = get_score_by_time time, topic.id
            topic.save
          end
        end
      end
    end
  end
end
