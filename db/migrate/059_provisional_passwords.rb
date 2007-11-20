class ProvisionalPasswords < ActiveRecord::Migration
  def self.up
    add_column :users, :new_password, :string
    add_column :users, :last_login, :datetime
  end

  def self.down
    remove_column :users, :last_login
  end
end