module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/plugin/impl/RenderImpl.rb')
require('com/wiris/plugin/api/Cas.rb')
  class CasImpl
  extend CasInterface

  include Wiris

    attr_accessor :plugin
    def initialize(plugin)
      super()
      @plugin = plugin
    end
    def showCasImage(f,provider)
      formula = f
      if formula::endsWith(".png")
        formula = Std::substr(formula,0,formula::length()-4)
      end
      store = plugin::getStorageAndCache()
      data = store::retreiveData(formula,"png")
      if data==nil
        data = Storage::newResourceStorage("cas.png")::readBinary()
        if data==nil
          raise Exception,"Missing resource cas.png"
        end
      end
      return data
    end
    def createCasImage(imageParameter)
      output = ""
      contextPath = @plugin::getConfiguration()::getProperty(ConfigurationKeys::CONTEXT_PATH,"/")
      if imageParameter!=nil
        dataDecoded = self.class.decodeBase64(imageParameter)
        digest = Md5::encode(imageParameter)
        store = plugin::getStorageAndCache()
        store::storeData(digest,"png",dataDecoded::getData())
        showImagePath = @plugin::getConfiguration()::getProperty(ConfigurationKeys::SHOWCASIMAGE_PATH,nil)
        output+=RenderImpl::concatPath(contextPath,showImagePath)+StringTools::urlEncode(digest+".png").to_s
      else 
        output+=RenderImpl::concatPath(contextPath,"core/cas.png")
      end
      return output
    end
    def cas(mode,language)
      output = StringBuf.new()
      output::add("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">")
      config = plugin::getConfiguration()
      availableLanguages = getAvailableCASLanguages(config::getProperty(ConfigurationKeys::CAS_LANGUAGES,nil))
      if (language==nil)||!availableLanguages::contains_(language)
        language = availableLanguages::_(0)
      end
      if (mode!=nil)&&(mode=="applet")
        codebase = StringTools::replace(config::getProperty(ConfigurationKeys::CAS_CODEBASE,nil),"%LANG",language)
        archive = StringTools::replace(config::getProperty(ConfigurationKeys::CAS_ARCHIVE,nil),"%LANG",language)
        className = StringTools::replace(config::getProperty(ConfigurationKeys::CAS_CLASS,nil),"%LANG",language)
        output::add(printCAS(codebase,archive,className))
      else 
        output::add(printCASContainer(config,availableLanguages,language))
      end
      return output::toString()
    end
    def getAvailableCASLanguages(languageString)
      langs = Std::split(languageString,",")
      availableLanguages = Array.new()
      iter = langs::iterator()
      while iter::hasNext()
        elem = iter::next()
        elem = StringTools::trim(elem)
        availableLanguages::push(elem)
      end
      if availableLanguages::length()==0
        availableLanguages = Array.new()
        availableLanguages::push("")
      end
      return availableLanguages
    end
    def printCAS(codebase,archive,className)
      output = StringBuf.new()
      output::add("<html><head><style type=\"text/css\">/*<!--*/ html, body { height: 100%; } body { overflow: hidden; margin: 0; } applet { height: 100%; width: 100%; } /*-->*/</style></head>")
      output::add("<body><applet id=\"applet\" alt=\"WIRIS CAS\" codebase=\"")
      output::add(htmlentities(codebase,true))
      output::add("\" archive=\"")
      output::add(htmlentities(archive,true))
      output::add("\" code=\"")
      output::add(htmlentities(className,true))
      output::add("\"><p>You need JAVA&reg; to use WIRIS tools.<br />FREE download from <a target=\"_blank\" href=\"http://www.java.com\">www.java.com</a></p></applet></body></html>")
      return output::toString()
    end
    def printCASContainer(config,availableLanguages,lang)
      output = StringBuf.new()
      output::add("<html><head><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"/><script>")
      output::add("var lang =\'")
      output::add(lang)
      output::add("/strings.js\';")
      output::add(" ")
      output::add(" var scriptsrc =  window.opener._wrs_conf_path + \'/lang/\' + lang;")
      output::add(" var script = document.createElement(\'script\'); ")
      output::add(" script.src = scriptsrc;")
      output::add(" document.head.appendChild(script);")
      output::add("</script><script>")
      output::add("var scriptsrc = window.opener._wrs_conf_path + \'/core/cas.js\'; ")
      output::add(" var script = document.createElement(\'script\'); ")
      output::add(" script.src = scriptsrc;")
      output::add(" document.head.appendChild(script);")
      output::add("</script>")
      output::add("<title>WIRIS CAS</title><style type=\"text/css\">")
      output::add("/*<!--*/ html, body, #optionForm { height: 100%; } body { overflow: hidden; margin: 0; } #controls { width: 100%; } /*-->*/</style></head>")
      output::add("<body><form id=\"optionForm\"><div id=\"appletContainer\"></div><table id=\"controls\"><tr><td>Width</td><td><input name=\"width\" type=\"text\" value=\"")
      output::add(config::getProperty(ConfigurationKeys::CAS_WIDTH,nil))
      output::add("\"/></td><td><input name=\"executeonload\" type=\"checkbox\"/> Calculate on load")
      output::add("</td><td><input name=\"toolbar\" type=\"checkbox\" checked /> Show toolbar</td><td>Language <select id=\"languageList\">")
        for i in 0..availableLanguages::length()-1
          language = htmlentities(availableLanguages::_(i),true)
          output::add("<option value=\"")
          output::add(language)
          output::add("\">")
          output::add(language)
          output::add("</option>")
          i+=1
        end
      output::add("</select></td></tr><tr><td>Height</td><td><input name=\"height\" type=\"text\" value=\"")
      output::add(config::getProperty(ConfigurationKeys::CAS_HEIGHT,nil))
      output::add("\"/></td><td><input name=\"focusonload\" type=\"checkbox\"/> Focus on load</td><td><input name=\"level\" type=\"checkbox\"/>")
      output::add("Elementary mode</td><td></td></tr><tr><td colspan=\"5\"><input id=\"submit\" value=\"Accept\" type=\"button\"/>")
      output::add("<input id=\"cancel\" value=\"Cancel\" type=\"button\"/></td></tr></table></form></body></html>")
      return output::toString()
    end
    def htmlentities(input,entQuotes)
      returnValue = StringTools::replace(input,"&","&amp;")
      returnValue = StringTools::replace(returnValue,"<","&lt;")
      returnValue = StringTools::replace(returnValue,">","gt;")
      if entQuotes
        returnValue = StringTools::replace(returnValue,"\"","&quot;")
        return returnValue
      end
      return returnValue
    end
    def self.decodeBase64(imageParameter)
      b = Base64.new()
      dataDecoded = b::decodeBytes(Bytes::ofString(imageParameter))
      return dataDecoded
    end
  end
end
