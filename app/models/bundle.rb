class Bundle < ActiveRecord::Base

  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  belongs_to :collection

  has_many_polymorphs :members, :as => 'superbundle', :from => [:nodes, :sources, :tags, :bundles, :questions]

end
