module Wiris
  class File < ::File
    def self.saveContent(file, str)
      out = write(file, true);
      out.write(str)
      out.close
    end

    def self.saveBytes(file, b)
      File.open(file, 'wb' ) do |output|
        b.bytes.each do  | byte |
           output.print byte.chr
        end
      end
    end

    def self.getBytes(file)
        return Bytes.new(IO.binread(file).unpack("C*"))
    end

    def self.getContent(file)
        return File.read(file)
    end

    def self.write(str, binary) 
      if (!binary)
         raise Exception,"Only binary files allowed!"
       end
       return File.open(str, 'wb')
    end

    def self.saveContent(file, str)
      IO.binwrite(file, str.force_encoding("UTF-8"))
    end
  end
end