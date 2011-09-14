module ActionView
  class Base
    def self.field_error_proc
      Proc.new do |html_tag, instance|
       "<span class=\"field_with_errors\">#{html_tag}</span>".html_safe 
      end 
    end
  end
end

module ActiveRecord 
  class Error
    def generate_full_message(options={}) 
        # Possible I18n Keys that may contain error message.
        keys = [
           #"full_messages.#{@message}""full_messages.#{@message}",
           #'full_messages.format''full_messages.format',
           #'{{attribute}} {{message}}' 
           # these keys(above) were causing a bug, returning the key string as the full message          
           "messages.#{self.type}", 
           "models.#{options[:model].downcase}.attributes.#{options[:attribute].gsub(/ /, "_").downcase}.#{self.type}"
         ] 
         options.merge!(:default => keys, :message => self.message)
          "#{self.base.class.human_attribute_name(self.attribute)} #{self.message}"
         # To Debug, use self.inspect
    end
  end
end

