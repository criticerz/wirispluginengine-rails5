module Wiris
	class TypeTools

		def self.floatToString(float)
			return float.to_s
		end

		def self.isFloating(str)
			Float(str) rescue false
		end

		def self.isInteger(str)
			Integer(str) rescue false
		end

		def self.isIdentifierPart(int)
			return (int.chr.match(/^[[:alpha:]]$/) ? true : false) || (int.chr.match(/^[[:digit:]]$/) ? true : false) || int.chr == '_'
		end

		def self.isIdentifierStart(int)
			return (int.chr.match(/^[[:alpha:]]$/) ? true : false) || int.chr == '_'
		end

		def self.isArray(o)
			return o.instance_of? Array
		end

		def self.isHash(o)
			return o.instance_of? Hash
		end
	end
end