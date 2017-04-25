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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161129152334) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles_tags", id: false, force: :cascade do |t|
    t.integer "article_id"
    t.integer "tag_id"
  end

  create_table "blogs", force: :cascade do |t|
    t.text   "settings"
    t.string "base_url"
  end

  create_table "campaign_links", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.string   "link_type"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "primary"
  end

  add_index "campaign_links", ["campaign_id"], name: "index_campaign_links_on_campaign_id", using: :btree
  add_index "campaign_links", ["primary"], name: "index_campaign_links_on_primary", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "active",            default: false
    t.string   "hero_image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "primary_link_id"
    t.integer  "secondary_link_id"
    t.boolean  "full_bleed"
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "contents", force: :cascade do |t|
    t.string   "type"
    t.string   "title"
    t.string   "author"
    t.text     "body"
    t.text     "extended"
    t.text     "excerpt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "permalink"
    t.string   "guid"
    t.integer  "text_filter_id"
    t.text     "whiteboard"
    t.string   "name"
    t.boolean  "published",                    default: false
    t.boolean  "allow_pings"
    t.boolean  "allow_comments"
    t.datetime "published_at"
    t.string   "state"
    t.integer  "parent_id"
    t.text     "settings"
    t.string   "post_type",                    default: "read"
    t.string   "hero_image"
    t.string   "hero_image_alt_text"
    t.string   "teaser_image"
    t.string   "teaser_image_alt_text"
    t.string   "core_content_text"
    t.string   "core_content_url"
    t.string   "title_meta_tag"
    t.string   "description_meta_tag"
    t.integer  "primary_related_content_id"
    t.integer  "secondary_related_content_id"
    t.boolean  "supports_amp",                 default: true
  end

  add_index "contents", ["published"], name: "index_contents_on_published", using: :btree
  add_index "contents", ["text_filter_id"], name: "index_contents_on_text_filter_id", using: :btree

  create_table "contents_most_popular_articles", force: :cascade do |t|
    t.integer "article_id"
    t.integer "most_popular_article_id"
  end

  create_table "feedback", force: :cascade do |t|
    t.string   "type"
    t.string   "title"
    t.string   "author"
    t.text     "body"
    t.text     "excerpt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "guid"
    t.integer  "text_filter_id"
    t.text     "whiteboard"
    t.integer  "article_id"
    t.string   "email"
    t.string   "url"
    t.string   "ip",               limit: 40
    t.string   "blog_name"
    t.boolean  "published",                   default: false
    t.datetime "published_at"
    t.string   "state"
    t.boolean  "status_confirmed"
    t.string   "user_agent"
  end

  add_index "feedback", ["article_id"], name: "index_feedback_on_article_id", using: :btree
  add_index "feedback", ["text_filter_id"], name: "index_feedback_on_text_filter_id", using: :btree

  create_table "most_popular_articles", force: :cascade do |t|
  end

  create_table "page_caches", force: :cascade do |t|
    t.string "name"
  end

  add_index "page_caches", ["name"], name: "index_page_caches_on_name", using: :btree

  create_table "pings", force: :cascade do |t|
    t.integer  "article_id"
    t.string   "url"
    t.datetime "created_at"
  end

  add_index "pings", ["article_id"], name: "index_pings_on_article_id", using: :btree

  create_table "post_types", force: :cascade do |t|
    t.string "name"
    t.string "permalink"
    t.string "description"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "label"
    t.string "nicename"
    t.text   "modules"
  end

  create_table "profiles_rights", id: false, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "right_id"
  end

  create_table "redirections", force: :cascade do |t|
    t.integer "content_id"
    t.integer "redirect_id"
  end

  create_table "redirects", force: :cascade do |t|
    t.string   "from_path"
    t.string   "to_path"
    t.string   "origin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", force: :cascade do |t|
    t.integer  "size"
    t.string   "upload"
    t.string   "mime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "article_id"
    t.boolean  "itunes_metadata"
    t.string   "itunes_author"
    t.string   "itunes_subtitle"
    t.integer  "itunes_duration"
    t.text     "itunes_summary"
    t.string   "itunes_keywords"
    t.string   "itunes_category"
    t.boolean  "itunes_explicit"
  end

  create_table "sidebars", force: :cascade do |t|
    t.integer "active_position"
    t.text    "config"
    t.integer "staged_position"
    t.string  "type"
  end

  create_table "sitealizer", force: :cascade do |t|
    t.string   "path"
    t.string   "ip"
    t.string   "referer"
    t.string   "language"
    t.string   "user_agent"
    t.datetime "created_at"
    t.date     "created_on"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
  end

  create_table "text_filters", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "markup"
    t.text   "filters"
    t.text   "params"
  end

  create_table "triggers", force: :cascade do |t|
    t.integer  "pending_item_id"
    t.string   "pending_item_type"
    t.datetime "due_at"
    t.string   "trigger_method"
  end

  create_table "users", force: :cascade do |t|
    t.string   "login"
    t.string   "password"
    t.text     "email"
    t.text     "name"
    t.boolean  "notify_via_email"
    t.boolean  "notify_on_new_articles"
    t.boolean  "notify_on_comments"
    t.integer  "profile_id"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "text_filter_id",            default: "1"
    t.string   "state",                     default: "active"
    t.datetime "last_connection"
    t.text     "settings"
    t.integer  "resource_id"
  end

end
