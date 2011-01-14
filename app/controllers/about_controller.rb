class AboutController < ApplicationController  
  include SimpleCaptcha::ControllerHelpers

  def index
  end
   
  def page
     if params[:id] # A page number is set, show that page
       @page = Page.find(params[:id])   
       if @page.published || @logged_in_user.is_admin? # make sure this is a published page they're going to
           @setting[:meta_title] = @page.title + " - " + @page.description + " - " + @setting[:meta_title]
           @setting[:meta_keywords] = @page.title + " - " + @page.description + " - " + @setting[:meta_title]
           @setting[:meta_description] = @page.title + " - " + @page.description + " - " + @setting[:meta_title]
           @page_comments = PageComment.paginate :page => params[:page], :per_page => 25, :conditions => ["page_id = ? and is_approved = ?", @page.id, "1"]                  
       else
          flash[:failure] = "#{t("notice.not_visible")}"      
          redirect_to :action => "index", :controller => "browse"
       end    
     else 
       @page = nil
     end
  end
  


  def send_contact_us
   if get_setting_bool("enable_contact_us")
     if simple_captcha_valid?  
       email_regexp = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
       if !email_regexp.match(params[:email])# validate email
         flash[:failure] = "#{t("notice.invalid_email")}" #print out any errors!
       else # email okay
        #  def contact_us_email(recipient, from = "noemailset@none.com", name = "No Name Set", subject = "No Subject Set", message = "No Message Set", ip = "", display = "plain") 
        # Send Email
        Emailer.deliver_contact_us_email(params[:email], params[:name], t("email.subject.contact_us", :site_title => @setting[:title], :from => params[:name]), params[:message], request.env['REMOTE_ADDR'])
        flash[:success] = "#{t("notice.contact_thanks", :name => params[:name])}" #print out any errors!
       end
     else # captcha failed
       flash[:failure] = t("notice.invalid_captcha") #print out any errors!
     end 
   else 
     flash[:failure] = t("notice.disabled") 
   end 
   redirect_to :action => "contact_us"
  end
  
  def report_content
  end
end
