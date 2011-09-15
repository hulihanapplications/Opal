class Authentication < ActiveRecord::Base
  belongs_to :user    

  validates :user_id, :uid, :provider, :presence => true
  validates_uniqueness_of :uid, :scope => :provider
  #validates_numericality_of :user_id, :greater_than => 0   

  attr_accessible :user_id, :provider, :uid
  
  AUTHFILE = File.join(Rails.root.to_s, "config", "providers.yml")
  
  def self.providers # return list and credentials of providers 
    if File.exists?(Authentication::AUTHFILE)
      auth = YAML::load(File.open(Authentication::AUTHFILE))
      return auth ? auth["providers"] : Hash.new
    else 
      return Hash.new
    end    
  end
  
  def self.config # git entire config file hash
    if File.exists?(Authentication::AUTHFILE)
      auth = YAML::load(File.open(Authentication::AUTHFILE))
      return auth
    else 
      return Hash.new
    end     
  end  
end
