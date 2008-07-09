class Person < ActiveRecord::Base

  acts_as_spoke :except => :index
  
  has_many :sources, :class_name => 'Source', :foreign_key => 'speaker_id'
  has_many :nodes, :class_name => 'Node', :foreign_key => 'speaker_id'
  has_one :user
  
  validates_presence_of :name, :description, :collection

  def self.nice_title
    "person"
  end

end
