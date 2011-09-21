class PluginFeature < ActiveRecord::Base
  #acts_as_opal_plugin
  
  has_many :plugin_feature_values, :dependent => :destroy
  has_many :plugin_feature_value_options, :dependent => :destroy  
  belongs_to :plugin
  belongs_to :user
  belongs_to :category
  
  validates_presence_of :name
  validates_numericality_of :min, :max, :allow_nil => true 

  def is_approved?
    return self.is_approved == "1"
  end
 
 
 def self.check(options = {}) # checks hash for presence of required features and feature value appropriateness
   options[:record]       ||= nil # item needed to add errors
   options[:features]   ||= Hash.new
   
   errors = Hash.new
   
   features = PluginFeature.find(:all)
   for feature in features
     entered_value = options[:features][feature.id.to_s] && options[:features][feature.id.to_s]["value"]
     if entered_value && entered_value != "" # they entered a value for this feature
       if feature.feature_type == "number" || feature.feature_type == "slider"  # make sure they entered a number 
         if entered_value !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/ # is this a float?
           
           errors[feature.name] = "is not a number!"
         else # this is a number
           # Check if within range
           if feature.min # check if below min
              errors[feature.name] = "must be greater than #{feature.min}" if entered_value.to_f < feature.min  # add requirement error            
           end 
           
           if feature.max # check if above max
               errors[feature.name] = "must be less than #{feature.max}" if entered_value.to_f > feature.max  # add requirement error            
           end         
         end           
      end
     else # they did not enter a value for this feature
       if feature.is_required # this is a required feature?
             #options[:item].errors.add(required_feature.name, " is required!")
             errors[feature.name] = "is required!" # add requirement error
       end   
     end   
   end
   return errors
 end
 
 def self.create_values_for_record(options = {}) # create values for an item(from a hash)
   # Set defaults 
   options[:record]                   ||= nil
   options[:features]               ||= Hash.new
   options[:user]                   ||= nil # user making changes
   options[:approve] = true if !defined? options[:approve] # never use ||= for default values when the value is a bool
   options[:delete_existing] = true if !defined? options[:delete_existing_values] # never use ||= for default values when the value is a bool
     logger.info options.inspect

   counter = 0 # num of values saved
   
   options[:features].each do |feature_id, feature_value| 
     if options[:delete_existing] # delete any existing values
      existing_value = PluginFeatureValue.where(:plugin_feature_id => feature_id).record(options[:record]).first
      existing_value.destroy if existing_value 
     end
    
     feature_value = PluginFeatureValue.new(feature_value) 
     # Handle protected attributes
     feature_value.plugin_feature_id =  feature_id     
     feature_value.record = options[:record]     
     feature_value.user_id = options[:user].id          
     feature_value.is_approved = "1" if options[:approve] == true 
     
     counter += 1 if feature_value.save     
   end   
   return counter
 end
 
 def visible_for_category?(some_category) # can this category display this feature?
   if self.category_id.blank?
     return true
   else 
     self.category ? self.category == some_category || some_category.descendant_of?(self.category) : true 
   end
 end
end
