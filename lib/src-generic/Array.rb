module Wiris
	class Array < Array
		def iterator
			return Iterator.new(self)
		end

		def get(i)
			return self[i]
		end

		def _(i, e=nil)
			if e.nil?
				return get(i)
			else
				self[i] = e
			end
		end

		def contains_(key)
			return self.include? key
		end
	end
end