module WirisPlugin
include  Wiris
  class WInteger
  include Wiris

    def initialize()
      super()
    end
    def self.max(x,y)
      if x>y
        return x
      end
      return y
    end
    def self.min(x,y)
      if x<y
        return x
      end
      return y
    end
    def self.toHex(x,digits)
      s = ""
      while (x!=0)&&((digits)>0)
        digits-=1
        d = x&15
        s = Std::fromCharCode(d+(d>=10 ? 55 : 48)).to_s+s
        x = x>>4
      end
      while (digits-=1)>0
        s = "0"+s
      end
      return s
    end
    def self.parseHex(str)
      return Std::parseInt("0x"+str)
    end
    def self.isInteger(str)
      str = StringTools::trim(str)
      i = 0
      n = str::length()
      if str::startsWith("-")
        i+=1
      end
      if str::startsWith("+")
        i+=1
      end
      while i<n
        c = Std::charCodeAt(str,i)
        if (c<48)||(c>57)
          return false
        end
        i+=1
      end
      return true
    end
  end
end
