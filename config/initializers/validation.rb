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

