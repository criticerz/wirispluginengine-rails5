class String
	def indexOf(substring, offset=0)
		if (offset == 0)
			index = index(substring)
		else
			index = index(substring, offset)
		end

		if (index.nil?)
			return -1
		else
			return index
		end
	end

	def trim()
		return self.strip()
	end

	def lastIndexOf(string)
		if (self.rindex(string).nil?)
			return 0
		else
			return self.rindex(string)
		end
	end

	def startsWith(string)
		return self.start_with?(string)
	end

	def toUpperCase()
		return self.upcase
	end

	def charAt(index)
		return self[index]
	end
end