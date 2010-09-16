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
      @setting = Hash.new
      @setting[:admin_email] = Setting.get_setting("admin_email")
      @setting[:title] = Setting.get_setting("site_title")  
      @url = url
      @body[:user_verification] = user_verification
      
      @subject = "Verify your new account at #{@setting[:title]}"
      @recipients = recipients
      @from = "#{@setting[:title]}<noreply@none.com>"
      @sent_on = Time.now
      @headers = {}
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
    @setting = Hash.new
    @recipients = message.user.email
    @sent_on = Time.now    
    @message = message
    @url = url
    @setting[:title] = Setting.get_setting("site_title")      
    @from = "#{@setting[:title]}<noreply@none.com>"
    @subject = "#{@setting[:title]}: New message from #{message.user_from.username}"
  end
  
  # Send User a password recovery email
  def password_recovery_email(user, url = "http://localhost/")
    @setting = Hash.new
    @recipients = user.email
    @sent_on = Time.now    
    @user = user
    @url = url
    @setting[:title] = Setting.get_setting("site_title")      
    @from = "#{@setting[:title]}<noreply@none.com>"
    @subject = "#{@setting[:title]}: Recover Password"
  end

  # Send New User Notification Email
  def new_user_notification(user, url = "http://localhost/")
    @setting = Hash.new
    @recipients = Emailer.admin_emails
    @sent_on = Time.now    
    @user = user
    @url = url
    @setting[:title] = Setting.get_setting("site_title")      
    @from = "#{@setting[:title]}<noreply@none.com>"
    @subject = "#{@setting[:title]}: New User - #{@user.username}"
  end
  
  # Send New Item Notification Email 
  def new_item_notification(item, url = "http://localhost/")
    @setting = Hash.new
    @recipients = Emailer.admin_emails
    @sent_on = Time.now    
    @item = item
    @url = url
    @setting[:title] = Setting.get_setting("site_title")
    @setting[:item_name] = Setting.get_setting("item_name")          
    @from = "#{@setting[:title]}<noreply@none.com>"
    @subject = "#{@setting[:title]}: New #{@setting[:item_name]} - #{@item.name}"
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
