class Tagging < ActiveRecord::Base

  is_material :only => [:undelete, :owners]

  belongs_to :tag
  belongs_to :collection  # shortcut for collection cloud. collection link is set by tagging_observer
  belongs_to :taggable, :polymorphic => true
  before_save :get_collection
  
  named_scope :of, lambda {|object| { :conditions => {:taggable_type => object.class.to_s, :taggable_id => object.id} } }
  
  named_scope :in_collection, lambda { |collection| {:conditions => { :collection_id => collection.id }} }
  named_scope :in_collections, lambda { |collections| {:conditions => ["#{table_name}.collection_id in (" + collections.map{'?'}.join(',') + ")"] + collections.map { |c| c.id }} }
  named_scope :grouped_with_popularity, {
    :select => "taggings.*, count(taggings.id) as use_count", 
    :group => "taggings.tag_id", 
    :order => 'use_count DESC',
    :include => :tag
  }

  def get_collection
    self.collection_id = self.taggable.collection_id
  end

end
