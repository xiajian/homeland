# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171219054122) do

  create_table "homeland_day_scores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "topic_id",   null: false, comment: "话题的 id"
    t.integer  "day_seq",    null: false, comment: "该小时所在的天数在全年中的序号"
    t.integer  "score_base", null: false, comment: "得分的基数"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day_seq"], name: "index_homeland_day_scores_on_day_seq", using: :btree
    t.index ["topic_id"], name: "index_homeland_day_scores_on_topic_id", using: :btree
  end

  create_table "homeland_hour_scores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "topic_id",   null: false, comment: "话题的 ID"
    t.integer  "hour_seq",   null: false, comment: "小时在全年中的序号"
    t.integer  "day_seq",    null: false, comment: "该小时所在的天数在全年中的序号"
    t.integer  "score_base", null: false, comment: "得分的基数"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day_seq"], name: "index_homeland_hour_scores_on_day_seq", using: :btree
    t.index ["hour_seq"], name: "index_homeland_hour_scores_on_hour_seq", using: :btree
    t.index ["topic_id"], name: "index_homeland_hour_scores_on_topic_id", using: :btree
  end

  create_table "homeland_nodes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                     null: false
    t.string   "description"
    t.string   "color"
    t.integer  "sort",         default: 0, null: false
    t.integer  "topics_count", default: 0, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["sort"], name: "index_homeland_nodes_on_sort", using: :btree
  end

  create_table "homeland_page_views", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "topic_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_homeland_page_views_on_topic_id", using: :btree
  end

  create_table "homeland_replies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body",        limit: 65535
    t.text     "body_html",   limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "reply_to_id"
    t.index ["reply_to_id"], name: "index_homeland_replies_on_reply_to_id", using: :btree
    t.index ["topic_id"], name: "index_homeland_replies_on_topic_id", using: :btree
    t.index ["user_id"], name: "index_homeland_replies_on_user_id", using: :btree
  end

  create_table "homeland_topics", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "node_id",                                      null: false
    t.integer  "user_id",                                      null: false
    t.string   "title",                                        null: false
    t.text     "body",               limit: 65535
    t.text     "body_html",          limit: 65535
    t.integer  "last_reply_id"
    t.integer  "last_reply_user_id"
    t.integer  "last_active_mark",                 default: 0, null: false
    t.datetime "replied_at"
    t.integer  "replies_count",                    default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "last_day_score"
    t.integer  "last_week_score"
    t.index ["deleted_at"], name: "index_homeland_topics_on_deleted_at", using: :btree
    t.index ["last_active_mark", "deleted_at"], name: "index_homeland_topics_on_last_active_mark_and_deleted_at", using: :btree
    t.index ["node_id", "deleted_at"], name: "index_homeland_topics_on_node_id_and_deleted_at", using: :btree
    t.index ["node_id", "last_active_mark"], name: "index_homeland_topics_on_node_id_and_last_active_mark", using: :btree
    t.index ["user_id"], name: "index_homeland_topics_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
