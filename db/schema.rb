# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110921212447) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "category_id", :default => 0
    t.string   "image_url"
    t.string   "description", :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "categories", ["ancestry"], :name => "index_categories_on_ancestry"

  create_table "group_plugin_permissions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "plugin_id"
    t.string   "can_create",        :limit => 1, :default => "0"
    t.string   "can_read",          :limit => 1, :default => "0"
    t.string   "can_update",        :limit => 1, :default => "0"
    t.string   "can_delete",        :limit => 1, :default => "0"
    t.string   "requires_approval", :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "is_deletable", :limit => 1, :default => "1"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "item_id"
    t.integer  "user_id"
    t.string   "url",                      :default => ""
    t.string   "thumb_url",                :default => ""
    t.string   "width",                    :default => "0"
    t.string   "height",                   :default => "0"
    t.string   "description",              :default => ""
    t.string   "is_approved", :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "category_id",               :default => 1
    t.string   "is_approved",  :limit => 1, :default => "0"
    t.string   "is_public",    :limit => 1, :default => "1"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",                  :default => false
    t.integer  "views",                     :default => 0
    t.integer  "recent_views",              :default => 0
    t.boolean  "locked",                    :default => false
    t.string   "preview_type"
    t.integer  "preview_id"
  end

  create_table "logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.string   "log"
    t.string   "log_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "target_type"
    t.integer  "target_id"
    t.string   "ip"
    t.string   "archived_target"
  end

  create_table "page_comments", :force => true do |t|
    t.integer  "page_id"
    t.integer  "user_id"
    t.text     "comment"
    t.string   "anonymous_email"
    t.string   "anonymous_name"
    t.string   "is_approved",     :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "page_id",              :default => 0
    t.integer  "user_id"
    t.string   "name"
    t.string   "title",                :default => ""
    t.string   "description",          :default => ""
    t.string   "page_type",            :default => "public"
    t.text     "content"
    t.boolean  "deletable",            :default => true
    t.boolean  "title_editable",       :default => true
    t.boolean  "description_editable", :default => true
    t.boolean  "content_editable",     :default => true
    t.boolean  "published",            :default => true
    t.boolean  "locked",               :default => false
    t.integer  "order_number"
    t.boolean  "display_in_menu",      :default => true
    t.boolean  "redirect",             :default => false
    t.string   "redirect_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "pages", ["ancestry"], :name => "index_pages_on_ancestry"

  create_table "plugin_comments", :force => true do |t|
    t.integer  "user_id"
    t.text     "comment"
    t.string   "is_approved",     :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "anonymous_email"
    t.string   "anonymous_name"
    t.integer  "up_votes",                     :default => 0
    t.integer  "down_votes",                   :default => 0
    t.string   "ancestry"
    t.string   "record_type"
    t.integer  "record_id"
  end

  add_index "plugin_comments", ["ancestry"], :name => "index_plugin_comments_on_ancestry"

  create_table "plugin_descriptions", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                    :default => ""
    t.text     "content"
    t.string   "is_approved", :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "record_type"
    t.integer  "record_id"
  end

  create_table "plugin_discussion_posts", :force => true do |t|
    t.integer  "plugin_discussion_id"
    t.integer  "user_id"
    t.text     "post"
    t.string   "is_sticky",            :limit => 1, :default => "1"
    t.string   "is_enabled",           :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plugin_discussions", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "description"
    t.string   "is_sticky",   :limit => 1, :default => "0"
    t.string   "is_approved", :limit => 1, :default => "0"
    t.string   "is_closed",   :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "record_type"
    t.integer  "record_id"
  end

  create_table "plugin_feature_value_options", :force => true do |t|
    t.integer  "plugin_feature_id"
    t.integer  "user_id"
    t.string   "value"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plugin_feature_values", :force => true do |t|
    t.integer  "plugin_feature_id"
    t.integer  "user_id"
    t.string   "value",                          :default => ""
    t.string   "is_approved",       :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "record_type"
    t.integer  "record_id"
  end

  create_table "plugin_features", :force => true do |t|
    t.string   "name",          :default => ""
    t.integer  "order_number",  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_url"
    t.string   "description"
    t.string   "search_type",   :default => "Grouped"
    t.boolean  "is_required",   :default => false
    t.string   "feature_type",  :default => "text"
    t.string   "default_value"
    t.float    "min"
    t.float    "max"
    t.boolean  "listed",        :default => true
    t.integer  "category_id"
  end

  create_table "plugin_files", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",                    :default => ""
    t.string   "filename"
    t.string   "is_approved", :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "downloads",                :default => 0
    t.string   "record_type"
    t.integer  "record_id"
    t.string   "file"
  end

  create_table "plugin_images", :force => true do |t|
    t.integer  "user_id"
    t.string   "width",                    :default => "0"
    t.string   "height",                   :default => "0"
    t.string   "description",              :default => ""
    t.string   "is_approved", :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "record_type"
    t.integer  "record_id"
    t.string   "image"
  end

  create_table "plugin_links", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "url"
    t.string   "is_approved", :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "record_type"
    t.integer  "record_id"
  end

  create_table "plugin_review_votes", :force => true do |t|
    t.integer  "plugin_review_id"
    t.integer  "user_id"
    t.integer  "score",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plugin_reviews", :force => true do |t|
    t.integer  "user_id"
    t.float    "review_score",                           :default => 0.0
    t.text     "review"
    t.string   "is_approved",               :limit => 1, :default => "0"
    t.integer  "useful_score",                           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_score",                             :default => 0
    t.integer  "up_votes",                               :default => 0
    t.integer  "down_votes",                             :default => 0
    t.integer  "plugin_review_category_id"
    t.string   "record_type"
    t.integer  "record_id"
  end

  create_table "plugin_settings", :force => true do |t|
    t.integer  "plugin_id"
    t.string   "name"
    t.string   "setting_type"
    t.string   "value"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "options"
  end

  create_table "plugin_tags", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id",                :default => 0
    t.string   "name"
    t.string   "is_approved", :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "record_type"
    t.integer  "record_id"
  end

  add_index "plugin_tags", ["name"], :name => "index_plugin_tags_on_name"

  create_table "plugin_videos", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.text     "code"
    t.string   "is_approved", :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "record_type"
    t.integer  "record_id"
    t.string   "video"
  end

  create_table "plugins", :force => true do |t|
    t.string   "name"
    t.integer  "order_number",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "is_enabled",   :limit => 1, :default => "1"
    t.string   "is_builtin",   :limit => 1, :default => "0"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string  "name"
    t.string  "setting_type"
    t.string  "value"
    t.string  "item_type"
    t.string  "options"
    t.string  "record_type"
    t.integer "record_id"
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "user_infos", :force => true do |t|
    t.integer  "user_id"
    t.string   "street_address",                      :default => ""
    t.string   "city",                                :default => ""
    t.string   "state",                               :default => ""
    t.string   "zip",                                 :default => ""
    t.string   "country",                             :default => ""
    t.text     "description"
    t.string   "interests",                           :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "use_gravatar",           :limit => 1, :default => "0"
    t.string   "location",                            :default => ""
    t.string   "forgot_password_code"
    t.boolean  "notify_of_new_messages",              :default => true
    t.boolean  "notify_of_item_changes",              :default => true
  end

  create_table "user_messages", :force => true do |t|
    t.text     "message"
    t.integer  "user_id"
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.integer  "reply_to_message_id",              :default => 0
    t.string   "is_read",             :limit => 1, :default => "0"
    t.boolean  "is_deletable",                     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_verifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "code",                           :default => "0000000000000000"
    t.string   "referrer"
    t.string   "ip"
    t.datetime "verification_date"
    t.string   "is_verified",       :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password_hash"
    t.string   "is_verified",         :limit => 1, :default => "0"
    t.string   "is_disabled",         :limit => 1, :default => "0"
    t.string   "is_admin",            :limit => 1, :default => "0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "registered_ip",                    :default => "0.0.0.0"
    t.string   "last_login_ip",                    :default => "0.0.0.0"
    t.integer  "group_id",                         :default => 2
    t.string   "locale"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.string   "single_access_token"
    t.integer  "login_count",                      :default => 0
    t.integer  "failed_login_count",               :default => 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "salt"
    t.string   "avatar"
  end

  create_table "votings", :force => true do |t|
    t.string   "voteable_type"
    t.integer  "voteable_id"
    t.string   "voter_type"
    t.integer  "voter_id"
    t.boolean  "up_vote",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votings", ["voteable_type", "voteable_id", "voter_type", "voter_id"], :name => "unique_voters", :unique => true
  add_index "votings", ["voteable_type", "voteable_id"], :name => "index_votings_on_voteable_type_and_voteable_id"
  add_index "votings", ["voter_type", "voter_id"], :name => "index_votings_on_voter_type_and_voter_id"

end
