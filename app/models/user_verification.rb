class UserVerification < ActiveRecord::Base
  belongs_to :user
  
  def self.send_to_user(user)
  end
  
  
  def is_verified?
    if self.is_verified == "1"
      return true
    else 
      return false
    end
  end
  
  def send_email
    user = User.find(self.user_id)
    Emailer.verification_email(user, self).deliver
  end
  
  def self.generate_code # generate verification code
    return Digest::SHA256.hexdigest(Time.now.to_s)
  end 
end
