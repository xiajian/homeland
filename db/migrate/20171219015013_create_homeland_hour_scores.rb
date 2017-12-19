class CreateHomelandHourScores < ActiveRecord::Migration[5.0]
  def change
    create_table :homeland_hour_scores do |t|
      t.integer :topic_id, null: false, comment: '话题的 ID'
      t.integer :hour_seq, null: false, comment: '小时在全年中的序号'
      t.integer :day_seq, null: false, comment: '该小时所在的天数在全年中的序号'
      t.integer :score_base, null: false, comment: '得分的基数'

      t.timestamps
    end

    add_index :homeland_hour_scores, :day_seq
    add_index :homeland_hour_scores, :hour_seq
    add_index :homeland_hour_scores, :topic_id
  end
end
