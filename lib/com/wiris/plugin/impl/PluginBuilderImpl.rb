module WirisPlugin
  include  Wiris
  require('com/wiris/plugin/api/ConfigurationKeys.rb')
  require('com/wiris/plugin/api/PluginBuilder.rb')
  require('com/wiris/plugin/impl/FolderTreeStorageAndCache.rb')
  require('com/wiris/plugin/impl/TestImpl.rb')
  require('com/wiris/plugin/impl/ServiceResourceLoaderImpl.rb')
  require('com/wiris/plugin/impl/ImageFormatControllerPng.rb')
  require('com/wiris/plugin/impl/CleanCacheImpl.rb')
  require('com/wiris/plugin/impl/EditorImpl.rb')
  require('com/wiris/plugin/impl/RenderImpl.rb')
  require('com/wiris/plugin/impl/DefaultConfigurationUpdater.rb')
  require('com/wiris/plugin/impl/FileStorageAndCache.rb')
  require('com/wiris/plugin/impl/ImageFormatControllerSvg.rb')
  require('com/wiris/plugin/impl/CasImpl.rb')
  require('com/wiris/plugin/impl/ConfigurationImpl.rb')
  require('com/wiris/plugin/impl/TextServiceImpl.rb')
  require('com/wiris/plugin/impl/GenericParamsProviderImpl.rb')
