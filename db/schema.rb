# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_04_14_043745) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.float "duration"
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "role"
    t.string "name"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "agencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.string "address"
    t.string "phone_number"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_agencies_on_email", unique: true
    t.index ["reset_password_token"], name: "index_agencies_on_reset_password_token", unique: true
  end

  create_table "allowlisted_jwts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["jti"], name: "index_allowlisted_jwts_on_jti", unique: true
    t.index ["user_id"], name: "index_allowlisted_jwts_on_user_id"
  end

  create_table "announcements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "title"
    t.text "body", size: :long
    t.datetime "announced_at"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "auto_response_keywords", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "auto_response_id"
    t.string "keyword"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["auto_response_id"], name: "index_auto_response_keywords_on_auto_response_id"
  end

  create_table "auto_response_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "auto_response_id"
    t.json "content"
    t.integer "message_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["auto_response_id"], name: "index_auto_response_messages_on_auto_response_id"
  end

  create_table "auto_responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "folder_id"
    t.string "name"
    t.string "status"
    t.json "biz_hours"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.integer "hit_count", default: 0
    t.index ["folder_id"], name: "index_auto_responses_on_folder_id"
    t.index ["line_account_id"], name: "index_auto_responses_on_line_account_id"
  end

  create_table "broadcast_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "broadcast_id"
    t.json "content"
    t.integer "message_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["broadcast_id"], name: "index_broadcast_messages_on_broadcast_id"
  end

  create_table "broadcasts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.json "conditions"
    t.string "title"
    t.boolean "deliver_now", default: true
    t.string "status"
    t.string "type"
    t.datetime "schedule_at"
    t.datetime "deliver_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.text "logs"
    t.index ["line_account_id"], name: "index_broadcasts_on_line_account_id"
  end

  create_table "channel_members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "channel_id"
    t.string "participant_type"
    t.bigint "participant_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["channel_id"], name: "index_channel_members_on_channel_id"
    t.index ["participant_type", "participant_id"], name: "index_participant_id_and_type_on_channel_participants"
  end

  create_table "channels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "line_friend_id"
    t.bigint "assignee_id"
    t.string "title"
    t.string "avatar"
    t.string "last_message"
    t.datetime "last_activity_at"
    t.datetime "last_seen_at"
    t.boolean "locked"
    t.string "alias"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["assignee_id"], name: "index_channels_on_assignee_id"
    t.index ["line_account_id"], name: "index_channels_on_line_account_id"
    t.index ["line_friend_id"], name: "index_channels_on_line_friend_id"
  end

  create_table "clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "agency_id"
    t.string "name"
    t.string "phone_number"
    t.string "address"
    t.string "status", default: "active"
    t.boolean "gauth_visible", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["agency_id"], name: "index_clients_on_agency_id"
  end

  create_table "emojis", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "package_id"
    t.string "line_emoji_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "episodes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "reminder_id"
    t.boolean "is_initial"
    t.integer "date"
    t.string "time"
    t.json "actions"
    t.json "messages"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reminder_id"], name: "index_episodes_on_reminder_id"
  end

  create_table "flex_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.json "content"
    t.text "html_content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "folders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.string "name"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["line_account_id"], name: "index_folders_on_line_account_id"
  end

  create_table "friend_variables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_friend_id"
    t.bigint "variable_id"
    t.bigint "survey_answer_id"
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_friend_id"], name: "index_friend_variables_on_line_friend_id"
    t.index ["survey_answer_id"], name: "index_friend_variables_on_survey_answer_id"
    t.index ["variable_id"], name: "index_friend_variables_on_variable_id"
  end

  create_table "insights", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.string "type", default: "daily"
    t.date "date"
    t.integer "quota", default: 0
    t.integer "total_usage", default: 0
    t.integer "broadcast"
    t.integer "targeting"
    t.integer "auto_response"
    t.integer "welcome_response"
    t.integer "chat"
    t.integer "api_broadcast"
    t.integer "api_push"
    t.integer "api_multicast"
    t.integer "api_narrowcast"
    t.integer "api_reply"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_account_id"], name: "index_insights_on_line_account_id"
  end

  create_table "line_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "client_id"
    t.string "line_user_id"
    t.string "line_name"
    t.string "display_name"
    t.string "channel_id"
    t.string "channel_secret"
    t.string "invite_url"
    t.string "webhook_url"
    t.string "liff_id"
    t.string "pms_api_key"
    t.text "note"
    t.boolean "bot_initialized", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["client_id"], name: "index_line_accounts_on_client_id"
  end

  create_table "line_friends", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.string "line_picture_url"
    t.string "line_user_id"
    t.string "line_name"
    t.string "display_name"
    t.string "status", default: "active"
    t.boolean "locked", default: false
    t.boolean "visible", default: true
    t.text "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.boolean "tester", default: false
    t.bigint "stream_route_id"
    t.index ["line_account_id"], name: "index_line_friends_on_line_account_id"
    t.index ["stream_route_id"], name: "index_line_friends_on_stream_route_id"
    t.index ["tester"], name: "index_line_friends_on_tester"
  end

  create_table "login_activities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "scope"
    t.string "strategy"
    t.string "identity"
    t.boolean "success"
    t.string "failure_reason"
    t.string "user_type"
    t.bigint "user_id"
    t.string "context"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "city"
    t.string "region"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at"
    t.index ["identity"], name: "index_login_activities_on_identity"
    t.index ["ip"], name: "index_login_activities_on_ip"
    t.index ["user_type", "user_id"], name: "index_login_activities_on_user_type_and_user_id"
  end

  create_table "media", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.string "type"
    t.string "provider", default: "system"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_account_id"], name: "index_media_on_line_account_id"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "channel_id"
    t.string "sender_type"
    t.bigint "sender_id"
    t.string "type"
    t.string "from"
    t.text "text"
    t.json "content"
    t.text "html_content"
    t.string "timestamp"
    t.string "reply_token"
    t.string "status", default: "sent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["channel_id"], name: "index_messages_on_channel_id"
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender_type_and_sender_id"
  end

  create_table "pms_reservations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_friend_id", null: false
    t.string "agency_booking_number"
    t.string "agency_code"
    t.string "agency_name"
    t.string "agency_plan_code"
    t.string "agency_plan_name"
    t.string "booking_date"
    t.string "booking_time"
    t.integer "charge_claimed"
    t.integer "charge_total"
    t.string "charge_type"
    t.string "check_in_date"
    t.string "check_in_time"
    t.string "check_out_date"
    t.string "guest_name"
    t.string "guest_kana"
    t.string "pms_id"
    t.text "insight_memo"
    t.integer "nights"
    t.text "order_memo"
    t.string "payment"
    t.string "prop_id"
    t.json "room_list"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status"
    t.string "guest_phone_number"
    t.json "tags"
    t.index ["line_friend_id"], name: "index_pms_reservations_on_line_friend_id"
    t.index ["pms_id"], name: "index_pms_reservations_on_pms_id"
  end

  create_table "postback_mappers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key"
    t.json "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_postback_mappers_on_key"
  end

  create_table "reminder_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "reminding_id"
    t.bigint "episode_id"
    t.string "status"
    t.datetime "schedule_at"
    t.boolean "is_last", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["episode_id"], name: "index_reminder_events_on_episode_id"
    t.index ["reminding_id"], name: "index_reminder_events_on_reminding_id"
  end

  create_table "reminders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "folder_id"
    t.bigint "line_account_id"
    t.string "name"
    t.integer "episodes_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["folder_id"], name: "index_reminders_on_folder_id"
    t.index ["line_account_id"], name: "index_reminders_on_line_account_id"
  end

  create_table "remindings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "channel_id"
    t.bigint "reminder_id"
    t.datetime "goal"
    t.string "status", default: "active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["channel_id"], name: "index_remindings_on_channel_id"
    t.index ["reminder_id"], name: "index_remindings_on_reminder_id"
  end

  create_table "reservation_inquiries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "num_room"
    t.date "date_start"
    t.date "date_end"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reservation_precheckins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "line_friend_id"
    t.string "name"
    t.string "phone_number"
    t.date "check_in_date"
    t.date "check_out_date"
    t.string "address"
    t.string "birthdate"
    t.string "companion"
    t.integer "gender"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_account_id"], name: "index_reservation_precheckins_on_line_account_id"
    t.index ["line_friend_id"], name: "index_reservation_precheckins_on_line_friend_id"
  end

  create_table "reservations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_friend_id"
    t.string "room_id"
    t.string "room_name"
    t.integer "stock"
    t.datetime "stock_from"
    t.datetime "stock_to"
    t.string "notifier_id"
    t.string "status", default: "wait"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "line_account_id"
    t.index ["line_account_id"], name: "index_reservations_on_line_account_id"
    t.index ["line_friend_id"], name: "index_reservations_on_line_friend_id"
  end

  create_table "review_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "review_id"
    t.bigint "review_question_id"
    t.text "answer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["review_id"], name: "index_review_answers_on_review_id"
    t.index ["review_question_id"], name: "index_review_answers_on_review_question_id"
  end

  create_table "review_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.string "title"
    t.text "description"
    t.json "config"
    t.integer "sort_order"
    t.boolean "required", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reviews", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "line_friend_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_reviews_on_client_id"
    t.index ["line_friend_id"], name: "index_reviews_on_line_friend_id"
  end

  create_table "rich_menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "folder_id"
    t.string "line_menu_id", comment: "richMenuId"
    t.string "template_id"
    t.string "name"
    t.json "size"
    t.string "chat_bar_text"
    t.boolean "selected"
    t.json "areas"
    t.string "status", default: "enabled"
    t.string "target", default: "all"
    t.json "conditions"
    t.boolean "enabled"
    t.bigint "media_id"
    t.integer "member_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.text "logs"
    t.index ["folder_id"], name: "index_rich_menus_on_folder_id"
    t.index ["line_account_id"], name: "index_rich_menus_on_line_account_id"
    t.index ["media_id"], name: "index_rich_menus_on_media_id"
  end

  create_table "scenario_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "scenario_id"
    t.bigint "scenario_message_id"
    t.string "type"
    t.json "content"
    t.bigint "channel_id"
    t.datetime "schedule_at"
    t.integer "order"
    t.string "status"
    t.boolean "is_last", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "scenario_log_id"
    t.index ["channel_id"], name: "index_scenario_events_on_channel_id"
    t.index ["line_account_id"], name: "index_scenario_events_on_line_account_id"
    t.index ["scenario_id"], name: "index_scenario_events_on_scenario_id"
    t.index ["scenario_log_id"], name: "index_scenario_events_on_scenario_log_id"
    t.index ["scenario_message_id"], name: "index_scenario_events_on_scenario_message_id"
  end

  create_table "scenario_friends", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "scenario_id", null: false
    t.bigint "line_friend_id", null: false
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_friend_id"], name: "index_scenario_friends_on_line_friend_id"
    t.index ["scenario_id"], name: "index_scenario_friends_on_scenario_id"
  end

  create_table "scenario_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "scenario_id", null: false
    t.bigint "line_friend_id", null: false
    t.string "status"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_friend_id"], name: "index_scenario_logs_on_line_friend_id"
    t.index ["scenario_id"], name: "index_scenario_logs_on_scenario_id"
  end

  create_table "scenario_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "scenario_id"
    t.string "status", default: "disabled"
    t.string "name"
    t.json "content"
    t.integer "message_type_id"
    t.integer "date"
    t.string "time"
    t.boolean "is_initial", default: true
    t.integer "step"
    t.integer "order"
    t.boolean "pause"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["scenario_id"], name: "index_scenario_messages_on_scenario_id"
  end

  create_table "scenarios", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "folder_id"
    t.string "title"
    t.text "description"
    t.string "status", default: "disabled"
    t.string "mode", default: "time"
    t.string "type", default: "manual"
    t.json "after_action"
    t.integer "scenario_messages_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.integer "sending_friend_count", default: 0
    t.integer "sent_friend_count", default: 0
    t.index ["folder_id"], name: "index_scenarios_on_folder_id"
    t.index ["line_account_id"], name: "index_scenarios_on_line_account_id"
  end

  create_table "scorings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "friend_variable_id"
    t.string "operation", default: "set"
    t.string "value"
    t.string "old_value"
    t.string "new_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["friend_variable_id"], name: "index_scorings_on_friend_variable_id"
  end

  create_table "site_measurements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "measurable_id"
    t.string "measurable_type"
    t.json "actions"
    t.integer "sending_count", default: 0
    t.integer "click_count", default: 0
    t.integer "receiver_count", default: 0
    t.integer "visitor_count", default: 0
    t.bigint "site_id", null: false
    t.string "site_name"
    t.text "redirect_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["measurable_id"], name: "index_site_measurements_on_measurable_id"
    t.index ["measurable_type"], name: "index_site_measurements_on_measurable_type"
    t.index ["site_id"], name: "index_site_measurements_on_site_id"
  end

  create_table "site_measurements_line_friends", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "site_measurement_id", null: false
    t.bigint "line_friend_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "sent", default: false
    t.boolean "visited", default: false
    t.index ["line_friend_id"], name: "index_site_measurements_line_friends_on_line_friend_id"
    t.index ["site_measurement_id"], name: "index_site_measurements_line_friends_on_site_measurement_id"
  end

  create_table "site_references", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "code"
    t.string "line_user_id"
    t.string "site_measurement_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_site_references_on_code"
  end

  create_table "sites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "url"
    t.string "name"
    t.bigint "folder_id", null: false
    t.integer "sending_count", default: 0
    t.integer "click_count", default: 0
    t.integer "receiver_count", default: 0
    t.integer "visitor_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "client_id", null: false
    t.index ["client_id"], name: "index_sites_on_client_id"
    t.index ["folder_id"], name: "index_sites_on_folder_id"
  end

  create_table "sites_line_friends", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.bigint "line_friend_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "sent", default: false
    t.boolean "visited", default: false
    t.index ["line_friend_id"], name: "index_sites_line_friends_on_line_friend_id"
    t.index ["site_id"], name: "index_sites_line_friends_on_site_id"
  end

  create_table "stream_routes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "folder_id", null: false
    t.string "name"
    t.json "actions"
    t.string "code"
    t.boolean "run_add_friend_actions", default: false
    t.boolean "always_run_actions", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "client_id", null: false
    t.string "qr_title"
    t.index ["client_id"], name: "index_stream_routes_on_client_id"
    t.index ["folder_id"], name: "index_stream_routes_on_folder_id"
  end

  create_table "survey_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "survey_response_id"
    t.bigint "survey_question_id"
    t.json "answer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"
    t.index ["survey_response_id"], name: "index_survey_answers_on_survey_response_id"
  end

  create_table "survey_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.string "name"
    t.integer "order", default: 0
    t.boolean "required", default: false
    t.string "type"
    t.json "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "survey_responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.bigint "line_friend_id"
    t.integer "answer_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_friend_id"], name: "index_survey_responses_on_line_friend_id"
    t.index ["survey_id"], name: "index_survey_responses_on_survey_id"
  end

  create_table "surveys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "folder_id"
    t.string "type", default: "normal"
    t.string "code"
    t.string "name"
    t.string "banner_url"
    t.string "liff_id"
    t.string "title"
    t.text "description"
    t.json "after_action"
    t.text "success_message"
    t.string "status", default: "enabled"
    t.boolean "re_answer", default: false
    t.boolean "sync_to_ggsheet", default: false
    t.boolean "connected_to_ggsheet", default: false
    t.string "google_oauth_code"
    t.json "google_oauth_tokens"
    t.string "google_oauth_email"
    t.string "spreadsheet_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["folder_id"], name: "index_surveys_on_folder_id"
    t.index ["line_account_id"], name: "index_surveys_on_line_account_id"
  end

  create_table "taggings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.bigint "tag_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "folder_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["folder_id"], name: "index_tags_on_folder_id"
    t.index ["line_account_id"], name: "index_tags_on_line_account_id"
  end

  create_table "template_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "template_id"
    t.integer "message_type_id"
    t.json "content"
    t.integer "order", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["template_id"], name: "index_template_messages_on_template_id"
  end

  create_table "templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "folder_id"
    t.string "name"
    t.integer "template_messages_count", default: 0
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["folder_id"], name: "index_templates_on_folder_id"
    t.index ["line_account_id"], name: "index_templates_on_line_account_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "client_id"
    t.string "email", default: "", null: false
    t.string "role"
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "company_name"
    t.string "phone_number"
    t.string "address"
    t.text "note"
    t.string "status", default: "active"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "authentication_token"
    t.string "pubsub_token"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["client_id"], name: "index_users_on_client_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "line_account_id"
    t.bigint "folder_id"
    t.string "name"
    t.string "type"
    t.string "default"
    t.integer "friends_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["folder_id"], name: "index_variables_on_folder_id"
    t.index ["line_account_id"], name: "index_variables_on_line_account_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allowlisted_jwts", "users"
  add_foreign_key "auto_response_keywords", "auto_responses"
  add_foreign_key "auto_response_messages", "auto_responses"
  add_foreign_key "auto_responses", "folders"
  add_foreign_key "auto_responses", "line_accounts"
  add_foreign_key "broadcast_messages", "broadcasts"
  add_foreign_key "broadcasts", "line_accounts"
  add_foreign_key "channel_members", "channels"
  add_foreign_key "channels", "line_accounts"
  add_foreign_key "channels", "line_friends"
  add_foreign_key "channels", "users", column: "assignee_id"
  add_foreign_key "clients", "agencies"
  add_foreign_key "episodes", "reminders"
  add_foreign_key "folders", "line_accounts"
  add_foreign_key "friend_variables", "line_friends"
  add_foreign_key "friend_variables", "survey_answers"
  add_foreign_key "friend_variables", "variables"
  add_foreign_key "insights", "line_accounts"
  add_foreign_key "line_accounts", "clients"
  add_foreign_key "line_friends", "line_accounts"
  add_foreign_key "line_friends", "stream_routes"
  add_foreign_key "media", "line_accounts"
  add_foreign_key "messages", "channels"
  add_foreign_key "pms_reservations", "line_friends"
  add_foreign_key "reminder_events", "episodes"
  add_foreign_key "reminder_events", "remindings"
  add_foreign_key "reminders", "folders"
  add_foreign_key "reminders", "line_accounts"
  add_foreign_key "remindings", "channels"
  add_foreign_key "remindings", "reminders"
  add_foreign_key "reservation_precheckins", "line_accounts"
  add_foreign_key "reservation_precheckins", "line_friends"
  add_foreign_key "reservations", "line_accounts"
  add_foreign_key "reservations", "line_friends"
  add_foreign_key "review_answers", "review_questions"
  add_foreign_key "review_answers", "reviews"
  add_foreign_key "reviews", "clients"
  add_foreign_key "reviews", "line_friends"
  add_foreign_key "rich_menus", "folders"
  add_foreign_key "rich_menus", "line_accounts"
  add_foreign_key "rich_menus", "media", column: "media_id"
  add_foreign_key "scenario_events", "channels"
  add_foreign_key "scenario_events", "line_accounts"
  add_foreign_key "scenario_events", "scenario_logs"
  add_foreign_key "scenario_events", "scenario_messages"
  add_foreign_key "scenario_events", "scenarios"
  add_foreign_key "scenario_friends", "line_friends"
  add_foreign_key "scenario_friends", "scenarios"
  add_foreign_key "scenario_logs", "line_friends"
  add_foreign_key "scenario_logs", "scenarios"
  add_foreign_key "scenario_messages", "scenarios"
  add_foreign_key "scenarios", "folders"
  add_foreign_key "scenarios", "line_accounts"
  add_foreign_key "scorings", "friend_variables"
  add_foreign_key "site_measurements", "sites"
  add_foreign_key "site_measurements_line_friends", "line_friends"
  add_foreign_key "site_measurements_line_friends", "site_measurements"
  add_foreign_key "sites", "clients"
  add_foreign_key "sites", "folders"
  add_foreign_key "sites_line_friends", "line_friends"
  add_foreign_key "sites_line_friends", "sites"
  add_foreign_key "stream_routes", "clients"
  add_foreign_key "stream_routes", "folders"
  add_foreign_key "survey_answers", "survey_questions"
  add_foreign_key "survey_answers", "survey_responses"
  add_foreign_key "survey_questions", "surveys"
  add_foreign_key "survey_responses", "line_friends"
  add_foreign_key "survey_responses", "surveys"
  add_foreign_key "surveys", "folders"
  add_foreign_key "surveys", "line_accounts"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tags", "folders"
  add_foreign_key "tags", "line_accounts"
  add_foreign_key "template_messages", "templates"
  add_foreign_key "templates", "folders"
  add_foreign_key "templates", "line_accounts"
  add_foreign_key "users", "clients"
  add_foreign_key "variables", "folders"
  add_foreign_key "variables", "line_accounts"
end
