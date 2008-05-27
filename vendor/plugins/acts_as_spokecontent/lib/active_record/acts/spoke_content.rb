require 'active_support'

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
          definitions = [:collection, :owners, :illustration, :organisation, :description, :annotation, :discussion, :index, :log, :undelete]
          if options[:except]
            definitions = definitions - Array(options[:except]) 
          elsif options[:only]
            definitions = definitions & Array(options[:only]) 
          end
        
          if definitions.include?(:index)
            is_indexed :fields => self.index_fields, :concatenate => self.index_concatenation
            Spoke::Associations.indexed_model(self)
          end
          
          if definitions.include?(:collection)
            if self.column_names.include?('collection_id')
              belongs_to :collection
              has_finder :in_collection, lambda { |collection| {:conditions => { :collection_id => collection.id }} }
              has_finder :in_collections, lambda { |collections| {:conditions => ["#{table_name}.collection_id in (" + collections.map{'?'}.join(',') + ")"] + collections.map { |c| c.id }} }
              Collection.can_catch(self)
            else
              logger.warn("!! #{self.to_s} should belong_to collection but has no collection_id column")
            end
          end
          
          if definitions.include?(:owners)
            belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
            belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
            has_finder :created_by_user, lambda { |user| {:conditions => { :created_by => user.id }} }
            if column_names.include?('speaker_id')
              belongs_to :speaker, :class_name => 'Person', :foreign_key => 'speaker_id'
              has_finder :spoken_by_person, lambda { |person| {:conditions => { :speaker_id => person.id }} }
            end
          end
          
          if definitions.include?(:illustration)
            if self.column_names.include?('clip')
              file_column :clip
            else
              logger.warn("!! #{self.to_s} should be illustrated but has no clip column")
            end
            if self.column_names.include?('image')
               file_column :image, :magick => { 
                 :versions => { 
                  "thumb" => "56x56!", 
                  "slide" => "135x135!", 
                  "illustration" => "240>", 
                  "preview" => "750x540>" 
                }
              }
            else
              logger.warn("!! #{self.to_s} should be illustrated but has no image column")
            end
          end
          
          if definitions.include?(:description)
            has_many :taggings, :as => :taggable, :dependent => :destroy
            has_many :tags, :through => :taggings
            self.can_catch(Tag)
            self.can_drop(Tag)
            Tag.can_catch(self)
            has_many :flaggings, :as => :flaggable, :dependent => :destroy
            has_many :flags, :through => :flaggings
            self.can_catch(Flag)
            self.can_drop(Flag)
            Flag.can_catch(self)
            Spoke::Associations.described_model(self)
          end

          if definitions.include?(:organisation)
            has_many :paddings, :as => :scrap, :dependent => :destroy
            has_many :scratchpads, :through => :paddings       
            Scratchpad.can_catch(self)
            Scratchpad.can_drop(self)
            has_many :bundlings, :as => :member, :dependent => :destroy
            has_many :bundles, :through => :bundlings, :source => :superbundle      
            Bundle.can_catch(self)
            Bundle.can_drop(self)
            Spoke::Associations.organised_model(self)
          end

          if definitions.include?(:annnotation)
            has_many :annotations, :as => :annotated, :dependent => :destroy
            Spoke::Associations.annotated_model(self)
          end

          if definitions.include?(:discussion)
            has_many :topics, :as => :referent, :dependent => :destroy
            Spoke::Associations.discussed_model(self)
          end

          if definitions.include?(:log)
            has_many :logged_events, :class_name => 'Event', :as => :affected, :order => 'at DESC'
            Spoke::Associations.logged_model(self)
          end
          
          if definitions.include?(:undelete)
            if self.column_names.include?('deleted_at')
              acts_as_paranoid
            else
              logger.warn("!! #{self.to_s} should be paranoid but has no deleted_at column")
            end
          end
          
          self.module_eval("include InstanceMethods")
        end
                
        def index_fields
          [
            'name', 'description', 'body', 
            'created_at', 'collection_id', 'created_by'   # these are faceted
          ]
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
        
        def per_page
          50
        end
        
        def nice_title
          self.to_s.downcase
        end        
         
      end #classmethods
      
      module InstanceMethods
        
        public
        
        def nice_title
          self.class.nice_title
        end        

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

        def is_discussable?
          true if self.class.reflect_on_association(:topics)
        end

        def has_topics?
          is_discussable? && topics.count > 0
        end

        def is_taggable?
          true if self.class.reflect_on_association(:tags)
        end
        
        def has_tags?
          is_taggable? && tags.count > 0
        end

        def tag_list
          tags.map {|t| t.name }.uniq.join(', ') if has_tags?
        end

        def has_members?
          self.respond_to?('members') && self.members.count > 0
        end
        
        def has_circumstances?
          self.respond_to?('circumstances') && !self.circumstances.nil? and self.circumstances.length != 0
        end
        
        def is_notable?
          respond_to?('observations') || respond_to?('emotions') || respond_to?('arising')
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

        def has_body?
          self.respond_to?('body') && !self.body.nil? and self.body.length != 0
        end

        def has_description?
          self.respond_to?('description') && !self.description.nil? and self.description.length != 0
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

        def has_monitorships?
          self.respond_to?('monitorships') && self.monitorships.count > 0
        end

        def has_sources?
          self.respond_to?('sources') && self.sources.count > 0
        end

        def has_nodes?
          self.respond_to?('nodes') && self.nodes.count > 0
        end
        
        def has_bundles?
          self.respond_to?('bundles') && self.bundles.count > 0
        end

        def editable_by?(user)
          user && (user.id == created_by || user.admin?)
        end

        def find_some_text
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
          ['circumstances', 'observations', 'emotions', 'arising'].map { |col| self.send(col) || ''}.join("\n\n")
        end
        
      end #instancemethods
      
    end #spokecontent
  end #acts
end #ar
