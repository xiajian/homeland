# This migration comes from homeland (originally 20171218125713)
class CreateHomelandPageViews < ActiveRecord::Migration[5.0]
  def change
    create_table :homeland_page_views do |t|
      t.integer :topic_id, null: false

      t.timestamps
    end

    add_index :homeland_page_views, :topic_id
  end
end
