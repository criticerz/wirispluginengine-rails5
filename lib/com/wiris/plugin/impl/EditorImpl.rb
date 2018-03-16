module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/plugin/api/Editor.rb')
  class EditorImpl
  extend EditorInterface

  include Wiris

    attr_accessor :plugin
    def initialize(plugin)
      super()
      @plugin = plugin
    end
    def editor(language,provider)
      output = StringBuf.new()
      if (language==nil)||(language::length()==0)
        language = "en"
      end
      language = language::toLowerCase()
      StringTools::replace(language,"-","_")
      store = Storage::newResourceStorage(("lang/"+language)+"/strings.js")
      if !store::exists()
        store = Storage::newResourceStorage(("lang/"+Std::substr(language,0,2).to_s)+"/strings.js")
        language = Std::substr(language,0,2)
        if !store::exists()
          language = "en"
        end
      end
      attributes = StringBuf.new()
      attributes::add("")
      confVal = ""
      i = 0
      config = @plugin::getConfiguration()
      h = ConfigurationKeys::imageConfigPropertiesInv
      it = h::keys()
      while it::hasNext()
        value = it::next()
        if config::getProperty(value,nil)!=nil
          if i!=0
            attributes::add(",")
          end
          i+=1
          confVal = config::getProperty(value,nil)
          StringTools::replace(confVal,"-","_")
          StringTools::replace(confVal,"-","_")
          attributes::add("\'")
          attributes::add(ConfigurationKeys::imageConfigPropertiesInv::get(value))
          attributes::add("\' : \'")
          attributes::add(confVal)
          attributes::add("\'")
        end
      end
      script = StringBuf.new()
      if i>0
        script::add("<script type=\"text/javascript\">window.wrs_attributes = {")
        script::add(attributes)
        script::add("};</script>")
      end
      editorUrl = @plugin::getImageServiceURL("editor",false)
      isSegure = (provider::getParameter("secure","false")=="true")
      if editorUrl::startsWith("http:")&&isSegure
        editorUrl = "https:"+Std::substr(editorUrl,5).to_s
      end
      addLine(output,"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">")
      addLine(output,"<html><head>")
      addLine(output,"<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"/>")
      addLine(output,script::toString())
      addLine(output,((("<script type=\"text/javascript\" src=\""+editorUrl)+"?lang=")+StringTools::urlEncode(language).to_s)+"\"></script>")
      addLine(output,"<script type=\"text/javascript\" src=\"../core/editor.js\"></script>")
      addLine(output,("<script type=\"text/javascript\" src=\"../lang/"+StringTools::urlEncode(language).to_s)+"/strings.js\"></script>")
      addLine(output,"<title>WIRIS editor</title>")
      addLine(output,"<style type=\"text/css\">/*<!--*/html, body, #container { height: 100%; } body { margin: 0; }")
      addLine(output,"#links { text-align: right; margin-right: 20px; } #links_rtl {text-align: left; margin-left: 20px;} #controls { float: left; } #controls_rtl {float: right;}/*-->*/</style>")
      addLine(output,"</head><body topmargin=\"0\" leftmargin=\"0\" marginwidth=\"0\" marginheight=\"0\">")
      addLine(output,"<div id=\"container\"><div id=\"editorContainer\"></div><div id=\"controls\"></div>")
      addLine(output,"<div id=\"links\"><a href=\"http://www.wiris.com/editor3/docs/manual/latex-support\" id=\"a_latex\" target=\"_blank\">LaTeX</a> | ")
      addLine(output,"<a href=\"http://www.wiris.com/editor3/docs/manual\" target=\"_blank\" id=\"a_manual\">Manual</a></div></div></body>")
      return output::toString()
    end
    def addLine(output,s)
      output::add(s)
      output::add("\r\n")
    end
  end
end
