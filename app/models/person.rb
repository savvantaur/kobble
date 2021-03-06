class Person < ActiveRecord::Base

  is_material
  
  has_many :sources, :class_name => 'Source', :foreign_key => 'speaker_id'
  has_many :nodes, :class_name => 'Node', :foreign_key => 'speaker_id'
  has_one :user
  
  validates_presence_of :name, :description, :collection

  def sources_and_nodes
    everything = self.sources + self.nodes
    everything.sort{|a,b| a.name <=> b.name }
  end

  def self.nice_title
    "person"
  end

end
