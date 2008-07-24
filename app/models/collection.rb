class Collection < ActiveRecord::Base

  before_destroy :reassign_associates
  acts_as_spoke :only => [:owners, :illustration, :discussion, :annotation, :log, :undelete]
  belongs_to :account
  
  has_many :activations, :dependent => :destroy
  has_many :permissions, :dependent => :destroy
  has_many :permitted_users, :through => :permissions, :conditions => ['permissions.active = ? or users.status > ?', true, 100], :source => :user
  has_many :sources, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :nodes, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :bundles, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :occasions, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :topics, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :events, :order => 'at DESC'
  
  validates_presence_of :name
  validates_presence_of :description
  validates_length_of :abbreviation, :maximum => 10

  # this is a nasty shortcut to allow collection tag clouds:
  # when item in collection is tagged, tagging is given collection link
  # otherwise polymorphism makes gathering collected-and-tagged objects horribly inefficient
  
  has_many :taggings  
  has_many :tags, :through => :taggings  
  
  cattr_accessor :current_collections

  named_scope :in_account, lambda { |account| {:conditions => { :account_id => account.id }} }

  def catch_this(object)
    if object.collection != self
      object.collection = self
      return CatchResponse.new("#{object.name} moved to #{self.name} collection", 'copy', 'success')
    else
      return CatchResponse.new("#{object.name} already in #{self.name} collection", 'copy', 'failure')
    end
  end
  
  def tags_with_popularity
    taggings = self.taggings.grouped_with_popularity
    taggings.each {|t| t.tag.used = t.use_count}
    taggings.map {|t| t.tag }.uniq.sort{|a,b| a.name <=> b.name}
  end
  
  def public?
    !private?
  end
  
end
