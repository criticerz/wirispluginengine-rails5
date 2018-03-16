module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/plugin/impl/TextFilterTags.rb')
require('com/wiris/util/json/JSon.rb')
  class TextFilter
  include Wiris

    attr_accessor :plugin
    attr_accessor :render
    attr_accessor :service
    attr_accessor :fixUrl
  NBSP = Std::fromCharCode(160)
    def initialize(plugin)
      super()
      @plugin = plugin
      @render = plugin::newRender()
      @service = plugin::newTextService()
      @fixUrl = nil
    end
    def filter(str,prop)
      saveMode = nil
      if prop!=nil
        saveMode = PropertiesTools::getProperty(prop,"savemode")
      end
      if saveMode==nil
        saveMode = @plugin::getConfiguration()::getProperty(ConfigurationKeys::SAVE_MODE,"xml")
      end
      b = (saveMode=="safeXml")
      if b
        tags = TextFilterTags::newSafeXml()
      else 
        tags = TextFilterTags::newXml()
      end
      str = filterMath(tags,str,prop,b)
      str = filterApplet(tags,str,prop,b)
      return str
    end
    def filterMath(tags,text,prop,safeXML)
      output = StringBuf.new()
      n0 = 0
      n1 = text::indexOf(tags::in_mathopen,n0)
      tag = @plugin::getConfiguration()::getProperty(ConfigurationKeys::EDITOR_MATHML_ATTRIBUTE,"data-mathml")
      dataMathml = text::indexOf(tag,0)
      while n1>=0
        m0 = n0
        output::add(Std::substr(text,n0,n1-n0))
        n0 = n1
        n1 = text::indexOf(tags::in_mathclose,n0)
        if n1>=0
          n1 = n1+tags::in_mathclose::length()
          sub = Std::substr(text,n0,n1-n0)
          if safeXML
            if dataMathml!=-1
              m1 = text::indexOf("/>",n1)
              if (m1>=0)&&((text::indexOf("<img",n1)==-1)||(text::indexOf("<img",n1)>m1))
                m0 = Std::substr(text,m0,n0-m0)::lastIndexOf("<img")
                if m0>=0
                  if (text::indexOf(tag,m0)>0)&&(text::indexOf(tag,m0)<n1)
                    n0 = n1
                    output::add(sub)
                    n1 = text::indexOf(tags::in_mathopen,n0)
                    m0 = m1
                      next
                  end
                end
              end
            end
            if @fixUrl==nil
              @fixUrl = EReg.new("<a href=\"[^\"]*\"[^>]*>([^<]*)<\\/a>|<a href=\"[^\"]*\">","")
            end
            sub = @fixUrl::replace(sub,"$1")
            sub = html_entity_decode(sub)
            sub = StringTools::replace(sub,tags::in_double_quote,tags::out_double_quote)
            sub = StringTools::replace(sub,tags::in_open,tags::out_open)
            sub = StringTools::replace(sub,tags::in_close,tags::out_close)
            sub = StringTools::replace(sub,tags::in_entity,tags::out_entity)
            sub = StringTools::replace(sub,tags::in_quote,tags::out_quote)
          end
          sub = math2Img(sub,prop)
          n0 = n1
          output::add(sub)
          n1 = text::indexOf(tags::in_mathopen,n0)
        end
      end
      output::add(Std::substr(text,n0))
      return output::toString()
    end
    def filterApplet(tags,text,prop,safeXML)
      output = StringBuf.new()
      n0 = 0
      n1 = text::toUpperCase()::indexOf(tags::in_appletopen,n0)
      while n1>=0
        output::add(Std::substr(text,n0,n1-n0))
        n0 = n1
        n1 = text::toUpperCase()::indexOf(tags::in_appletclose,n0)
        if n1>=0
          n1 = n1+tags::in_appletclose::length()
          sub = Std::substr(text,n0,n1-n0)
          if safeXML
            if @fixUrl==nil
              @fixUrl = EReg.new("<a href=\"[^\"]*\"[^>]*>([^<]*)<\\/a>|<a href=\"[^\"]*\">","")
            end
            sub = @fixUrl::replace(sub,"$1")
            sub = html_entity_decode(sub)
            sub = StringTools::replace(sub,tags::in_double_quote,tags::out_double_quote)
            sub = StringTools::replace(sub,tags::in_open,tags::out_open)
            sub = StringTools::replace(sub,tags::in_close,tags::out_close)
            sub = StringTools::replace(sub,tags::in_entity,tags::out_entity)
            sub = StringTools::replace(sub,tags::in_quote,tags::out_quote)
          end
          n0 = n1
          output::add(sub)
          n1 = text::toUpperCase()::indexOf(tags::in_appletopen,n0)
        end
      end
      output::add(Std::substr(text,n0))
      return output::toString()
    end
    def math2Img(str,prop)
      img = "<img"
      output = PropertiesTools::newProperties()
      PropertiesTools::setProperty(prop,"centerbaseline","false")
      PropertiesTools::setProperty(prop,"accessible","true")
      PropertiesTools::setProperty(prop,"metrics","true")
      provider = @plugin::newGenericParamsProvider(prop)
      if (@plugin::getConfiguration()::getProperty("wirispluginperformance","false")=="false")
        src = @render::createImage(str,provider,output)
        img+=(" src=\""+src)+"\""
        alt = PropertiesTools::getProperty(output,"alt")
        width = PropertiesTools::getProperty(output,"width")
        height = PropertiesTools::getProperty(output,"height")
        baseline = PropertiesTools::getProperty(output,"baseline")
      else 
        digest = @render::computeDigest(str,prop)
        json = JSon::decode(@render::showImageJson(digest,PropertiesTools::getProperty(prop,"alt")))
        hashImage = (json)
        if (hashImage::get("status")=="warning")
          @render::showImage(nil,str,provider)
        end
        json = JSon::decode(@render::showImageJson(digest,"en"))
        hashImage = (json)
        if (hashImage::get("status")=="ok")
          result = (hashImage::get("result"))
          base64 = (result::get("base64"))
          img+=(" src=\"data:image/png;base64,"+base64)+"\""
          if result::exists("alt")
            alt = (result::get("alt"))
          else 
            alt = @service::mathml2accessible(str,nil,prop)
          end
          width = (result::get("width"))
          height = (result::get("height"))
          baseline = (result::get("baseline"))
        else 
          raise Exception,"Image can\'t be rendererd"
        end
      end
      dpi = Std::parseFloat(@plugin::getConfiguration()::getProperty(ConfigurationKeys::WIRIS_DPI,"96"))
      if @plugin::getConfiguration()::getProperty(ConfigurationKeys::EDITOR_PARAMS,nil)!=nil
        json = JSon::decode(@plugin::getConfiguration()::getProperty(ConfigurationKeys::EDITOR_PARAMS,nil))
        decodedHash = (json)
        if decodedHash::exists("dpi")
          dpi = Std::parseFloat((decodedHash::get("dpi")))
        end
      end
      mml = (@plugin::getConfiguration()::getProperty(ConfigurationKeys::FILTER_OUTPUT_MATHML,"false")=="true")
      f = 96/dpi
      dwidth = f*Std::parseFloat(width)
      dheight = f*Std::parseFloat(height)
      dbaseline = f*Std::parseFloat(baseline)
      alt = html_entity_encode(alt)
      img+=" class=\"Wirisformula\""
      img+=(" alt=\""+alt)+"\""
      img+=(" width=\""+(dwidth).to_s)+"\""
      img+=(" height=\""+(dheight).to_s)+"\""
      d = ((dbaseline-dheight))
      img+=(" style=\"vertical-align:"+d.to_s)+"px\""
      if mml
        tag = @plugin::getConfiguration()::getProperty(ConfigurationKeys::EDITOR_MATHML_ATTRIBUTE,"data-mathml")
        img+=(((" "+tag)+"=\"")+save_xml_encode(str))+"\""
      end
      img+="/>"
      return img
    end
    def html_entity_decode(str)
      str = StringTools::replace(str,"&lt;","<")
      str = StringTools::replace(str,"&gt;",">")
      str = StringTools::replace(str,"&quot;","\"")
      str = StringTools::replace(str,"&nbsp;",NBSP)
      str = StringTools::replace(str,"&amp;","&")
      return str
    end
    def html_entity_encode(str)
      str = StringTools::replace(str,"<","&lt;")
      str = StringTools::replace(str,">","&gt;")
      str = StringTools::replace(str,"\"","&quot;")
      str = StringTools::replace(str,"&","&amp;")
      return str
    end
    def save_xml_encode(str)
      tags = TextFilterTags::newSafeXml()
      str = StringTools::replace(str,tags::out_double_quote,tags::in_double_quote)
      str = StringTools::replace(str,tags::out_open,tags::in_open)
      str = StringTools::replace(str,tags::out_close,tags::in_close)
      str = StringTools::replace(str,tags::out_entity,tags::in_entity)
      str = StringTools::replace(str,tags::out_quote,tags::in_quote)
      return str
    end
  end
end
