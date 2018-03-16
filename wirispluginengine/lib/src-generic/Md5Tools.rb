module Wiris
	class Md5Tools
		def self.encodeString(content)
			return Md5::encode(content)
		end

		def self.encodeBytes(bytes)
			bytes = bytes.getData()
			return Md5::encode(bytes.pack('c*'))
		end
	end
end