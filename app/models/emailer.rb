class Emailer < ActionMailer::Base
  default :from => "#{Setting.get_setting("site_title")} <#{Setting.get_setting("sender_email")}>"
  default :content_type => "text/plain" # not working in Rails 3.0.3 for some reason, must set inside mail()
  
  def contact_us_email(email = "noemailset@none.com", name = "No Name Set", subject = "No Subject Set", phone = I18n.t("single.none"), message = "No Message Set", ip = "0.0.0.0")
    recipients = Emailer.admin_emails
    @message = message
    @email = email
    @name = name
    @phone = phone
    @ip = ip
    mail(:to => recipients, :subject => subject, :date => Time.now, :reply_to => @email)
  end

	# not used anywhere
#   def test_email(recipients, subject = "No Subject Set", message = "No Message Set.", sent_at = Time.now)
#     @message = message
#     mail(:to => nil, :bcc => recipients, :subject => subject, :date => Time.now)
#   end

  def verification_email(user, user_verification)
    @setting = Setting.global_settings
    @user_verification = user_verification
		@user = user
		@url = url_for(:action => "verify", :controller => "user", :id => user_verification.id, :code => user_verification.code, :only_path => false)                                                         
    subject = I18n.t("email.subject.verification", :name => @user.username, :title => @setting[:title])
    mail(:to => @user.email, :subject =>  subject, :date => Time.now)
  end

	# not used anywhere
  # Send an email with a modified from header
#   def email_from_anyone(recipients, from = "none@none.com", subject = "No Subject Set", message = "No Message Set.", sent_at = Time.now)
#     @body["email"] = from
#     @body["message"] = message
#     mail(:to => nil, :from => from, :bcc => recipients, :subject =>  subject, :date => Time.now)
#   end

  # Notify a User that a message was sent to them
  def new_message_notification(message)
    @setting = Setting.global_settings
    @message = message
    subject = I18n.t("email.subject.item_new_from_user", :item => UserMessage.model_name.human, :from => @message.user_from.username, :name => "#{@message.user_from.first_name} #{@message.user_from.last_name}", :title => @setting[:title])
    mail(:to => message.user.email, :subject => subject, :date => Time.now)
  end

  # Send User a password recovery email
  def password_recovery_email(user, url = "http://localhost/")
    @setting = Setting.global_settings
    @user = user
    @url = url
    subject = I18n.t("email.subject.item_new", :item => UserInfo.human_attribute_name(:forgot_password_code), :name => @user.username, :title => @setting[:title])
    mail(:to => user.email, :subject => subject, :date => Time.now)
  end

  # Send New User Notification Email
  def new_user_notification(user)
    @setting = Setting.global_settings
    @user = user
    subject = I18n.t("email.subject.item_new", :item => User.model_name.human, :name => @user.to_s, :title => @setting[:title])
    mail(:to => Emailer.admin_emails, :subject => subject, :date => Time.now)
  end

  # Send New Item Notification Email
  def new_item_notification(item)
    @setting = Setting.global_settings
    @item = item
    subject = I18n.t("email.subject.item_new_from_user", :item => Item.model_name.human, :name => @item.name, :title => @setting[:title], :from => @item.user ? @item.user.username : nil)
    mail(:to => Emailer.admin_emails, :subject => subject, :date => Time.now)
  end

  def new_plugin_record_notification(record)
    @record = record
    subject = I18n.t("email.subject.item_new_from_user", :item => record.class.model_name.human, :name => record.record.to_s, :title => Setting.global_settings[:title], :from => record.user ? record.user.to_s : nil)
    mail(:to => record.record.user.email, :subject => subject, :date => Time.now)
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
