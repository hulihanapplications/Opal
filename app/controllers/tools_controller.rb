class ToolsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 
 
  def index
    redirect_to :action => "index", :controller => "logs"
  end

  def export
  end

  def do_export  
    @options = Hash.new 
    @options[:category_ids] = Array.new # Array to hold category ids to search 
    if params[:item][:category_id] == "all" # search all categories
      for category in Category.get_parent_categories 
         @options[:category_ids] +=  category.get_all_ids(:include_children => true).split(',')
      end
    else # search one category
      category = Category.find(params[:item][:category_id])
      @options[:category_ids] +=  category.get_all_ids(:include_children => @setting[:include_child_category_items]).split(',')
    end
    
    # Get Items to Export   
    @items = Item.find(:all, :conditions => ["category_id in (?)",  @options[:category_ids] ])

    # Export by Selected Format
    filename = Item.model_name.human(:count => :other) + "_#{Time.now.strftime("%Y%m%d_%H%M%S")}" 
    if params[:format] == "csv" # Export to CSV
      csv_array = Array.new
      for item in @items # load item attributes into new array
         line = Array.new # holds items on current line of csv
         line << item.id if params[:attributes][:id]         
         line << item.name if params[:attributes][:name]
         line << item.description if params[:attributes][:description]
         line << item.created_at if params[:attributes][:created_at]
         line << item.updated_at if params[:attributes][:updated_at]
         csv_array << line.join(", ")
      end 
      csv = csv_array.join("\r\n") # join the array, separate by newline
      send_data(csv, :type => 'text/csv; charset=utf-8; header=present', :filename => filename + ".csv")
      #render :text => csv

    elsif params[:format] == "excel" # Export to Excel
    else # No Format Selected
      flash[:failure] = t("notice.item_forgot_to_select", :item => t("single.format"))                 
      #flash[:failure] = "I don't know what format to export to!<br>"
      redirect_to :action => "export"
    end
  end 

  def import
  end 

 
  def do_import  
    params[:item] ||= Hash.new
    params[:item][:category_id] ||= Category.first.id # default category
    @category = Category.find(params[:item][:category_id])
    
    uploaded_file = Uploader.file_from_url_or_local(:local => params[:file], :url => params[:url])
    item_counter = 0 # num of items imported
    if params[:format] == "csv" # to CSV
      linestring = String.new
      while(line = uploaded_file.gets)
        logger.info line
        line_array = line.split(",") # split by comma csv
        attributes = {:name => line_array[0], :description => line_array[1], :category_id => @category.id}
        temp_item = Item.new(attributes)
        temp_item.user_id = @logged_in_user.id        
        temp_item.is_approved = "1" # auto-approve
        linestring += line
        if temp_item.save
          Log.create(:user_id => @logged_in_user.id, :item_id => temp_item.id,  :log_type => "new", :log => t("log.item_create", :item => Item.model_name.human, :name => temp_item.name + " (#{t("single.import")})"))
          item_counter += 1
        end
      end
      
      flash[:success] = t("notice.save_success", :item => Item.model_name.human(:count => :other), :count => item_counter)                 
      #Log.create(:user_id => @logged_in_user.id, :log_type => "system", :log => t("notice.items_import", :item => Item.model_name.human(:count => :other), :count => item_counter)) # log it
      redirect_to :action => "category", :controller => "items", :id => @category      
    else # No Format Selected
      flash[:failure] = t("notice.item_forgot_to_select", :item => t("single.format"))                 
      redirect_to :action => "import"
    end
  ensure
   FileUtils.rm_rf(uploaded_file.path) if uploaded_file
  end


end
