class CreateImages < ActiveRecord::Migration
  @images_path  = "#{Rails.root.to_s}/public/images/uploaded_images"
  
  def self.up
    # Create Images Folder
    FileUtils.mkdir_p(@images_path) if !File.exist?(@images_path) # remove the folder if it exists 
    
    create_table :images do |t|
      t.column :item_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false
      t.column :url, :string, :default => ""
      t.column :thumb_url, :string, :default => ""
      t.column :width, :string, :default => "0"
      t.column :height, :string, :default => "0" 
      t.column :description, :string, :default => ""
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.column :created_at, :datetime 
      t.column :updated_at, :datetime 
    end   
  end

  def self.down
    # Remove Images Folder
    FileUtils.rm_rf(@images_path) if File.exist?(@images_path) # remove the folder if it exists  
    
    drop_table :images      
  end
end
