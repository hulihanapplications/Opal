require 'net/http'

class UriResponseValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    configuration = { :message => :unresponsive, :format => URI::regexp(%w(http https)) }
    configuration.update(options)
    
    begin # check header response
      case Net::HTTP.get_response(URI.parse(value))
        when Net::HTTPSuccess then true
        else object.errors.add(attribute.to_sym, configuration[:message]) and false
      end
    rescue # Recover on DNS failures..
      object.errors.add(attribute.to_sym, configuration[:message]) and false
    end
  end
end

module ActiveRecord
  class Base
    # Make sure record does not belong to self
    #   validate :cannot_belong_to_self
    def cannot_belong_to_self
      parent_id_attr = self.class.name.underscore +  "_id"
      errors.add parent_id_attr.to_sym, :belongs_to_self if send(parent_id_attr) == id
    end
  end
end 