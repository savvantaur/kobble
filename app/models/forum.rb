class Forum < ActiveRecord::Base
  belongs_to :collection
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  acts_as_list


  validates_presence_of :name

  has_many :topics, :order => 'sticky desc, replied_at desc', :dependent => :destroy do
    def first
      @first_topic ||= find(:first)
    end
  end

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, :class_name => 'Topic', :order => 'replied_at desc' do 
    def first 
      @first_recent_topic ||= find(:first) 
    end 
  end

  has_many :posts, :order => 'posts.created_at desc' do
    def last
      @last_post ||= find(:first, :include => :creator)
    end
  end

  acts_as_catcher :topics
  
  def visible_to?(user)
    return true unless visibility.nil? or visibility == 0
    return false if user.status.nil? or user.status == 0
    visibility >= user.status
  end

end
