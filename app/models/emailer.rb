class Emailer < ActionMailer::Base
  
  def contact_us_email(from = "noemailset@none.com", name = "No Name Set", subject = "No Subject Set", message = "No Message Set", ip = "0.0.0.0", display = "plain") 
     @recipients = Emailer.admin_emails
     @from = "#{from}"
     @subject = subject
     @sent_on = Time.now
     @body["message"] = message
     @body["from"] = from
     @body["name"] = name
     @body["display"] = display
     @body["ip"] = ip
     #@body["message"] = message
     if display == "plain"
       @content_type = "text/plain"
     elsif display == "html"
       @content_type = "text/html"
     end
     @headers = {}
  end
 
   
  def test_email(recipients, subject = "No Subject Set", message = "No Message Set.", sent_at = Time.now)
      @subject = subject
      @recipients = recipients
      @from = 'test@test.com'
      @sent_on = sent_at
      @body["email"] = 'test@test.com'
      @body["message"] = message
      @headers = {}
  end
  
  def verification_email(recipients, user_verification = UserVerification.new, url = "http://localhost/")
      @setting = Setting.global_settings
      @setting[:admin_email] = Setting.get_setting("admin_email")        
      @url = url
      @user_verification = user_verification      
      @recipients = recipients
      @from = "#{@setting[:title]}<noreply@none.com>"
      @sent_on = Time.now
      @headers = {}
      @subject = I18n.t("email.subject.verification", :name => @user_verification.user.username, :title => @setting[:title])       
  end  

  # Send an email with a modified from header 
  def email_from_anyone(recipients, from = "none@none.com", subject = "No Subject Set", message = "No Message Set.", sent_at = Time.now)
      @subject = subject
      @recipients = recipients
      @from = from
      @sent_on = sent_at
      @body["email"] = from
      @body["message"] = message
      @headers = {}
  end
  
  # Notify a User that a message was sent to them
  def new_message_notification(message, url = "http://localhost/")     
    @setting = Setting.global_settings
    @recipients = message.user.email
    @sent_on = Time.now    
    @message = message
    @url = url
    @from = "#{@setting[:title]}<noreply@none.com>"
    @subject = I18n.t("email.subject.object_new_from_user", :object => UserMessage.human_name, :from => @message.user_from.username, :name => "#{@message.user_from.first_name} #{@message.user_from.last_name}", :title => @setting[:title]) 
  end
  
  # Send User a password recovery email
  def password_recovery_email(user, url = "http://localhost/")
    @setting = Setting.global_settings     
    @recipients = user.email
    @sent_on = Time.now    
    @user = user
    @url = url          
    @from = "#{@setting[:title]}<noreply@none.com>"
    @subject = I18n.t("email.subject.object_new", :object => UserInfo.human_attribute_name(:forgot_password_code), :name => @user.username, :title => @setting[:title]) 
  end

  # Send New User Notification Email
  def new_user_notification(user, url = "http://localhost/")
    @setting = Setting.global_settings
    @recipients = Emailer.admin_emails
    @sent_on = Time.now    
    @user = user
    @url = url        
    @from = "#{@setting[:title]}<noreply@none.com>"
    @subject = I18n.t("email.subject.object_new", :object => User.human_name, :name => @user.username + " (#{@user.first_name} #{@user.last_name})", :title => @setting[:title])
  end
  
  # Send New Item Notification Email 
  def new_item_notification(item, url = "http://localhost/")
    @setting = Setting.global_settings
    @recipients = Emailer.admin_emails
    @sent_on = Time.now    
    @item = item
    @url = url           
    @from = "#{@setting[:title]}<noreply@none.com>"
    @subject = I18n.t("email.subject.object_new_from_user", :object => @setting[:item_name], :name => @item.name, :title => @setting[:title], :from => @item.user.username) 
  end
  
  private 
  
  def self.admin_emails # get all admin email addresses 
    admin_emails = Array.new 
    for user in User.admins
      admin_emails << user.email
    end
    return admin_emails.join(", ") # return email addresses in a csv string
  end
end
