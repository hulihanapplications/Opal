class ItemsController < ApplicationController
 before_filter :authenticate_user, :except => [:index, :rss, :category, :view, :search, :tag, :new_advanced_search, :advanced_search, :set_list_type, :set_item_page_type] # check if user is logged in
 before_filter :enable_user_menu, :only =>  [:new, :edit, :create, :update] # show user menu 
 
 before_filter :authenticate_admin, :only =>  [:all_items] # check if user is admin 
 before_filter :enable_admin_menu, :only =>  [:all_items] # show admin menu 
 
 before_filter :find_item, :except => [:index, :rss, :category, :all_items, :tag, :create, :new, :search, :new_advanced_search, :advanced_search, :set_list_type, :set_item_page_type] # look up item 
 before_filter :check_item_edit_permissions, :except => [:index, :rss, :category, :all_items, :tag, :create, :view, :new, :search, :new_advanced_search, :advanced_search, :set_list_type, :set_item_page_type] # check if item is editable by user 
 before_filter :enable_sorting, :only => [:index, :category, :all_items, :search] # prepare sort variables & defaults for sorting
 

 
  def index # show all items to user
   @setting[:homepage_type] = Setting.get_setting("homepage_type")    
   if @logged_in_user.is_admin?
    @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => Item.sort_order(params[:sort])     
   else      
    @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => Item.sort_order(params[:sort]), :conditions => ["is_approved = '1' and is_public = '1'"]
   end 
  end
 
  def category # get all items for a category and its children/descendants recursively
     @category = Category.find(params[:id]) 
     #@setting[:include_child_category_items] = Setting.get_setting_bool("include_child_category_items") # get a bool object for a setting to pass into various functions that use it(reduces redundant db queries).
     category_ids = @category.get_all_ids(:include_children => @setting[:include_child_category_items]).split(',') # get an array of category ids to be passed into Mysql IN clause
     current_page = params[:page] ||= 1 
     page = @setting[:items_per_page].to_i
     
     @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :order => "created_at DESC", :conditions => ["category_id IN (?) and is_approved = '1' and is_public = '1'", category_ids]    
     
     @setting[:meta_title] = @category.name + " - " + @setting[:meta_title]
     @setting[:meta_keywords] = @category.name + " - " + @category.description + " - " + @setting[:item_name_plural] + " - " + @setting[:meta_keywords]
     @setting[:meta_description] = @category.name + " - " + @category.description + " - " + @setting[:item_name_plural] + " - " + @setting[:meta_description]   
  end
 
  def all_items # show all items in system 
    if params[:type] == "unapproved" # show unapproved items
      @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page], :order => Item.sort_order(params[:sort]), :conditions => ["is_approved = '0'"]
    elsif params[:type] == "approved" # show only approved, public items
      @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page], :order => Item.sort_order(params[:sort]), :conditions => ["is_public = '1' and is_approved = '1'" ]      
    elsif params[:type] == "private" # show only private items
      @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page], :order => Item.sort_order(params[:sort]), :conditions => ["is_public = '0'" ]            
    else # show all items 
      @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page], :order => Item.sort_order(params[:sort])
    end
  end 

  # Regular Methods   

  def view
    @item = Item.find(params[:id])
    if @item.is_viewable_for_user?(@logged_in_user) 
      @setting[:meta_title] = meta_title(@item) 
      @setting[:meta_keywords] = @setting[:meta_title]
      @setting[:meta_description] = @setting[:meta_title]
      @item.update_attribute(:views, @item.views += 1) # update total views
      @item.update_attribute(:recent_views, @item.recent_views += 1) # update recent views  
    else # the user can't see this item
        flash[:failure] = t("notice.not_visible")
        redirect_to :action => "index", :controller => "browse"
    end
    rescue ActiveRecord::RecordNotFound # the item doesn't exist
        flash[:failure] = t("notice.item_not_found", :item => @setting[:item_name] + " #{(@item.id)}")
        redirect_to :action => "index", :controller => "browse"
  end
 
  def new
    @item = Item.new
    params[:id] ||= Category.find(:first).id # set item's category the first category if not specified
    @item.category_id = params[:id] if params[:id]
    @item.is_approved = "1" if @logged_in_user.is_admin? # check the is_approved checkbox 
    if !get_setting_bool("let_users_create_items") && !@logged_in_user.is_admin? # users can't create items and they user isn't an admin
      flash[:failure] = t("notice.items_cannot_add_any_more", :items => @setting[:item_name_plural])      
      redirect_to :action => "index"
    end
  end  


  def update
    # Handle Defaults & Unselected/Unchecked Options
    params[:item][:is_approved]   ||= "0" 
    params[:item][:is_public]     ||= "0" 
    params[:item][:featured]      ||= false
        
    @feature_errors = PluginFeature.check(:features => params[:features], :item => @item) # check if required features are present
        
    if @item.update_attributes(params[:item]) && @feature_errors.size == 0 # make sure there's not required feature errors
        # Update Protected Attributes 
        if @logged_in_user.is_admin? 
          @item.update_attribute(:is_approved, params[:item][:is_approved])
          @item.update_attribute(:featured, params[:item][:featured])        
        end
        
        # Update Features
        num_of_features_updated = PluginFeature.create_values_for_item(:item => @item, :features => params[:features], :user => @logged_in_user, :delete_existing => true, :approve => true)  
        Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "update", :log =>  t("log.item_save", :item => @setting[:item_name], :name => @item.name))                    
        flash[:success] = t("notice.item_save_success", :item => @setting[:item_name])
        redirect_to :action => "edit" , :id => @item        

    else # failed adding required features
      flash[:failure] = t("notice.item_save_failure", :item => @setting[:item_name])
      render :action => "edit"
    end    
    
  end

  def create
    proceed = false # set default flag to false
    max_items = get_setting("max_items_per_user").to_i # get the amount
    if (max_items.to_i == 0 && get_setting_bool("let_users_create_items")) || @logged_in_user.is_admin? # users can add unlimited items or user is an admin
        # do nothing, proceed 
        proceed = true
    else # users can only add a limited number of items
      if get_setting("let_users_create_items") # are users allowed to create items? 
        users_items = Item.count(:all, :conditions => ["user_id = ?", @logged_in_user.id])
        if users_items < max_items # they can add more
          # do nothing, proceed 
        else # they can't add any more items
          flash[:failure] = t("notice.items_cannot_add_any_more", :items => @setting[:item_name_plural]) 
          proceed = false
        end
      end
    end
    
    @item = Item.new(params[:item])
    @item.user_id = @logged_in_user.id
    
    @item.is_public = "0" if (!params[:item][:is_public] && (get_setting_bool("allow_private_items") || @logged_in_user.is_admin?))  # make private if is_public checkbox not checked
    if (@logged_in_user.is_admin? && params[:item][:is_approved]) || (!@logged_in_user.is_admin? && !get_setting_bool("item_approval_required"))   
      @item.is_approved = "1" # make approved if admin or if item approval isn't required
    else # this item is unapproved
       flash[:notice] = t("notice.item_needs_approval", :item => @setting[:item_name])    
    end 

   params[:item][:category_id] ||= Category.find(:first).id # assign the first category's id if not selected.
   @feature_errors = PluginFeature.check(:features => params[:features], :item => @item) # check if required features are present        

   if proceed 
      if @item.save && @feature_errors.size == 0 # item creation failed
         Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "new", :log => t("log.item_create", :item => @setting[:item_name], :name => @item.name))
  
         # Create Features
         num_of_features_updated = PluginFeature.create_values_for_item(:item => @item, :features => params[:features], :user => @logged_in_user, :delete_existing => true, :approve => true)
   
         Emailer.deliver_new_item_notification(@item, url_for(:action => "view", :controller => "items", :id => @item)) if Setting.get_setting_bool("new_item_notification")
         flash[:success] = t("notice.item_create_success", :item => @setting[:item_name])
         redirect_to :action => "view", :controller => "items", :id => @item
       else
          flash[:failure] = t("notice.item_create_failure", :item => @setting[:item_name])
          render :action => "new"
      end     
   else # they aren't allowed to add item
      flash[:failure] = t("notice.invalid_permissions")
      render :action => "new"
   end 
  end
  
  def delete
   @item = Item.find(params[:id])
   if @item.is_deletable_for_user?(@logged_in_user)
     Log.create(:user_id => @logged_in_user.id, :item_id => @item.id,  :log_type => "delete", :log => t("log.item_delete", :item => @setting[:item_name], :name => @item.name))     
     @item.destroy
     flash[:success] = t("notice.item_delete_success", :item => @setting[:item_name])
   else # The user can't delete this item
     flash[:failure] = t("notice.invalid_permissions")
   end 
   redirect_to :action => "items", :controller => "/user"
  end

 def rss
   @latest_items = Item.find(:all, :conditions => ["is_approved = '1' and is_public = '1'"], :limit => 10, :order => "created_at DESC")
   render :layout => false
 end

 def search
   if !params[:search_for] == "" || !params[:search_for].nil?
    @search_for = params[:search_for] # what to search for
    @setting[:meta_title] = t("label.search_results_for", :query => @search_for) + " - " + @setting[:meta_title] 
    @items = Item.paginate :page => params[:page], :per_page => @setting[:items_per_page], :order => Item.sort_order(params[:sort]), :conditions => ["name like ? or description like ? and is_approved = '1' and is_public = '1'", "%#{@search_for}%", "%#{@search_for}%" ]
   else # No Input
     flash[:failure] = t("notice.search_results_left_blank")
     redirect_to :action => "index"
   end
 end
 
 def new_advanced_search
   @setting[:load_prototype] = true # use prototype for ajax calls in this method, instead of jquery
 end
 
 def advanced_search
   @options = Hash.new
   @options[:item_ids] = Array.new # Array to hold item ids to search
   
   # Prepare Features
   if params[:feature] # if there are any feature fields submitted
     # We need to sanitize all values entering the ActiveRecord's conditions. They will be passed in via the array[string, hash] format: ActiveRecord::Base.find(:all, :conditions => ["x = :x_value", {:x_value => "someValue"}])
     conditions_array = Array.new # hash to contain strings of certain conditions, ie: ["x = :x_value", "y LIKE :y_value"], which we will then join with the appropriate conjunction, ie: conditions.join(" AND ")  to create the required string
     values_hash = Hash.new # hash to contain values, ie: {:x_value => "someValue", :y_value => "%someValue%"}   
     num_of_features_to_search = 0 # number of features to search       
     matching_feature_values = Hash.new # hash to hold arrays of ids of items that match each feature value
     
     params[:feature].each do |feature_id, feature_hash|# loop through for every feature value, create a conditions
        #logger.info "#{feature_id} - #{feature_hash.inspect}"
       if feature_hash["search"] == "1" # was this feature's checkbox checked?
          num_of_features_to_search += 1 # increment number of features to search  
           
           # Determine Mysql Where Opertor by Feature Search Type
           matching_feature_values[feature_id] = Array.new # create array to hold matching item ids          
          if feature_hash["type"] == "Keyword" # if searching by Keyword
             matching_values = PluginFeatureValue.find(:all, :group => "item_id", :select => "item_id", :conditions => ["value like ?", "%#{feature_hash["value"]}%"]) # get items matching this feature                  
          else # some other search type
            matching_values = PluginFeatureValue.find(:all, :group => "item_id", :select => "item_id", :conditions => ["value = ?", "#{feature_hash["value"]}"]) # get items matching this feature                              
          end
          
          # Load Item IDs from matching values into arrays
          for value in matching_values 
            matching_feature_values[feature_id] << value.item_id 
          end
       end 
     end     
      
    @options[:item_ids] =  get_common_elements_for_hash_of_arrays(matching_feature_values) if num_of_features_to_search > 0 # get common elements from hash using & operator
    #logger.info "Matching Items: #{matching_feature_values.inspect}"
  else # no features selected
    Item.find(:all, :select => "id").each{|item|  @options[:item_ids] << item.id } # load all item ids into array  
            
  end 
         


   # Prepare Category
     @options[:category_ids] = Array.new # Array to hold category ids to search 
     if params[:item][:category_id] == "all" # search all categories
       for category in Category.get_parent_categories 
          @options[:category_ids] +=  category.get_all_ids(:include_children => true).split(',')
       end
     else # search one category
       category = Category.find(params[:item][:category_id])
       @options[:category_ids] +=  category.get_all_ids(:include_children => @setting[:include_child_category_items]).split(',')
     end 
   
   # Prepare Times
     times  = Hash.new # create a new hash indexed by html value, which contains a time object to be passed into query 
     times["whenever"] = Time.now.to_time.advance(:years => -100) 
     times["today"] = Time.now.beginning_of_day
     times["this_week"] = Time.now.beginning_of_week
     times["this_month"] = Time.now.beginning_of_month
     times["this_year"] = Time.now.beginning_of_year
  
     @options[:created_at_start] = times[params[:created_at]] # select hash item that matches selected form data
     @options[:updated_at_start] = times[params[:updated_at]] # select hash item that matches form data

   # Get Item That match our Search
    @items = Item.find(:all, :conditions => ["(name like ? or description like ?) and id in (?) and category_id in (?) and ( created_at > ? and updated_at > ?)", "%#{params[:search]["keywords"]}%", "%#{params[:search]["keywords"]}%",  @options[:item_ids], @options[:category_ids], @options[:created_at_start], @options[:updated_at_start]  ], :limit => 20)
 
    render :layout => false # ajax powered? then no layout! 
 end
 
 def tag
   @tag = CGI::unescape(params[:tag])
   tags = PluginTag.find(:all, :conditions => ["name = ?", @tag])
   @items = Array.new # create container to hold items
   for tag in tags
     temp_item = Item.find(tag.item_id) # get the item that the tag points to
     @items << temp_item # Throw item into array     
   end
 end
 
 def set_list_type # change the item list type 
   if get_setting_bool("allow_item_list_type_changes")   
     session[:list_type] = params[:list_type] # save the list type in the visitor's browser sessions
   else # not allowed to change list type
     flash[:failure] = t("notice.invalid_permissions")
   end 
   redirect_to request.env["HTTP_REFERER"]  # send them back to original request 
 end

 def set_item_page_type # change the item list type 
   if get_setting_bool("allow_item_page_type_changes")   
     session[:item_page_type] = params[:item_page_type] # save the list type in the visitor's browser sessions
   else # not allowed to change list type
     flash[:failure] = t("notice.invalid_permissions")
   end 
   redirect_to request.env["HTTP_REFERER"]  # send them back to original request 
 end
 
private 

  def get_common_elements_for_hash_of_arrays(hash) # get an array of common elements contained in a hash of arrays, for every array in the hash.
    #hash = {:item_0 => [1,2,3], :item_1 => [2,4,5], :item_2 => [2,5,6] } # for testing
    return hash.values.inject{|acc,elem| acc & elem} # inject & operator into hash values.
  end
  
end
