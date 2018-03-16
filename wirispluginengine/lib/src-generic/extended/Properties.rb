# Extending Ruby Hash clash
# in order to testing PropertiesTools
# and others classes with Properties java clash involved

class Properties < Hash
	def initialize
		# p instance_eval
	end
	def put(key, value)
		self[key]=value
	end
end