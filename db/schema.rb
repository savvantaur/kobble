# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 72) do

  create_table "answers", :force => true do |t|
    t.column "question_id",   :integer
    t.column "body",          :text
    t.column "image",         :string
    t.column "clip",          :string
    t.column "collection_id", :integer
    t.column "created_at",    :datetime
    t.column "created_by",    :integer
    t.column "updated_at",    :datetime
    t.column "updated_by",    :integer
    t.column "speaker_id",    :integer
  end

  create_table "blogentries", :force => true do |t|
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "name",          :string
    t.column "introduction",  :text
    t.column "body",          :text
    t.column "collection_id", :integer
    t.column "node_id",       :string
    t.column "image",         :string
    t.column "clip",          :string
    t.column "caption",       :text
  end

  create_table "bundles", :force => true do |t|
    t.column "name",           :string
    t.column "user_id",        :integer
    t.column "clustertype_id", :integer
    t.column "body",           :text
    t.column "collection_id",  :integer
    t.column "created_by",     :integer
    t.column "updated_by",     :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
    t.column "observations",   :text
    t.column "emotions",       :text
    t.column "arising",        :text
    t.column "image",          :string
    t.column "synopsis",       :string
  end

  add_index "bundles", ["collection_id"], :name => "index_bundles_on_collection"

  create_table "collections", :force => true do |t|
    t.column "user_id",            :integer
    t.column "name",               :string
    t.column "description",        :text
    t.column "status",             :string,   :limit => 20, :default => "0"
    t.column "created_by",         :integer
    t.column "updated_by",         :integer
    t.column "created_at",         :datetime
    t.column "updated_at",         :datetime
    t.column "allow_registration", :integer
    t.column "invitation",         :text
    t.column "welcome",            :text
    t.column "privacy",            :text
    t.column "abbreviation",       :string
    t.column "url",                :string
    t.column "background",         :text
    t.column "faq",                :text
    t.column "blog_forum_id",      :integer
    t.column "editorial_forum_id", :integer
    t.column "survey_forum_ud",    :integer
    t.column "email_from",         :string
  end

  create_table "forums", :force => true do |t|
    t.column "name",             :string
    t.column "description",      :string
    t.column "topics_count",     :integer,  :default => 0
    t.column "posts_count",      :integer,  :default => 0
    t.column "position",         :integer
    t.column "description_html", :text
    t.column "collection_id",    :integer
    t.column "created_at",       :datetime
    t.column "created_by",       :integer
    t.column "updated_at",       :datetime
    t.column "updated_by",       :integer
    t.column "visibility",       :integer,  :default => 0
    t.column "image",            :string
  end

  create_table "marks_tags", :force => true do |t|
    t.column "tag_id",    :integer
    t.column "mark_type", :string,  :limit => 20
    t.column "mark_id",   :integer
  end

  add_index "marks_tags", ["mark_type", "mark_id"], :name => "index_tag_marks"

  create_table "members_superbundles", :force => true do |t|
    t.column "superbundle_id", :integer
    t.column "member_id",      :integer
    t.column "member_type",    :string,  :limit => 20
    t.column "position",       :integer
  end

  add_index "members_superbundles", ["member_type", "member_id"], :name => "index_bundle_members"

  create_table "monitorships", :force => true do |t|
    t.column "topic_id", :integer
    t.column "user_id",  :integer
    t.column "active",   :boolean, :default => true
  end

  create_table "nodes", :force => true do |t|
    t.column "name",           :string
    t.column "synopsis",       :text
    t.column "notes",          :text
    t.column "body",           :text
    t.column "speaker_id",     :integer
    t.column "source_id",      :integer
    t.column "status",         :string
    t.column "rating",         :integer
    t.column "image",          :string
    t.column "clip",           :string
    t.column "playfrom",       :integer,  :limit => 10, :precision => 10, :scale => 0
    t.column "playto",         :integer,  :limit => 10, :precision => 10, :scale => 0
    t.column "keywords_count", :integer
    t.column "collection_id",  :integer
    t.column "created_by",     :integer
    t.column "updated_by",     :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
    t.column "observations",   :text
    t.column "emotions",       :text
    t.column "arising",        :text
    t.column "question_id",    :integer
    t.column "circumstances",  :text
    t.column "original_text",  :text
  end

  add_index "nodes", ["collection_id"], :name => "index_nodes_on_collection"
  add_index "nodes", ["source_id"], :name => "index_nodes_on_source"
  add_index "nodes", ["question_id"], :name => "index_nodes_on_question"

  create_table "occasions", :force => true do |t|
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "name",          :string
    t.column "description",   :text
    t.column "image",         :string
    t.column "clip",          :string
    t.column "collection_id", :integer
  end

  create_table "offenders_warnings", :force => true do |t|
    t.column "warning_id",    :integer
    t.column "offender_type", :string,  :limit => 20
    t.column "offender_id",   :integer
  end

  create_table "posts", :force => true do |t|
    t.column "topic_id",      :integer
    t.column "body",          :text
    t.column "forum_id",      :integer
    t.column "body_html",     :text
    t.column "collection_id", :integer
    t.column "created_at",    :datetime
    t.column "created_by",    :integer
    t.column "updated_at",    :datetime
    t.column "updated_by",    :integer
  end

  add_index "posts", ["forum_id", "created_at"], :name => "index_posts_on_forum_id"
  add_index "posts", ["created_by", "created_at"], :name => "index_posts_oncreator_id"

  create_table "questions", :force => true do |t|
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "prompt",        :text
    t.column "guidance",      :text
    t.column "observations",  :text
    t.column "emotions",      :text
    t.column "arising",       :text
    t.column "survey_id",     :integer
    t.column "collection_id", :integer
    t.column "user_group_id", :integer
    t.column "question_type", :string
    t.column "request_image", :integer
    t.column "request_clip",  :integer
    t.column "name",          :string
    t.column "introduction",  :text
    t.column "image",         :string
    t.column "clip",          :string
    t.column "dull",          :integer
  end

  create_table "scraps_scratchpads", :force => true do |t|
    t.column "scratchpad_id", :integer
    t.column "scrap_type",    :string,  :limit => 20
    t.column "scrap_id",      :integer
    t.column "position",      :integer
  end

  add_index "scraps_scratchpads", ["scrap_type", "scrap_id"], :name => "index_scratchpad_scraps"

  create_table "scratchpads", :force => true do |t|
    t.column "name",    :string
    t.column "user_id", :integer
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "sources", :force => true do |t|
    t.column "name",          :string
    t.column "notes",         :text
    t.column "synopsis",      :text
    t.column "speaker_id",    :integer
    t.column "body",          :text
    t.column "clip",          :string
    t.column "duration",      :integer,  :limit => 10,  :precision => 10, :scale => 0
    t.column "rating",        :integer
    t.column "collection_id", :integer
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "observations",  :text
    t.column "emotions",      :text
    t.column "arising",       :text
    t.column "image",         :string
    t.column "circumstances", :text
    t.column "occasion_id",   :integer
    t.column "file",          :string,   :limit => 355
  end

  add_index "sources", ["collection_id"], :name => "index_sources_on_collection"

  create_table "surveys", :force => true do |t|
    t.column "created_by",    :integer
    t.column "updated_by",    :integer
    t.column "created_at",    :datetime
    t.column "updated_at",    :datetime
    t.column "title",         :string
    t.column "description",   :text
    t.column "collection_id", :integer
  end

  create_table "tags", :force => true do |t|
    t.column "parent_id",      :integer
    t.column "name",           :string
    t.column "description",    :text
    t.column "colour",         :string,   :limit => 7
    t.column "nodes",          :integer
    t.column "keywords_count", :integer
    t.column "user_id",        :integer
    t.column "created_by",     :integer
    t.column "updated_by",     :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
    t.column "collection_id",  :integer
    t.column "image",          :string
  end

  create_table "topics", :force => true do |t|
    t.column "forum_id",      :integer
    t.column "title",         :string
    t.column "hits",          :integer,  :default => 0
    t.column "sticky",        :integer,  :default => 0
    t.column "posts_count",   :integer,  :default => 0
    t.column "replied_at",    :datetime
    t.column "locked",        :boolean,  :default => false
    t.column "replied_by",    :integer
    t.column "last_post_id",  :integer
    t.column "collection_id", :integer
    t.column "speaker_id",    :integer
    t.column "created_at",    :datetime
    t.column "created_by",    :integer
    t.column "updated_at",    :datetime
    t.column "updated_by",    :integer
    t.column "subject_type",  :string
    t.column "subject_id",    :integer
  end

  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"
  add_index "topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"

  create_table "user_groups", :force => true do |t|
    t.column "name",          :string
    t.column "description",   :string
    t.column "collection_id", :integer
    t.column "users_count",   :integer,  :default => 0
    t.column "created_at",    :datetime
    t.column "created_by",    :integer
    t.column "updated_at",    :datetime
    t.column "updated_by",    :integer
    t.column "prompt",        :string
  end

  create_table "users", :force => true do |t|
    t.column "login",                     :string,   :limit => 80, :default => "", :null => false
    t.column "crypted_password",          :string,   :limit => 40, :default => "", :null => false
    t.column "email",                     :string,   :limit => 60, :default => "", :null => false
    t.column "diminutive",                :string,   :limit => 40
    t.column "honorific",                 :string
    t.column "firstname",                 :string,   :limit => 40
    t.column "lastname",                  :string,   :limit => 40
    t.column "salt",                      :string,   :limit => 40, :default => "", :null => false
    t.column "verified",                  :integer,                :default => 0
    t.column "role",                      :string
    t.column "remember_token",            :string,   :limit => 40
    t.column "remember_token_expires_at", :datetime
    t.column "created_at",                :datetime
    t.column "updated_at",                :datetime
    t.column "logged_in_at",              :datetime
    t.column "deleted",                   :integer,                :default => 0
    t.column "delete_after",              :datetime
    t.column "collection_id",             :integer
    t.column "status",                    :integer,                :default => 10
    t.column "image",                     :string
    t.column "description",               :text
    t.column "created_by",                :integer
    t.column "updated_by",                :integer
    t.column "activated_at",              :datetime
    t.column "activation_code",           :string,   :limit => 40
    t.column "workplace",                 :string
    t.column "phone",                     :string
    t.column "posts_count",               :integer,                :default => 0
    t.column "last_seen_at",              :datetime
    t.column "postcode",                  :string
    t.column "new_password",              :string
    t.column "last_login",                :datetime
    t.column "password",                  :string
    t.column "user_group_id",             :integer
    t.column "receive_questions_email",   :integer
    t.column "receive_news_email",        :integer
    t.column "receive_html_email",        :integer
  end

  add_index "users", ["collection_id"], :name => "index_users_on_collection"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["last_seen_at"], :name => "index_users_on_last_seen_at"

  create_table "warnings", :force => true do |t|
    t.column "body",           :text
    t.column "offender_type",  :string,   :limit => 20
    t.column "offender_id",    :integer
    t.column "user_id",        :integer
    t.column "warningtype_id", :string
    t.column "created_by",     :integer
    t.column "updated_by",     :integer
    t.column "created_at",     :datetime
    t.column "updated_at",     :datetime
  end

end