# require('com/wiris/plugin/api/PluginBuilder.rb')

  class PluginBuilderImpl # < PluginBuilder
    include Wiris

    attr_accessor :configuration
    attr_accessor :store
    attr_accessor :updaterChain
    attr_accessor :storageAndCacheInitObject
    attr_accessor :customParamsProvider
    def initialize()
      super()
      @updaterChain = Array.new()
      @updaterChain::push(DefaultConfigurationUpdater.new())
      ci = ConfigurationImpl.new()
      @configuration = ci
      ci::setPluginBuilderImpl(self)
    end
    def addConfigurationUpdater(conf)
      @updaterChain::push(conf)
    end
    def setCustomParamsProvider(provider)
      @customParamsProvider = provider
    end
    def getCustomParamsProvider()
      return @customParamsProvider
    end
    def setStorageAndCache(store)
      @store = store
    end
    def newRender()
      if (Type::resolveClass("com.wiris.editor.services.PublicServices")!=nil)&&isEditorLicensed()
        return RenderImplIntegratedServices.new(self)
      end
      return RenderImpl.new(self)
    end
    def newAsyncRender()
      return AsyncRenderImpl.new(self)
    end
    def newTest()
      return TestImpl.new(self)
    end
    def newEditor()
      return EditorImpl.new(self)
    end
    def newCas()
      return CasImpl.new(self)
    end
    def newTextService()
      if (Type::resolveClass("com.wiris.editor.services.PublicServices")!=nil)&&isEditorLicensed()
        return TextServiceImplIntegratedServices.new(self)
      end
      return TextServiceImpl.new(self)
    end
    def newAsyncTextService()
      return AsyncTextServiceImpl.new(self)
    end
    def getConfiguration()
      return @configuration
    end
    def getStorageAndCache()
      if @store==nil
        className = @configuration::getProperty(ConfigurationKeys::STORAGE_CLASS,nil)
        if (className==nil)||(className=="FolderTreeStorageAndCache")
          @store = FolderTreeStorageAndCache.new()
        else 
          if (className=="FileStorageAndCache")
            @store = FileStorageAndCache.new()
          else 
            cls = Type::resolveClass(className)
            if cls==nil
              raise Exception,("Class "+className)+" not found."
            end
            @store = (Type::createInstance(cls,Array.new()))
            if @store==nil
              raise Exception,("Instance from "+cls.to_s)+" cannot be created."
            end
          end
        end
        initialize_(@store,@configuration::getFullConfiguration())
      end
      return @store
    end
    def initialize_(sac,conf)
      sac::init(@storageAndCacheInitObject,conf)
    end
    def getConfigurationUpdaterChain()
      return @updaterChain
    end
    def setStorageAndCacheInitObject(obj)
      @storageAndCacheInitObject = obj
    end
    def newCleanCache()
      return CleanCacheImpl.new(self)
    end
    def newResourceLoader()
      return ServiceResourceLoaderImpl.new()
    end
    def getImageServiceURL(service,stats)
      config = getConfiguration()
      if Type::resolveClass("com.wiris.editor.services.PublicServices")!=nil
        if (config::getProperty(ConfigurationKeys::SERVICE_HOST,nil)=="www.wiris.net")
          return getConfiguration()::getProperty(ConfigurationKeys::CONTEXT_PATH,"/")+"/editor/editor"
        end
      end
      protocol = config::getProperty(ConfigurationKeys::SERVICE_PROTOCOL,nil)
      port = config::getProperty(ConfigurationKeys::SERVICE_PORT,nil)
      url = config::getProperty(ConfigurationKeys::INTEGRATION_PATH,nil)
      if (protocol==nil)&&(url!=nil)
        if StringTools::startsWith(url,"https")
          protocol = "https"
        end
      end
      if protocol==nil
        protocol = "http"
      end
      if port!=nil
        if (protocol=="http")
          if !(port=="80")
            port = ":"+port
          else 
            port = ""
          end
        end
        if (protocol=="https")
          if !(port=="443")
            port = ":"+port
          else 
            port = ""
          end
        end
      else 
        port = ""
      end
      domain = config::getProperty(ConfigurationKeys::SERVICE_HOST,nil)
      path = config::getProperty(ConfigurationKeys::SERVICE_PATH,nil)
      if service!=nil
        _end = path::lastIndexOf("/")
        if _end==-1
          path = service
        else 
          path = (Std::substr(path,0,_end).to_s+"/")+service
        end
      end
      if stats
        path = addStats(path)
      end
      return (((protocol+"://")+domain)+port)+path
    end
    def addProxy(h)
      conf = getConfiguration()
      proxyEnabled = conf::getProperty(ConfigurationKeys::HTTPPROXY,"false")
      if (proxyEnabled=="true")
        host = conf::getProperty(ConfigurationKeys::HTTPPROXY_HOST,nil)
        port = Std::parseInt(conf::getProperty(ConfigurationKeys::HTTPPROXY_PORT,"80"))
        if (host!=nil)&&(host::length()>0)
          user = conf::getProperty(ConfigurationKeys::HTTPPROXY_USER,nil)
          pass = conf::getProperty(ConfigurationKeys::HTTPPROXY_PASS,nil)
          h::setProxy(HttpProxy::newHttpProxy(host,port,user,pass))
        end
      end
    end
    def addReferer(h)
      conf = getConfiguration()
      if (conf::getProperty("wirisexternalplugin","false")=="true")
        h::setHeader("Referer",conf::getProperty(ConfigurationKeys::EXTERNAL_REFERER,"external referer not found"))
      else 
        h::setHeader("Referer",conf::getProperty(ConfigurationKeys::REFERER,""))
      end
    end
    def addCorsHeaders(response,origin)
      conf = getConfiguration()
      if (conf::getProperty("wiriscorsenabled","false")=="true")
        confDir = conf::getProperty(ConfigurationKeys::CONFIGURATION_PATH,nil)
        corsConfFile = confDir+"/corsservers.ini"
        s = Storage::newStorage(corsConfFile)
        if s::exists()
          dir = s::read()
          allowedHosts = Std::split(dir,"\n")
          if allowedHosts::contains_(origin)
            response::setHeader("Access-Control-Allow-Origin",origin)
          end
        else 
          response::setHeader("Access-Control-Allow-Origin","*")
        end
      end
    end
    def addStats(url)
      saveMode = getConfiguration()::getProperty(ConfigurationKeys::SAVE_MODE,"xml")
      externalPlugin = getConfiguration()::getProperty(ConfigurationKeys::EXTERNAL_PLUGIN,"false")
      begin
        version = Storage::newResourceStorage("VERSION")::read()
      end
      begin
        tech = StringTools::replace(Storage::newResourceStorage("tech.txt")::read(),"\n","")
        tech = StringTools::replace(tech,"\r","")
      end
      if url::indexOf("?")!=-1
        return (((((((url+"&stats-mode=")+saveMode)+"&stats-version=")+version)+"&stats-scriptlang=")+tech)+"&external=")+externalPlugin
      else 
        return (((((((url+"?stats-mode=")+saveMode)+"&stats-version=")+version)+"&stats-scriptlang=")+tech)+"&external=")+externalPlugin
      end
    end
    def isEditorLicensed()
      licenseClass = Type::resolveClass("com.wiris.util.sys.License")
      if licenseClass!=nil
        init = Reflect::field(licenseClass,"init")
        initMethodParams = Array.new()
        initMethodParams::push(getConfiguration()::getProperty(ConfigurationKeys::EDITOR_KEY,""))
        initMethodParams::push("")
        initMethodParams::push([4, 5, 9, 10])
        Reflect::callMethod(licenseClass,init,initMethodParams)
        isLicensedMethod = Reflect::field(licenseClass,"isLicensed")
        isLicensedObject = Reflect::callMethod(licenseClass,isLicensedMethod,nil)
        if Type::getClassName(Type::getClass(isLicensedObject))::indexOf("Boolean")!=-1
          isLicensed = Boolean::valueOf(isLicensedObject::toString())
        else 
          isLicensed = (isLicensedObject)
        end
        return (isLicensed)
      end
      return false
    end
    def getImageFormatController()
      if (@configuration::getProperty(ConfigurationKeys::IMAGE_FORMAT,"png")=="svg")
        imageFormatController = ImageFormatControllerSvg.new()
      else 
        imageFormatController = ImageFormatControllerPng.new()
      end
      return imageFormatController
    end
    def newGenericParamsProvider(properties)
      return GenericParamsProviderImpl.new(properties)
    end
  end

  @@pb = nil

  def self.pb
    @@pb
  end

  def self.pb=(pb)
    @@pb = pb
  end

  def self.getInstance()
    if @pb == nil
      @pb = PluginBuilderImpl.new()
    end
    return @pb
  end

end