module WirisPlugin
include  Wiris
  class ConfigurationKeys
  include Wiris

    def initialize()
      super()
    end
  DEBUG = "wirisdebug"
  FORMULA_FOLDER = "wirisformuladirectory"
  CACHE_FOLDER = "wiriscachedirectory"
  INTEGRATION_PATH = "wirisintegrationpath"
  EDITOR_PARAMETERS_LIST = "wiriseditorparameterslist"
  STORAGE_CLASS = "wirisstorageclass"
  CONFIGURATION_CLASS = "wirisconfigurationclass"
  CONFIGURATION_PATH = "wirisconfigurationpath"
  CONTEXT_PATH = "wiriscontextpath"
  SERVICE_PROTOCOL = "wirisimageserviceprotocol"
  SERVICE_PORT = "wirisimageserviceport"
  SERVICE_HOST = "wirisimageservicehost"
  SERVICE_PATH = "wirisimageservicepath"
  CAS_LANGUAGES = "wiriscaslanguages"
  CAS_CODEBASE = "wiriscascodebase"
  CAS_ARCHIVE = "wiriscasarchive"
  CAS_CLASS = "wiriscasclass"
  CAS_WIDTH = "wiriscaswidth"
  CAS_HEIGHT = "wiriscasheight"
  SHOWIMAGE_PATH = "wirishowimagepath"
  SHOWCASIMAGE_PATH = "wirishowcasimagepath"
  CLEAN_CACHE_PATH = "wiriscleancachepath"
  RESOURCE_PATH = "wirisresourcespath"
  LATEX_TO_MATHML_URL = "wirislatextomathmlurl"
  SAVE_MODE = "wiriseditorsavemode"
  EDITOR_TOOLBAR = "wiriseditortoolbar"
  HOST_PLATFORM = "wirishostplatform"
  VERSION_PLATFORM = "wirisversionplatform"
  WIRIS_DPI = "wirisimagedpi"
  FONT_FAMILY = "wirisfontfamily"
  FILTER_OUTPUT_MATHML = "wirisfilteroutputmathml"
  EDITOR_MATHML_ATTRIBUTE = "wiriseditormathmlattribute"
  EDITOR_PARAMS = "wiriseditorparameters"
  EDITOR_PARAMETERS_DEFAULT_LIST = "mml,color,centerbaseline,zoom,dpi,fontSize,fontFamily,defaultStretchy,backgroundColor,format"
  EDITOR_PARAMETERS_NOTRENDER_LIST = "toolbar, toolbarHidden, reservedWords, autoformat, mml, language, rtlLanguages, ltrLanguages, arabicIndicLanguages, easternArabicIndicLanguages, europeanLanguages"
  HTTPPROXY = "wirisproxy"
  HTTPPROXY_HOST = "wirisproxy_host"
  HTTPPROXY_PORT = "wirisproxy_port"
  HTTPPROXY_USER = "wirisproxy_user"
  HTTPPROXY_PASS = "wirisproxy_password"
  REFERER = "wirisreferer"
  IMAGE_FORMAT = "wirisimageformat"
  EXTERNAL_PLUGIN = "wirisexternalplugin"
  EXTERNAL_REFERER = "wirisexternalreferer"
  IMPROVE_PERFORMANCE = "wirispluginperformance"
  EDITOR_KEY = "wiriseditorkey"
  CLEAN_CACHE_TOKEN = "wiriscleancachetoken"
  CLEAN_CACHE_GUI = "wiriscleancachegui"
    def self.imageConfigProperties
      @@imageConfigProperties
    end
    def self.imageConfigProperties=(imageConfigProperties)
      @@imageConfigProperties = imageConfigProperties
    end
    def self.imageConfigPropertiesInv
      @@imageConfigPropertiesInv
    end
    def self.imageConfigPropertiesInv=(imageConfigPropertiesInv)
      @@imageConfigPropertiesInv = imageConfigPropertiesInv
    end
  SERVICES_PARAMETERS_LIST = "mml,lang,service,latex"
    def self.computeInverse(dict)
      keys = dict::keys()
      outDict = Hash.new()
      while keys::hasNext()
        key = keys::next()
        outDict::set(dict::get(key),key)
      end
      return outDict
    end
  @@imageConfigProperties = Hash.new()
  @@imageConfigProperties::set("backgroundColor","wirisimagebackgroundcolor")
  @@imageConfigProperties::set("transparency","wiristransparency")
  @@imageConfigProperties::set("fontSize","wirisimagefontsize")
  @@imageConfigProperties::set("version","wirisimageserviceversion")
  @@imageConfigProperties::set("color","wirisimagecolor")
  @@imageConfigProperties::set("dpi","wirisimagedpi")
  @@imageConfigProperties::set("fontFamily",ConfigurationKeys::FONT_FAMILY)
  @@imageConfigProperties::set("rtlLanguages","wirisrtllanguages")
  @@imageConfigProperties::set("ltrLanguages","wirisltrlanguages")
  @@imageConfigProperties::set("arabicIndicLanguages","wirisarabicindiclanguages")
  @@imageConfigProperties::set("easternArabicIndicLanguages","wiriseasternarabicindiclanguages")
  @@imageConfigProperties::set("europeanLanguages","wiriseuropeanlanguages")
  @@imageConfigProperties::set("defaultStretchy","wirisimagedefaultstretchy")
  @@imageConfigProperties::set("parseMemoryLimit","wirisparsememorylimit")
  @@imageConfigPropertiesInv = computeInverse(@@imageConfigProperties)
  end
end
