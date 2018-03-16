module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ImageFormatController.rb')
  class ImageFormatControllerPng
  extend ImageFormatControllerInterface

  include Wiris

    def initialize()
      super()
    end
    def getContentType()
      return "image/png"
    end
    def getMetrics(bytes,ref_output)
      output = ref_output
      width = 0
      height = 0
      dpi = 0
      baseline = 0
      bi = BytesInput.new(bytes)
      n = bytes::length()
      alloc = 10
      b = Bytes::alloc(alloc)
      bi::readBytes(b,0,8)
      n-= 8
      while n>0
        len = bi::readInt32()
        typ = bi::readInt32()
        if typ==1229472850
          width = bi::readInt32()
          height = bi::readInt32()
          bi::readInt32()
          bi::readByte()
        else 
          if typ==1650545477
            baseline = bi::readInt32()
          else 
            if typ==1883789683
              dpi = bi::readInt32()
              dpi = (Math::round(dpi/39.37))
              bi::readInt32()
              bi::readByte()
            else 
              if len>alloc
                alloc = len
                b = Bytes::alloc(alloc)
              end
              bi::readBytes(b,0,len)
            end
          end
        end
        bi::readInt32()
        n-= len+12
      end
      if output!=nil
        PropertiesTools::setProperty(output,"width",""+width.to_s)
        PropertiesTools::setProperty(output,"height",""+height.to_s)
        PropertiesTools::setProperty(output,"baseline",""+baseline.to_s)
        if dpi!=96
          PropertiesTools::setProperty(output,"dpi",""+dpi.to_s)
        end
        r = ""
      else 
        r = (((("&cw="+width.to_s)+"&ch=")+height.to_s)+"&cb=")+baseline.to_s
        if dpi!=96
          r = (r+"&dpi=")+dpi.to_s
        end
      end
      return r
    end
  end
end
