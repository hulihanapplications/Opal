class ZeroThreeFour < ActiveRecord::Migration
  def self.up
     # Update Opal Version
    Setting.find_by_name("opal_version").update_attribute(:value, "0.3.4")    
    
    Setting.create(:name => "section_blog", :title => "Blog",  :value => "1", :setting_type => "Section", :description => "Opal's Integrated Blog. If enabled, a <b>blog</b> link will show up in the main menu.", :item_type => "bool")
    Setting.create(:name => "section_about", :title => "About",  :value => "1", :setting_type => "Section", :description => "Opal's About Section. This section is designed to help people learn about your site. It displays public pages(you create), terms of service, and contact tools. If enabled, an <b>about</b> link will show up in the main menu.", :item_type => "bool")
    
    # Create Blog Post
    blog_page = Page.new(:title => "First Post", :content => "This is the first blog post!", :page_type => "blog")
    blog_page.save
    
    # Create Email Notification Settings
    add_column(:user_infos, :notify_of_new_messages, :boolean, :default => true) # notify users of new messages.    
    
    # Create Token to let users recover their password
    add_column(:user_infos, :forgot_password_code, :string)
    
    # Create Homepage Sidebar Page
    Page.create(:title => "Home Page Sidebar", :description => "This page appears in the sidebar of the homepage.", :page_type => "system", :content => "<div class=\"box_style_2\" style=\"margin-bottom:5px\">\r\n<h1 class=\"title\">Getting Started</h1>To get started, Log in with the username: <strong>admin</strong> and the password: <strong>admin. </strong>\r\n<br><br><h2 class=\"title\">First things First</h2>\r\n <div class=\"spacer\"></div>To start, you might want to change the name of the items you're going to be listing. To do this, log in to your account, Click on the <b>admin</b> tab, then the <b>settings</b> tab. Under small <b>Public</b> subtab, you can change the name of the items you're listing by changing the <b>Item Name</b> and <b>Plural Item Name</b> values.<br><br><h2 class=\"title\">Change this Section</h2>\r\n<div class=\"spacer\"></div>After you log in, Click on the <strong>admin Tab</strong>, then Click on the <strong>Pages Tab</strong>. In the <strong>System Pages Section</strong>, click on the edit icon next to the page: <span style=\"text-decoration: underline;\">Home Page Sidebar</span>. That's all there is to it!<br><br><h2 class=\"title\">Need Any More Help?</h2><div class=\"spacer\"></div>If you need any more help with Opal, check out the <a href=\"http://www.hulihanapplications.com/projects/opal_guide\" onclick=\"window.open(&quot;http://www.hulihanapplications.com/projects/opal_guide&quot;, &quot;&quot;, &quot;resizable=yes, location=no, width=400, height=640, menubar=no, status=no, scrollbars=yes&quot;); return false;\"><b>Opal User Guide</b></a> for help on using Opal.</div>")
    
  end

  def self.down
  end
end
