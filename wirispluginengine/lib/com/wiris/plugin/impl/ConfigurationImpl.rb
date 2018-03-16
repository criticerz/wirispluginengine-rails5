module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/plugin/impl/CustomConfigurationUpdater.rb')
require('com/wiris/util/json/JSon.rb')
require('com/wiris/plugin/impl/FileConfigurationUpdater.rb')
require('com/wiris/plugin/api/Configuration.rb')
  class ConfigurationImpl
  extend ConfigurationInterface

  include Wiris

    attr_accessor :plugin
    attr_accessor :initObject
    attr_accessor :props
    attr_accessor :initialized
    def initialize()
      super()
      @props = PropertiesTools::newProperties()
    end
    def getFullConfiguration()
      initialize0()
      return @props
    end
    def getFullConfigurationAsJson()
      initialize0()
      return nil
    end
    def getProperty(key,dflt)
      initialize0()
      return PropertiesTools::getProperty(@props,key,dflt)
    end
    def setProperty(key,value)
      PropertiesTools::setProperty(@props,key,value)
    end
    def setInitObject(context)
      @initObject = context
    end
    def initialize0()
      if @initialized
        return 
      end
      @initialized = true
      @plugin::addConfigurationUpdater(FileConfigurationUpdater.new())
      @plugin::addConfigurationUpdater(CustomConfigurationUpdater.new(self))
      a = @plugin::getConfigurationUpdaterChain()
      iter = a::iterator()
      while iter::hasNext()
        cu = iter::next()
        initialize_(cu)
        cu::updateConfiguration(@props)
      end
    end
    def initialize_(cu)
      cu::init(@initObject)
    end
    def setPluginBuilderImpl(plugin)
      @plugin = plugin
    end
    def appendVarJs(sb,varName,value,comment)
      sb::add("var ")
      sb::add(varName)
      sb::add(" = ")
      sb::add(value)
      sb::add("; // ")
      sb::add(comment)
      sb::add("\r\n")
    end
    def appendElement2JavascriptArray(array,value)
      arrayOpen = array::indexOf("[")
      arrayClose = array::indexOf("]")
      if (arrayOpen==-1)||(arrayClose==-1)
        raise Exception,"Array not valid"
      end
      return ((("["+"\'")+value)+"\'")+(array::length()==2 ? "]" : ","+Std::substr(array,arrayOpen+1,arrayClose-arrayOpen).to_s)
    end
    def getJavaScriptConfiguration()
      sb = StringBuf.new()
      arrayParse = "[]"
      appendVarJs(sb,"_wrs_conf_editorEnabled",getProperty("wiriseditorenabled",nil),"Specifies if fomula editor is enabled")
      appendVarJs(sb,"_wrs_conf_imageMathmlAttribute",("\'"+getProperty("wiriseditormathmlattribute",nil))+"\'","Specifies the image tag where we should save the formula editor mathml code")
      appendVarJs(sb,"_wrs_conf_saveMode",("\'"+getProperty("wiriseditorsavemode",nil))+"\'","This value can be \'xml\', \'safeXml\', \'image\' or \'base64\'")
      appendVarJs(sb,"_wrs_conf_editMode",("\'"+getProperty("wiriseditoreditmode",nil))+"\'","This value can be \'default\' or \'image\'")
      if (getProperty("wiriseditorparselatex",nil)=="true")
        arrayParse = appendElement2JavascriptArray(arrayParse,"latex")
      end
      if (getProperty("wiriseditorparsexml",nil)=="true")
        arrayParse = appendElement2JavascriptArray(arrayParse,"xml")
      end
      appendVarJs(sb,"_wrs_conf_parseModes",arrayParse,"This value can contain \'latex\' and \'xml)")
      appendVarJs(sb,"_wrs_conf_editorAttributes",("\'"+getProperty("wiriseditorwindowattributes",nil))+"\'","Specifies formula editor window options")
      appendVarJs(sb,"_wrs_conf_editorUrl",("\'"+@plugin::getImageServiceURL("editor",false))+"\'","WIRIS editor")
      appendVarJs(sb,"_wrs_conf_modalWindow",getProperty("wiriseditormodalwindow",nil),"Editor modal window")
      appendVarJs(sb,"_wrs_conf_CASEnabled",getProperty("wiriscasenabled",nil),"Specifies if WIRIS cas is enabled")
      appendVarJs(sb,"_wrs_conf_CASMathmlAttribute",("\'"+getProperty("wiriscasmathmlattribute",nil))+"\'","Specifies the image tag where we should save the WIRIS cas mathml code")
      appendVarJs(sb,"_wrs_conf_CASAttributes",("\'"+getProperty("wiriscaswindowattributes",nil))+"\'","Specifies WIRIS cas window options")
      appendVarJs(sb,"_wrs_conf_hostPlatform",("\'"+getProperty("wirishostplatform",nil))+"\'","Specifies host platform")
      appendVarJs(sb,"_wrs_conf_versionPlatform",("\'"+getProperty("wirisversionplatform","unknown"))+"\'","Specifies host version platform")
      appendVarJs(sb,"_wrs_conf_enableAccessibility",getProperty("wirisaccessibilityenabled",nil),"Specifies whether accessibility is enabled")
      appendVarJs(sb,"_wrs_conf_setSize",getProperty("wiriseditorsetsize",nil),"Specifies whether to set the size of the images at edition time")
      appendVarJs(sb,"_wrs_conf_editorToolbar",("\'"+getProperty(ConfigurationKeys::EDITOR_TOOLBAR,nil))+"\'","Toolbar definition")
      appendVarJs(sb,"_wrs_conf_chemEnabled",getProperty("wirischemeditorenabled",nil),"Specifies if WIRIS chem editor is enabled")
      appendVarJs(sb,"_wrs_conf_imageFormat",("\'"+getProperty("wirisimageformat","png"))+"\'","WIRIS Plugin image format")
      if getProperty(ConfigurationKeys::EDITOR_PARAMS,nil)!=nil
        appendVarJs(sb,"_wrs_conf_editorParameters",getProperty(ConfigurationKeys::EDITOR_PARAMS,nil),"Editor parameters")
      else 
        h = ConfigurationKeys::imageConfigPropertiesInv
        attributes = StringBuf.new()
        confVal = ""
        i = 0
        it = h::keys()
        while it::hasNext()
          value = it::next()
          if getProperty(value,nil)!=nil
            if i!=0
              attributes::add(",")
            end
            i+=1
            confVal = getProperty(value,nil)
            StringTools::replace(confVal,"-","_")
            StringTools::replace(confVal,"-","_")
            attributes::add("\'")
            attributes::add(ConfigurationKeys::imageConfigPropertiesInv::get(value))
            attributes::add("\' : \'")
            attributes::add(confVal)
            attributes::add("\'")
          end
        end
        appendVarJs(sb,"_wrs_conf_editorParameters",("{"+attributes::toString().to_s)+"}","Editor parameters")
      end
      appendVarJs(sb,"_wrs_conf_wirisPluginPerformance",getProperty("wirispluginperformance",nil),"Experimental settings to improve performance")
      sb::add("var _wrs_conf_configuration_loaded = true;\r\n")
      sb::add("if (typeof _wrs_conf_core_loaded != \'undefined\') _wrs_conf_plugin_loaded = true;\r\n")
      begin
      version = Storage::newResourceStorage("VERSION")::read()
      end
      sb::add(("var _wrs_conf_version = \'"+version)+"\';\r\n")
      return sb::toString()
    end
    def getJsonConfiguration(configurationKeys)
      configurationKeysArray = Std::split(configurationKeys,",")
      iterator = configurationKeysArray::iterator()
      jsonOutput = Hash.new()
      jsonVariables = Hash.new()
      thereIsNullValue = false
      while iterator::hasNext()
        key = iterator::next()
        value = getProperty(key,"null")
        if (value=="null")
          thereIsNullValue = true
        end
        jsonVariables::set(key,value)
      end
      if !thereIsNullValue
        jsonOutput::set("status","ok")
      else 
        jsonOutput::set("status","warning")
      end
      jsonOutput::set("result",jsonVariables)
      return JSon::encode(jsonOutput)
    end
    def setConfigurations(configurationKeys,configurationValues)
      configurationKeysArray = Std::split(configurationKeys,",")
      configurationValuesArray = Std::split(configurationValues,",")
      keysIterator = configurationKeysArray::iterator()
      valuesIterator = configurationValuesArray::iterator()
      while keysIterator::hasNext()&&valuesIterator::hasNext()
        key = keysIterator::next()
        value = valuesIterator::next()
        if getProperty(key,nil)!=nil
          setProperty(key,value)
        end
      end
    end
  end
end
