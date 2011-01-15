class CreateUsers < ActiveRecord::Migration
  def self.up
  
    create_table :users do |t|
      t.column :username, :string, :nil => false
      t.column :email, :string, :nil => false    
      t.column :last_login, :datetime 
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :password_hash, :string
      t.column :is_verified, :string,  :limit => 1, :default => "0" # are they verified?
      t.column :is_disabled, :string,  :limit => 1, :default => "0" # are they disabled for being bad?      t.column :is_admin, :string, :limit => 1, :default => "0"
      t.column :is_admin, :string, :limit => 1, :default => "0"      
      t.column :created_at, :datetime#this will get populated automatically  
      t.column :updated_at, :datetime#this will get populated automatically
      t.column :registered_ip, :string, :default => "0.0.0.0" 
      t.column :last_login_ip, :string, :default => "0.0.0.0"  
      t.column :group_id, :integer, :default => 2 
      t.column :locale, :string, :default => nil
    end
    
    # Make Avatar Folder
    avatars_path = "#{Rails.root.to_s}/public/images/avatars"
    FileUtils.mkdir_p(avatars_path) if !File.exist?(avatars_path) # create the tmp folder if it doesn't exist
  end 

  def self.down
    # Remove Avatars Folder
    avatars_path = "#{Rails.root.to_s}/public/images/avatars"
    FileUtils.rm_rf(avatars_path) if File.exist?(avatars_path) # remove the folder if it exists    
    
    drop_table :users
    # clear out all avatars
    # Dave: I'm turning this off for now, because it will only delete the default avatars.
    #avatars_path = "#{Rails.root.to_s}/public/images/avatars"
    #FileUtils.rm_rf(avatars_path)     
    #FileUtils.mkdir(avatars_path) # remake the folder
    #FileUtils.cp("#{Rails.root.to_s}/default.png", avatars_path) # copy the default avatar into the recreated folder
    #FileUtils.cp("#{Rails.root.to_s}/1.png", avatars_path) # copy the admin avatar into the recreated folder
  end
end
