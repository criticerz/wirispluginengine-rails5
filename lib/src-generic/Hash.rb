module Wiris
	class Hash < Hash
		def javaHashtable=(javaHashtable)
			@javaHashtable=javaHashtable
		end

		def javaHashtable
			@javaHashtable
		end
		# private:javaHashtable=

		def initialize(hs=nil)
			if (hs.nil?)
				super()
			end
			@javaHashtable = hs
		end

		def get(key)
			return self[key]
		end
		def set(key, value)
			self[key] = value
		end
		alias originalkeysmethod keys

		def keys()
			return Iterator.new(self.originalkeysmethod().to_enum)
		end

		def getJavaHashtable()
			return @javaHashtable
		end

		def exists(key)
			self.has_key?(key)
		end

		def remove(key)
			self.delete(key)
		end
	end
end