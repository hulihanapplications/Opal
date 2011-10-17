class String
  def self.random(options = {})
    options[:length] ||= 6
    options[:mode]   ||= :alphanum # alphanum, num, alpha
    
    case options[:mode]
    when :alpha
      o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;
    when :num
      o =  [('0'..'9')].map{|i| i.to_a}.flatten;  
    else
      o =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten;  
    end            
    string  =  (0..options[:length].to_i).map{ o[rand(o.length)]  }.join;    
  end
  
  # normalize action - "edit" => "update", "update" => "update" 
  def normalize_action 
    case self.to_sym
    when :new, :create
      "create"    
    when :view, :read
      "read"
    when :edit, :update
      "update"
    when :destroy, :delete
      "destroy"
    else
      self
    end 
  end   
end