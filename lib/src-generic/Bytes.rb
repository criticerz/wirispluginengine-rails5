# This class encapsulates the data structure of an array of bytes. Depending
# on the platform the actual byte array ca be a String, an array of integers,
# or the best choice everywhere.
# It is encouraged to use this structure specially for input/output 
# operations where large byte arrays have to be handled.

module Wiris
  class Bytes
    def bytes=(bytes)
      @bytes=bytes
    end
    def bytes
      @bytes
    end

    def initialize(bytes)
      @bytes = bytes
    end


    def self.ofString(s)
      return Bytes.new(s.force_encoding("ISO-8859-1").bytes.to_a)
    end

    def self.ofData(data)
      return Bytes.new(data)
    end

    def getData()
      return @bytes
    end

    def get(index)
      return @bytes[index]
    end

    def self.alloc(int)
      return []
    end

    def length()
      return @bytes.length
    end

    def toString()
      return @bytes.pack('c*').force_encoding("ISO-8859-1")
    end

  end
end
