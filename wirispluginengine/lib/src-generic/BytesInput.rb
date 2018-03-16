module Wiris
	class BytesInput
		def binary()
			@binary
		end

		def initialize(bs)
			@binary = bs.getData().to_enum
		end

		def readBytes(b, pos, len)
			return @binary[pos..len]
		end

		def readByte()
			byt = @binary.next
			if byt.nil?
				return false
			else
				return byt
			end
		end
		def readInt32()
			c1 = readByte
			c2 = readByte
			c3 = readByte
			c4 = readByte
			return (c1 << 8 | c2) << 16 | (c3 << 8 | c4)
		end

		def readBytes(bytes, pos, len)
			for i in 0..len-1
				bytes[i]=readByte
			end
		end

	end
end