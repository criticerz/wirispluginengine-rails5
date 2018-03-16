module WirisPlugin
include  Wiris
require('com/wiris/util/xml/WXmlUtils.rb')
require('com/wiris/plugin/api/ImageFormatController.rb')
  class ImageFormatControllerSvg
  extend ImageFormatControllerInterface

  include Wiris

    def initialize()
      super()
    end
    def getContentType()
      return "image/svg+xml"
    end
    def getMetrics(bytes,ref_output)
      svg = bytes::toString()
      output = ref_output
      svgXml = WXmlUtils::parseXML(svg)
      width = svgXml::firstElement()::get("width")
      height = svgXml::firstElement()::get("height")
      baseline = svgXml::firstElement()::get("wrs:baseline")
      if output!=nil
        PropertiesTools::setProperty(output,"width",""+width)
        PropertiesTools::setProperty(output,"height",""+height)
        PropertiesTools::setProperty(output,"baseline",""+baseline)
        r = ""
      else 
        r = (((("&cw="+width)+"&ch=")+height)+"&cb=")+baseline
      end
      return r
    end
  end
end
