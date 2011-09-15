class CreatePluginFiles < ActiveRecord::Migration
  def self.up
    create_table :plugin_files do |t|
      t.column :item_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false
      t.string :title, :default => "" #  link title Ie: "Download Link"
      t.string :size, :default => "" #  link title Ie: "Download Link"
      t.string :filename # file name
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
      t.column :downloads, :integer, :default => 0          
    end
    
    # Create Files Folder
    files_path = "#{Rails.root.to_s}/files/item_files"
    FileUtils.mkdir_p(files_path) if !File.exist?(files_path) # createthe folder if it doesn't exist    
  end

  def self.down
    drop_table :plugin_files
    
    # Remove Files Folder
    files_path = "#{Rails.root.to_s}/files/item_files"
    FileUtils.rm_rf(files_path) if File.exist?(files_path) # remove the folder if it exists    
  end
end
