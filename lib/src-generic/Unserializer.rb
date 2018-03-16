module Wiris
  class Unserializer
    def buf
      @buf
    end

    def pos
      @pos
    end

    def initialize(s)
      @buf = s
      @pos = 0
    end

    def self.run(s)
      return Unserializer.new(s).unserialize()
    end

    def unserialize()
      c = Std.charCodeAt(buf, @pos)
      @pos += 1
      case c
      when 0x61 # 'a' for Array
        a = Array.new()
        while(true)
          t = Std.charCodeAt(buf, @pos)
          if (t == 0x68) # 'h'
            @pos += 1
            break
          end
          if (t == 0x75) # 'u'
            @pos += 1
            n = readDigits()
            a._(a.length()-(n-1), nil)
          else
            a.push(unserialize())
          end
        end
        return a
      when 0x69 # 'i' for integer
        return readDigits()
      when 0x7a # 'z'
        return 0
      when 0x6e #n
        return nil
      else
        raise Exception,'Object class not implemented: " ' + Std.fromCharCode(c) + "."
      end
    end

    def readDigits()
      n = 0
      c = Std.charCodeAt(buf,@pos)
      minus = false
      if c == 0x2d # '-'
        minus = true
        @pos += 1
        c = Std.charCodeAt(buf,@pos)
      end
      while (c>=0x30 && c<=0x39)
        n = n*10 + (c-0x30)
        @pos += 1
        if (@pos >= buf.length())
          break
        end
        c= Std.charCodeAt(buf,@pos)
      end
      ret = (minus ? -n : n)
      return ret
    end
  end
end