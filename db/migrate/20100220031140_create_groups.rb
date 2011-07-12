class CreateGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base ;  end # override model to bypass validations, etc.
  def self.up
    create_table :groups do |t|
      t.column :name, :string, :nil => false
      t.column :description, :string, :nil => false
      t.string :is_deletable, :limit => 1, :default => "1" # can this group be deleted?      
      t.timestamps
    end

	public_group = Group.new(:name => I18n.t('seeds.group.public.name'), :description => I18n.t('seeds.group.public.description'))
	public_group.is_deletable = "0"
	public_group.save     
	users_group = Group.new(:name => I18n.t('seeds.group.users.name'), :description => I18n.t('seeds.group.users.description'))
	users_group.is_deletable = "0"
	users_group.save   
	admin_group = Group.new(:name => I18n.t('seeds.group.admin.name'), :description => I18n.t('seeds.group.admin.description'))
	admin_group.is_deletable = "0"
	admin_group.save  	    
  end

  def self.down
    drop_table :groups
  end
end
