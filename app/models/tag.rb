class Tag < ActiveRecord::Base

  acts_as_spoke :except => [:collection, :index, :description]
  has_many :taggings, :dependent => :destroy
  belongs_to :account
  has_finder :in_account, lambda { |account| {:conditions => { :account_id => account.id }} }

  def stem
    name.split.map{|w| w.stem}.join('_')
  end
  
  def subsume(subsumed)
    self.taggings += subsumed.taggings
    self.flags += subsumed.flags
    self.description = subsumed.description if self.description.nil? or self.description.size == 0
    self.body = subsumed.body if self.body.nil? or self.body.size == 0
    self.image = subsumed.image if self.image.nil? or self.image.size == 0
    self.clip = subsumed.clip if self.clip.nil? or self.clip.size == 0
    self.emotions = subsumed.clip if self.emotions.nil? or self.emotions.size == 0
    self.arising = subsumed.clip if self.arising.nil? or self.arising.size == 0
    self.observations = subsumed.observations if self.observations.nil? or self.observations.size == 0
    subsumed.destroy
    CatchResponse.new("#{subsumed.name} merged into #{self.name}", "delete")
  end
    
  def self.from_list(taglist)
    taglist.split(/[,;]\s*/).uniq.map { |t| Tag.find_or_create_by_name(t) }
  end

  def tagged_items
    taggings.map{|t| t.taggable }
  end


end

