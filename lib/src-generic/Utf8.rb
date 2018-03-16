module Wiris
	class Utf8
		def self.toBytes(str)
			return str.force_encoding("UTF-8").bytes.to_a
		end

		def self.fromBytes(bytes)
			return bytes.pack("C*")
		end

		def self.charCodeAt(s, index)
			return s.codepoints.to_a[index]
		end

		def self.uchr(code)
			return code.chr(Encoding::UTF_8)
		end

		def self.getLength(s)
			return s.length
		end

		def self.charAt(s, i)
			return s[i]
		end
	end
end