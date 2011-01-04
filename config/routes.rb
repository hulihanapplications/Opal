Opal::Application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.

  @setting = Setting.global_settings

  #map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  match '/simple_captcha/:action', :controller => 'simple_captcha'

  # Set up default
  root :to => "browse#index"

  match '/tag/:tag', :controller => "items", :action => "tag"
  match '/download/:id', :controller => "plugin_files", :action => "download"
  match '/verify/:id/:code', :controller => "user", :action => "verify"
  match '/page/:id', :controller => "pages", :action => "page"

  match "/#{@setting[:item_name_plural]}/:action/:id", :controller => "items" # use plural item name in url for anything in the items controller 
  
  match '/blog/:year/:month/:day',
               :controller => 'blog',
               :action     => 'archive',
               :month => nil, :day => nil,
               :requirements => {:year => /\d{4}/, :month => /\d{1,2}/,:day => /\d{1,2}/ }


  # Load Custom Plugin Routes 
  #Dir["#{RAILS_ROOT}/vendor/plugins/*"].each do |plugin| 
  #  if File.exists?("#{plugin}/routes.rb") 
  #    File.open("#{plugin}/routes.rb").each do |line|
  #      eval "#{line}" 
  #    end
  #  end
  #end
  
  #Dir["#{RAILS_ROOT}/vendor/plugins/*"].each do |plugin_dir|
    #map.from_plugin(File.basename(plugin_dir))
  #end  


  # See how all your routes lay out with "rake routes"
  
  # Simple Captcha
  match '/simple_captcha/:id', :to => 'simple_captcha#show', :as => :simple_captcha

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'

  
end


