require 'digest/md5'
module Wiris
	class Md5
		def self.encode(content)
			return Digest::MD5.hexdigest(content)
		end
	end
end
