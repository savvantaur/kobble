class Tag < ActiveRecord::Base
  acts_as_spoke
  has_many_polymorphs :taggables, :from => self.organised_classes(:except => :tags), :through => :taggings
  acts_as_tree :order => 'name'
  acts_as_catcher :taggables, {:tag => :subsume}

  def self.sort_options 
    {
      'name' => 'name',
      'date' => 'created_at',
      'popularity' => 'popularity',     # special case
    }
  end

  def subsume(subsumed)
    self.taggables << subsumed.taggables
    self.flags << subsumed.flags
    self.children << subsumed.children
    self.description = subsumed.description if self.description.nil? or self.description.size == 0
    self.image = subsumed.image if self.image.nil? or self.image.size == 0
    subsumed.destroy
    {
      :success => 'true',
      :message => "#{subsumed.name} folded into #{self.name}",
      :action => 'delete'
    }
  end
  
  def parentage
    return self unless self.parent
    return [self.parent.parentage, self]
  end
  
  def ancestry
    return unless self.parent
    return self.parent.parentage
  end  

  def self.find_or_create_branch(branch)
    name = branch.pop
    tag = (branch.nitems > 0) ?
      Tag.find(:first,
        :conditions => ["tags.name= ? AND tp.name = ?", name, branch[-1]], 
        :select => "tags.*", 
        :joins => "as tags inner join tags as tp on tags.parent_id = tp.id",
        :order => "tags.name") :
      Tag.find(:first,
        :conditions => ["name= ? AND parent_id IS NULL", name]);

    unless (tag)
      if (branch.nitems > 0)
        parent = Tag.find_or_create_branch(branch)
        tag = Tag.new(:name => name, :parent => parent)
      else
        tag = Tag.new(:name => name)
      end
      tag.save
    end
    return tag
  end

  def self.tags_with_popularity
    Tag.find(:all, 
      :select => "tags.*, count(taggings.id) as use_count",
      :joins => "LEFT JOIN taggings on taggings.tag_id = tags.id",
      :conditions => ["tags.parent_id = ?", self.id],
      :group => "taggings.tag_id",
      :order => 'use_count DESC'
    )
  end

  def children_with_count
    Tag.find(:all, 
      :select => "tags.*, count(taggings.id) as use_count",
      :joins => "LEFT JOIN taggings on taggings.tag_id = tags.id",
      :conditions => ["tags.parent_id = ?", self.id],
      :group => "taggings.tag_id",
      :order => 'name ASC'
    )
  end

end

