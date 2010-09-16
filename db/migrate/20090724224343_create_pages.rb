# Pages are used for non-item content.
class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :page_id, :default => 0 # parent page id
      t.integer :user_id, :default => nil # user who added page
      t.string :title, :default => "" # title of the page
      t.string :description, :default => ""      
      t.string :page_type, :default => "public" # public, system(title & description non-editable)
      t.text :content 
      t.timestamps
    end
    
    title = Setting.get_setting("title")
    Page.create(:title => "Banner Top", :description => "Any content added here will show at the top of your site. Useful for ad banners and javascript.", :page_type => "system")
    Page.create(:title => "Banner Bottom", :description => "Any content added here will show at the bottom of your site. Useful for ad banners and javascript.", :page_type => "system")
    Page.create(:title => "Main Home Page", :description => "The Main Home Page of your site.", :page_type => "system", :content => "<div class=\"box_style_2\" style=\"margin-bottom:5px\">\r\n<h1 class=\"title\">Welcome!</h1>Welcome to Opal. First time using Opal? No problem. Start by reading the <b>Getting Started</b> section.<br><br><h2 class=\"title\">Change this Section</h2>\r\n<div class=\"spacer\"></div>After you log in, Click on the <strong>admin Tab</strong>, then Click on the <strong>Pages Tab</strong>. In the <strong>System Pages Section</strong>, click on the edit icon next to the page: <span style=\"text-decoration: underline;\">Main Home Page</span>. That's all there is to it!</div>")
    Page.create(:title => "About Home", :description => "The Homepage of the About Section.", :page_type => "system", :content => "<div class=\"box_style_2\"><h1>What is Opal?</h1>Opal is a Ruby on Rails Item Management Application. Well, what kind of items can you <b>manage</b>? Anything! Bicycles, homes for sale, banana vendors, etc. can all be managed and organized by Opal.</div>")
    Page.create(:title => "Terms of Service", :description => "The Terms of Service for new users joining #{title}.", :page_type => "system", :content => "<h1>Terms of Service</h1>By joining this site, you agree not to add or submit any damaging or offensive content, including by not limited to: pornography, any malicious software or files, violent or hateful images, etc.<br><br>You also agree not to submit any content that is either stolen, plagiarized, or otherwise listed without the consent of the copyright holder.")
  end

  def self.down
    drop_table :pages
  end
end
