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
          flash[:notice] = "<div class=\"flash_failure\">Sorry, you're not allowed to see this.</div>"      
          redirect_to :action => "index", :controller => "browse"
       end    
     else 
       @page = nil
     end
  end
  
  def contact_us
     @setting[:admin_email] = get_setting("admin_email")
  end

  def send_contact_us
   if get_setting_bool("enable_contact_us")
     if simple_captcha_valid?  
       email_regexp = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
       if !email_regexp.match(params[:email])# validate email
         flash[:notice] = "<div class=\"flash_failure\">Sorry, <b>#{params[:email]}</b> isn't a valid email address.</div><br>" #print out any errors!
       else # email okay
        #  def contact_us_email(recipient, from = "noemailset@none.com", name = "No Name Set", subject = "No Subject Set", message = "No Message Set", ip = "", display = "plain") 
        # Send Email
        Emailer.deliver_contact_us_email(params[:email], params[:name], "#{@setting[:title]} Contact Us Message: #{params[:name]}", params[:message], request.env['REMOTE_ADDR'])
        flash[:notice] = "<div class=\"flash_success\">Thanks for contacting us, #{params[:name]}. we'll try to get back to you shortly!</div><br>" #print out any errors!
       end
     else # captcha failed
       flash[:notice] = "<div class=\"flash_failure\">You entered the wrong verification code!</div>" #print out any errors!
     end 
   else 
     flash[:notice] = "<div class=\"flash_failure\">Sorry, This feature is disabled</div>" 
   end 
   redirect_to :action => "contact_us"
  end
  
  def report_content
  end
end
