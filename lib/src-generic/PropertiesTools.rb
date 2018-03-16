module Wiris
	class PropertiesTools
		def self.getProperty(prop, key, dflt=nil)
			if (!prop[key].nil?)
				return prop[key]
			else
				return dflt
			end
		end

		def self.setProperty(prop, key, value)
			prop[key] = value
		end

		def self.newProperties()
			return Hash.new()
		end

		def self.toProperties(hashString)
	        p = Hash.new()
	        keys = hashString.keys()
	        while keys.hasNext()
	        	key = keys.next()
	        	p[key] = hashString.get(key)
	        end
	        return p
	    end

	     def self.fromProperties(prop)
	        return prop
	    end
	end
end