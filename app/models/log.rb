class Log < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  belongs_to :target, :polymorphic => true
  
  default_scope :order => "created_at DESC" # override default find
  scope :target, lambda{|target| where(:target_id => target.id, :target_type => target.class.name)}
  scope :newest_first, order("created_at DESC")


  #validates_presence_of :log
  
  after_create :create_everything
  
  def create_everything
    logger.info ":: Opal Log - #{self.created_at} - #{self.log}" # save a copy of log to log file.
  end
  
  
  def self.search(options = {})
    # defaults
    options ||= Hash.new
    options[:user]        ||= nil # for a user
    options[:item]        ||= nil # for an item
    options[:users]       ||= nil # for a group of users
    options[:items]       ||= nil # for a group of items
    options[:start_date]  ||= nil # start date
    options[:end_date]    ||= nil # end date
    options[:log_type]     ||= nil # by log type 
    
    # Perform find
    logs = Log.find :all, :conditions => Log.get_search_conditions(options).join("AND")
    return logs
  end
  
  def self.get_search_conditions(options = {}) # get an array of search conditions for use in an ActiveRecord find or in will_paginate 
    # defaults
    options ||= Hash.new
    options[:user]        ||= nil # for a user
    options[:item]        ||= nil # for an item
    options[:users]       ||= nil # for a group of users
    options[:items]       ||= nil # for a group of items
    options[:start_date]  ||= nil # start date
    options[:end_date]    ||= nil # end date
    options[:log_type]     ||= nil # by log type 
  
    
    conditions = Array.new # create conditions array for mysql find    
    # Search for one or more users
    user_id_array = Array.new # to hold a container of users
    user_id_array << options[:user].id if options[:user] # add one user to array of users to search for

    if options[:users] # get all for a set of users
      for user in options[:users]
         user_id_array << user.id # add user id to array
      end
    end
   
    conditions << "user_id IN (#{ user_id_array.join(",") })" if (user_id_array.size > 0) # get logs for these users, if any users are in array

    # Search for one or more items
    item_id_array = Array.new # to hold a container of items
    item_id_array << options[:item].id if options[:item] # add one item to array of items to search for

    if options[:items] # get all for a set of items
      for item in options[:items]
         item_id_array << item.id # add item id to array
      end
    end
   
    conditions << "item_id IN (#{ item_id_array.join(",") })" if (item_id_array.size > 0) # get logs for these items, if any items are in array

    # Handle Other Conditions
    conditions << "created_at > #{options[:start_date].strftime("%Y-%m-%d %H:%M:%S")}" if options[:start_date]
    conditions << "created_at < #{options[:end_date].strftime("%Y-%m-%d %H:%M:%S")}" if options[:end_date]
    conditions << "log_type = '#{options[:type]}'" if options[:log_type]

    return conditions
  end
  
  def to_s
    string = String.new
    if self.user
      string << self.user.username + " "
    end
    string << self.log
  end
  
  def klass # return target class
    target_type.constantize
  end
end
