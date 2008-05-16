class Collection < ActiveRecord::Base

  acts_as_spoke :only => [:owners, :illustration, :discussion, :log, :undelete]
  belongs_to :account, :dependent => :destroy
  
  has_many :activations, :dependent => :destroy
  has_many :permissions, :dependent => :destroy
  has_many :users, :through => :permissions, :source => :user, :conditions => ['permissions.active = ?', true]
  has_many :sources, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :nodes, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :bundles, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :occasions, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :topics, :order => 'name', :dependent => :destroy, :conditions => "deleted_at IS NULL"
  has_many :events, :order => 'at DESC'
  
  cattr_accessor :current_collections

  has_finder :in_account, lambda { |account| {:conditions => { :account_id => account.id }} }
 
end
