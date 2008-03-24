require 'active_support'

module Spoke
  module Config
    @@indexed_models = []
    mattr_accessor :indexed_models
    @@discussed_models = []
    mattr_accessor :discussed_models
    
    def self.indexed_model(klass)
      unless @@indexed_models.detect {|k| k.to_s == klass.to_s}
        @@indexed_models.push(klass) 
      end
    end

    def self.discussed_model(klass)
      unless @@discussed_models.detect {|k| k.to_s == klass.to_s}
        @@discussed_models.push(klass) 
      end
    end
    
  end
end

module ActiveRecord
  module Acts #:nodoc:
    module SpokeContent #:nodoc:
      
      def self.included(base)
        base.extend(ClassMethods)
      end

      # This +acts_as+ extension consolidates common spoke functionality in one place for dryness.
      #
      # It defines one class method:
      #
      # acts_as_spoke
      #   which creates the standard ownership and collection relations
      #
      # :only and :except parameters can be supplied, so eg:
      #
      # acts_as_spoke :except => :illustration
      #
      # the options are:
      # :collection, :creator, :updater, :illustration, :discussion, :index
      #
      # by default all relations are created
      #
      # (which usually means that they're pushed onto class variable arrays that are used to define has_many_polymorphs relations after initialization)
      
      module ClassMethods

        def acts_as_spoke(options={})
          definitions = [:collection, :creator, :updater, :illustration, :discussion, :index]
          if options[:except]
            definitions = definitions - Array(options[:except]) 
          elsif options[:only]
            definitions = definitions & Array(options[:only]) 
          end
        
          if definitions.include?(:index)
            Spoke::Config.indexed_model(self)
            is_indexed :fields => self.index_fields, :concatenate => self.index_concatenation
          end
          if definitions.include?(:collection)
            belongs_to :collection
          end
          if definitions.include?(:creator)
            belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
          end
          if definitions.include?(:updater)
            belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
          end
          if definitions.include?(:illustration)
            file_column :clip
            file_column :image, :magick => { 
              :versions => { 
                "thumb" => "56x56!", 
                "slide" => "135x135!", 
                "preview" => "750x540>" 
              }
            }
          end
          if definitions.include?(:discussion)
            has_many :topics, :as => :referent
            Spoke::Config.discussed_model(self)
          end

          self.class_eval("include InstanceMethods")
        end

        def organised_classes(options={})
          oc = [:users, :sources, :nodes, :bundles, :people, :tags, :flags, :occasions, :topics, :posts]
          if options[:except]
            oc -= Array(options[:except]) 
          elsif options[:only]
            oc &= Array(options[:only]) 
          end
          oc
        end
        
        def index_fields
          ['name', 'description', 'body', 'created_by', 'created_at', 'collection_id']
        end

        def index_concatenation
          [{:fields => ['observations', 'arising', 'emotions'], :as => 'field_notes'}]
        end
        
        def sort_options
          {
            "name" => "name",
            "date" => "created_at DESC",
          }
        end

        def default_sort
          "name"
        end
        
        def nice_title
          self.to_s.downcase
        end
         
      end #classmethods
      
      module InstanceMethods
        
        public
        
        def owned_by
          return self.account if self.respond_to?('account')
          return self.collection.account if self.respond_to?('collection')
          return self.creator.account if self.respond_to?('creator')
        end
        
        def has_collection?
          self.respond_to?('collection') && !self.collection.nil?
        end

        def has_source?
          self.respond_to?('source') && !self.source.nil?
        end

        def has_tags?
          self.respond_to?('tags') && self.tags.count > 0
        end

        def tag_list
          self.respond_to?('tags') && tags.map {|t| t.name }.uniq.join(', ')
        end

        def has_members?
          self.respond_to?('members') && self.members.count > 0
        end
        
        def has_circumstances?
          self.respond_to?('circumstances') && !self.circumstances.nil? and self.circumstances.length != 0
        end

        def has_notes?
          (self.respond_to?('observations') && (observations.nil? || observations.size == 0)) && 
          (self.respond_to?('emotions') && (emotions.nil? || emotions.size == 0)) && 
          (self.respond_to?('arising') && (arising.nil? || arising.size == 0)) ? false : true
        end

        def has_origins?
          (self.respond_to?('source') && source.nil?) && 
          (self.respond_to?('speaker') && speaker.nil?) && 
          (self.respond_to?('creator') && creator.nil?) ? false : true
        end

        def has_synopsis?
          self.respond_to?('synopsis') && !self.synopsis.nil? and self.synopsis.length != 0
        end

        def has_body?
          self.respond_to?('body') && !self.body.nil? and self.body.length != 0
        end

        def has_description?
          self.respond_to?('description') && !self.description.nil? and self.description.length != 0
        end

        def has_synopsis?
          self.respond_to?('synopsis') && !self.synopsis.nil? and self.synopsis.length != 0
        end

        def has_extracted_text?
          self.respond_to?('extracted_text') && !self.extracted_text.nil? and self.extracted_text.length != 0
        end

        def has_image?
          self.respond_to?('image') && !self.image.nil? and File.file? self.image
        end

        def has_clip?
          self.respond_to?('clip') && !self.clip.nil?
        end
        
        def clip_exists?
          self.respond_to?('clip') && !self.clip.nil? and File.file? self.clip
        end

        def has_file?
          self.respond_to?('file') && !self.file.nil?
        end
        
        def file_exists?
          self.respond_to?('file') && !self.file.nil? and File.file? self.file
        end

        def filetype
          self.has_file? ? self.file_relative_path.split('.').last : nil
        end

        def has_topics?
          self.respond_to?('topics') && self.topics.count > 0
        end

        def has_posts?
          self.respond_to?('posts') && self.posts.count > 0
        end

        def has_marks?
          self.respond_to?('marks') && self.marks.count > 0
        end

        def has_answers?
          self.respond_to?('answers') && self.answers.count > 0
        end

        def editable_by?(user)
          user && (user.id == created_by || user.admin?)
        end

        def find_some_text
          return synopsis if has_synopsis?
          return description if has_description?
          return body if has_body?
          return extracted_text if has_extracted_text?
          "No text available"
        end
        
        def has_creator?
          self.respond_to?('creator') && !self.creator.nil?
        end
        
        def has_speaker?
          self.respond_to?('speaker') && !self.speaker.nil?
        end
 
        def main_person
          return speaker if has_speaker?
          return creator
        end
        
        def field_notes
          return self.observations + "\n\n" + self.emotions + "\n\n" + self.arising
        end
        
      end #instancemethods
      
    end #spokecontent
  end #acts
end #ar
