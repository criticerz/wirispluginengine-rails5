module Wiris
	class ArrayInt < ::Array
		def sort()
			for i in 1..length()
				j = i
				b = get(i)
				while ((j>0) && get(j-1) > b)
					insert(j,get(j-1))
					j -=1
				end
				insert(j, b)
				i += 1
			end
		end

		def splice(i, len)
			na = slice!(i, len)
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
	end
end