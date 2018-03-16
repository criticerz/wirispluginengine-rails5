require 'base64'

module Wiris
	class Base64
		def initialize()
		end
		def encodeBytes(b)
			#Using '::' to call Base64 module out of the Wiris module scope.
			return Bytes.ofString(::Base64::strict_encode64(b.toString()))
		end

		def decodeBytes(b)
		end
	end
end