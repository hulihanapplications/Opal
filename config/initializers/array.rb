class Array
	def hash_by(key_method = :to_s, value_method = :to_value) # convert array to hash, indexed by whatever, value by method called on element
		hash = Hash.new		
		each do |o|
			hash[o.send(key_method).to_sym] = o.send(value_method)
		end
		hash
	end
end