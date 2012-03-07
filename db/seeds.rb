# This file creates required data for new installations. 
I18n.locale = ENV['LOCALE'].nil? ? "en" : ENV['LOCALE']  # Define locale 

# Create Default Admin Account
@admin = User.new(:first_name => I18n.t('seeds.user.admin.first_name'), :last_name => I18n.t('seeds.user.admin.last_name'), :username => I18n.t('seeds.user.admin.username'), :password => I18n.t('seeds.user.admin.password'), :password_confirmation => I18n.t('seeds.user.admin.password'), :is_admin => "1", :email => I18n.t('seeds.user.admin.email'))
@admin.group_id = Group.admin.id
@admin.is_admin = "1" 
@admin.is_verified = "1"     
@admin.locale = I18n.locale.to_s
@admin.save

puts "\n" + I18n.t("notice.item_install_success", :item => I18n.t("name")) + "\n"
puts I18n.t("label.login_as", :username => I18n.t('seeds.user.admin.username'), :password => I18n.t('seeds.user.admin.password'))
Log.create(:log => I18n.t("notice.item_install_success", :item => I18n.t("name")), :log_type => "system") # Log Install