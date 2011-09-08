class UserMessage < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id, :from_user_id, :to_user_id
  
  default_scope :order => "created_at desc"
  
  after_create :notify
  
  attr_protected :user_id, :from_user_id
  
  def is_read? 
    if self.is_read == "1"
      return true
    else 
      return false
    end
  end
  
  def is_deletable? 
    if self.is_deletable == "1"
      return true
    else 
      return false
    end
  end

  def is_replied_to? # is this message a reply to another message?
    if self.reply_to_message_id != 0
      return true
    else 
      return false
    end
  end

  def message_replied_to # get the message this message is a reply to
    return UserMessage.find(self.reply_to_message_id)
  rescue # if message not found
    return nil
  end
  
  def user_to # get user this message was sent to
    return User.find(self.to_user_id)
  rescue # if user not found
    return nil
  end
  
  def user_from # get user sent this message 
    return User.find(self.from_user_id)
  rescue # if user not found
    return nil
  end
  
  def self.messages_from_user(user)
    return UserMessage.find(:all, :conditions => ["from_user_id = ?", user.id])
  end
  
  def notify
    Emailer.new_message_notification(self).deliver if self.user.user_info.notify_of_new_messages? # send notification email      
  end
end
