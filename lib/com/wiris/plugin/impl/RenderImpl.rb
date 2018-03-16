module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/plugin/impl/HttpImpl.rb')
require('com/wiris/util/sys/IniFile.rb')
require('com/wiris/util/json/JSon.rb')
require('com/wiris/plugin/api/Render.rb')
  class RenderImpl
  extend RenderInterface

  include Wiris

    attr_accessor :plugin
    def initialize(plugin)
      super()
      @plugin = plugin
    end
    def computeDigest(mml,param)
      ss = getEditorParametersList()
      renderParams = Hash.new()
        for i in 0..ss::length-1
          key = ss[i]
          value = PropertiesTools::getProperty(param,key)
          if value!=nil
            renderParams::set(key,value)
          end
          i+=1
        end
      if mml!=nil
        renderParams::set("mml",mml)
      end
      s = IniFile::propertiesToString(renderParams)
      return @plugin::getStorageAndCache()::codeDigest(s)
    end
    def createImage(mml,provider,ref_output)
      output = ref_output
      if mml==nil
        raise Exception,"Missing parameter \'mml\'."
      end
      digest = computeDigest(mml,provider::getRenderParameters(@plugin::getConfiguration()))
      contextPath = @plugin::getConfiguration()::getProperty(ConfigurationKeys::CONTEXT_PATH,"/")
      showImagePath = @plugin::getConfiguration()::getProperty(ConfigurationKeys::SHOWIMAGE_PATH,nil)
      saveMode = @plugin::getConfiguration()::getProperty(ConfigurationKeys::SAVE_MODE,"xml")
      s = ""
      if (provider::getParameter("metrics","false")=="true")
        s = getMetrics(digest,output)
      end
      a = ""
      if (provider::getParameter("accessible","false")=="true")
        lang = provider::getParameter("lang","en")
        text = safeMath2Accessible(mml,lang,provider::getParameters())
        if output==nil
          a = "&text="+StringTools::urlEncode(text).to_s
        else 
          PropertiesTools::setProperty(output,"alt",text)
        end
      end
      rparam = ""
      if provider::getParameter("refererquery",nil)!=nil
        refererquery = provider::getParameter("refererquery","")
        rparam = "&refererquery="+refererquery
      end
      if (provider::getParameter("base64",nil)!=nil)||(saveMode=="base64")
        bs = showImage(digest,nil,provider)
        by = Bytes::ofData(bs)
        b64 = Base64.new()::encodeBytes(by)
        imageContentType = @plugin::getImageFormatController()::getContentType()
        return (("data:"+imageContentType)+";base64,")+b64::toString().to_s
      else 
        return (((self.class.concatPath(contextPath,showImagePath)+StringTools::urlEncode(digest).to_s)+s)+a)+rparam
      end
    end
    def showImage(digest,mml,provider)
      if (digest==nil)&&(mml==nil)
        raise Exception,"Missing parameters \'formula\' or \'mml\'."
      end
      if (digest!=nil)&&(mml!=nil)
        raise Exception,"Only one parameter \'formula\' or \'mml\' is valid."
      end
      atts = false
      if ((digest==nil)&&(mml!=nil))&&(provider!=nil)
        digest = computeDigest(mml,provider::getRenderParameters(@plugin::getConfiguration()))
      end
      formula = @plugin::getStorageAndCache()::decodeDigest(digest)
      if formula==nil
        raise Exception,"Formula associated to digest not found."
      end
      if formula::startsWith("<")
        raise Exception,"Not implemented."
      end
      iniFile = IniFile::newIniFileFromString(formula)
      renderParams = iniFile::getProperties()
      ss = getEditorParametersList()
      if provider!=nil
        renderParameters = provider::getRenderParameters(@plugin::getConfiguration())
          for i in 0..ss::length-1
            key = ss[i]
            value = PropertiesTools::getProperty(renderParameters,key)
            if value!=nil
              atts = true
              renderParams::set(key,value)
            end
            i+=1
          end
      end
      if atts
        if mml!=nil
          digest = computeDigest(mml,PropertiesTools::toProperties(renderParams))
        else 
          digest = computeDigest(renderParams::get("mml"),PropertiesTools::toProperties(renderParams))
        end
      end
      store = @plugin::getStorageAndCache()
      bs = nil
      bs = store::retreiveData(digest,@plugin::getConfiguration()::getProperty("wirisimageformat","png"))
      if bs==nil
        if @plugin::getConfiguration()::getProperty(ConfigurationKeys::EDITOR_PARAMS,nil)!=nil
          json = JSon::decode(@plugin::getConfiguration()::getProperty(ConfigurationKeys::EDITOR_PARAMS,nil))
          decodedHash = (json)
          keys = decodedHash::keys()
          notAllowedParams = Std::split(ConfigurationKeys::EDITOR_PARAMETERS_NOTRENDER_LIST,",")
          while keys::hasNext()
            key = keys::next()
            if !notAllowedParams::contains_(key)
              renderParams::set(key,(decodedHash::get(key)))
            end
          end
        else 
            for i in 0..ss::length-1
              key = ss[i]
              if !renderParams::exists(key)
                confKey = ConfigurationKeys::imageConfigProperties::get(key)
                if confKey!=nil
                  value = @plugin::getConfiguration()::getProperty(confKey,nil)
                  if value!=nil
                    renderParams::set(key,value)
                  end
                end
              end
              i+=1
            end
        end
        renderParams::set("format",@plugin::getConfiguration()::getProperty("wirisimageformat","png"))
        h = HttpImpl.new(@plugin::getImageServiceURL(nil,true),nil)
        @plugin::addReferer(h)
        @plugin::addProxy(h)
        iter = renderParams::keys()
        while iter::hasNext()
          key = iter::next()
          h::setParameter(key,renderParams::get(key))
        end
        h::request(true)
        b = Bytes::ofString(h::getData())
        store::storeData(digest,@plugin::getConfiguration()::getProperty("wirisimageformat","png"),b::getData())
        bs = b::getData()
      end
      return bs
    end
    def showImageJson(digest,lang)
      imageFormat = @plugin::getConfiguration()::getProperty("wirisimageformat","png")
      store = @plugin::getStorageAndCache()
      bs = nil
      bs = store::retreiveData(digest,imageFormat)
      jsonOutput = Hash.new()
      if bs!=nil
        jsonOutput::set("status","ok")
        jsonResult = Hash.new()
        by = Bytes::ofData(bs)
        b64 = Base64.new()::encodeBytes(by)
        metrics = PropertiesTools::newProperties()
        getMetrics(digest,metrics)
        if lang==nil
          lang = "en"
        end
        s = store::retreiveData(digest,lang)
        hashMetrics = PropertiesTools::fromProperties(metrics)
        keys = hashMetrics::keys()
        while keys::hasNext()
          currentKey = keys::next()
          jsonResult::set(currentKey,hashMetrics::get(currentKey))
        end
        if s!=nil
          jsonResult::set("alt",Utf8::fromBytes(s))
        end
        jsonResult::set("base64",b64::toString())
        jsonResult::set("format",imageFormat)
        jsonOutput::set("result",jsonResult)
      else 
        jsonOutput::set("status","warning")
      end
      return JSon::encode(jsonOutput)
    end
    def getMathml(digest)
      return nil
    end
    def getEditorParametersList()
      pl = @plugin::getConfiguration()::getProperty(ConfigurationKeys::EDITOR_PARAMETERS_LIST,ConfigurationKeys::EDITOR_PARAMETERS_DEFAULT_LIST)
      return pl::split(",")
    end
    def getMetrics(digest,ref_output)
      output = ref_output
      begin
      bs = showImage(digest,nil,nil)
      end
      b = Bytes::ofData(bs)
      return @plugin::getImageFormatController()::getMetrics(b,output)
    end
    def getMetricsFromBytes(bs,ref_output)
      output = ref_output
      width = 0
      height = 0
      dpi = 0
      baseline = 0
      bys = Bytes::ofData(bs)
      bi = BytesInput.new(bys)
      n = bys::length()
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
    def safeMath2Accessible(mml,lang,param)
      begin
      text = @plugin::newTextService()::mathml2accessible(mml,lang,param)
      return text
      end
    end
    def self.concatPath(s1,s2)
      if s1::lastIndexOf("/")==(s1::length()-1)
        return s1+s2
      else 
        return (s1+"/")+s2
      end
    end
  end
end
