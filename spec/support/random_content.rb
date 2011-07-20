def random_content(options = {})
	options[:length] = 255 if options[:length].nil?
	alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
	(0...options[:length]).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
end