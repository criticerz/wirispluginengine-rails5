require 'stringio'

module Wiris
  class StringBuf
    @sb

    def sb
      @sb
    end
    
    def initialize()
      @sb = StringIO.new('',"a+") # Append mode 
    end

    def add(o)
      @sb << o
    end

    def addChar(c)
      @sb << c.chr
    end
    
    # public void addSub(String s, int pos, int len){
    #   sb.append(s, pos, len+pos);
    # }
    
    def toString()
      return @sb.string
    end

    def to_s()
      return @sb.string
    end
    # /**
    #  * Not for haxe! Only for C#
    #  * **/
    # public int length(){
    #   return sb.length();
    # }
  end
end