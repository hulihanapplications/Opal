class CreateUserVerifications < ActiveRecord::Migration
  def self.up
    create_table :user_verifications do |t|
      t.column :user_id, :integer, :nil => false
      t.column :code, :string, :default => "0000000000000000"
      t.column :referrer, :string
      t.column :ip, :string
      t.column :verification_date, :datetime      
      t.column :is_verified, :string,  :limit => 1, :default => "0" # has the user verified this link yet?      
      t.timestamps
    end
  end

  def self.down
    drop_table :user_verifications
  end
end
