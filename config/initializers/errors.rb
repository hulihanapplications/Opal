module ActionView
  class Base
    def self.field_error_proc
      Proc.new { |html_tag, instance|  "<span class=\"fieldWithErrors\">#{html_tag}</span>" }
    end
  end
end

module ActiveRecord 
  class Error
    def generate_full_message(options={})
        keys = [
           #"full_messages.#{@message}""full_messages.#{@message}",
           #'full_messages.format''full_messages.format',
           #'{{attribute}} {{message}}' 
           # these keys(above) were causing a bug, returning the key string as the full message          
           "messages.#{self.type}" 
         ] 
         options.merge!(:default => keys, :message => self.message)
         "#{self.base.class.human_attribute_name(self.attribute)} #{I18n.translate(keys.shift, options)}"
         # To Debug, use self.inspect
    end
  end
end



