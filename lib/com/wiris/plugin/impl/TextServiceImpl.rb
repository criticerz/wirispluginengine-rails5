module WirisPlugin
include  Wiris
require('com/wiris/plugin/impl/TextFilter.rb')
require('com/wiris/plugin/impl/HttpImpl.rb')
require('com/wiris/util/sys/IniFile.rb')
require('com/wiris/plugin/api/TextService.rb')
  class TextServiceImpl
  extend TextServiceInterface

  include Wiris

    attr_accessor :plugin
    def initialize(plugin)
      super()
      @plugin = plugin
    end
    def service(serviceName,provider)
      digest = nil
      renderParams = provider::getRenderParameters(@plugin::getConfiguration())
      if self.class.hasCache(serviceName)
        digest = @plugin::newRender()::computeDigest(nil,renderParams)
        store = @plugin::getStorageAndCache()
        ext = self.class.getDigestExtension(serviceName,provider)
        s = store::retreiveData(digest,ext)
        if s!=nil
          return Utf8::fromBytes(s)
        end
      end
      url = @plugin::getImageServiceURL(serviceName,self.class.hasStats(serviceName))
      h = HttpImpl.new(url,nil)
      @plugin::addReferer(h)
      @plugin::addProxy(h)
      ha = PropertiesTools::fromProperties(provider::getServiceParameters())
      iter = ha::keys()
      while iter::hasNext()
        k = iter::next()
        h::setParameter(k,ha::get(k))
      end
      h::request(true)
      r = h::getData()
      if digest!=nil
        store = @plugin::getStorageAndCache()
        ext = self.class.getDigestExtension(serviceName,provider)
        store::storeData(digest,ext,Utf8::toBytes(r))
      end
      return r
    end
    def mathml2accessible(mml,lang,param)
      if lang!=nil
        PropertiesTools::setProperty(param,"lang",lang)
      end
      PropertiesTools::setProperty(param,"mml",mml)
      provider = @plugin::newGenericParamsProvider(param)
      return service("mathml2accessible",provider)
    end
    def mathml2latex(mml)
      param = PropertiesTools::newProperties()
      PropertiesTools::setProperty(param,"mml",mml)
      provider = @plugin::newGenericParamsProvider(param)
      return service("mathml2latex",provider)
    end
    def latex2mathml(latex)
      param = PropertiesTools::newProperties()
      PropertiesTools::setProperty(param,"latex",latex)
      provider = @plugin::newGenericParamsProvider(param)
      return service("latex2mathml",provider)
    end
    def getMathML(digest,latex)
      if digest!=nil
        content = @plugin::getStorageAndCache()::decodeDigest(digest)
        if content!=nil
          if StringTools::startsWith(content,"<")
            breakline = content::indexOf("\n",0)
            return Std::substr(content,0,breakline)
          else 
            iniFile = IniFile::newIniFileFromString(content)
            mathml = iniFile::getProperties()::get("mml")
            if mathml!=nil
              return mathml
            else 
              return "Error: mathml not found."
            end
          end
        else 
          return "Error: formula not found."
        end
      else 
        if latex!=nil
          return latex2mathml(latex)
        else 
          return "Error: no digest or latex has been sent."
        end
      end
    end
    def self.hasCache(serviceName)
      if (serviceName=="mathml2accessible")
        return true
      end
      return false
    end
    def self.hasStats(serviceName)
      if (serviceName=="latex2mathml")
        return true
      end
      return false
    end
    def self.getDigestExtension(serviceName,provider)
      lang = provider::getParameter("lang","en")
      if (lang!=nil)&&(lang::length()==0)
        return "en"
      end
      return lang
    end
    def filter(str,prop)
      return TextFilter.new(@plugin)::filter(str,prop)
    end
  end
end
