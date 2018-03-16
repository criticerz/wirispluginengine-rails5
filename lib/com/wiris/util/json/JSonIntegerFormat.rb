module WirisPlugin
include  Wiris
  class JSonIntegerFormat
  include Wiris

  HEXADECIMAL = 0
    attr_accessor :n
    attr_accessor :format
    def initialize(n,format)
      super()
      @n = n
      @format = format
    end
    def toString()
      if @format==HEXADECIMAL
        return "0x"+StringTools::hex(@n,0).to_s
      end
      return ""+@n.to_s
    end
  end
end
