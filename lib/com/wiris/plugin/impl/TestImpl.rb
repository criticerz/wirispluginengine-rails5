module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/plugin/impl/HttpImpl.rb')
require('com/wiris/plugin/api/Test.rb')
  class TestImpl
  extend TestInterface

  include Wiris

    attr_accessor :plugin
    def initialize(plugin)
      super()
      @plugin = plugin
    end
    def getTestPage()
      random = ""+(Math::random()*9999).to_s
      mml = ("<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><mrow><msqrt><mn>"+random)+"</mn></msqrt></mrow></math>"
      output = ""
      output+="<html><head>\r\n"
      output+="<title>WIRIS plugin test page</title><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\" /><style type=\"text/css\">/*<!--*/html {font-family: sans-serif;}h2 {margin-left: 1em;}h3 {margin-left: 2em;}p {margin-left: 3em;}p.concrete {margin-left: 4em;}.ok {font-weight: bold;color: #0c0;}.error {font-weight: bold;color: #f00;}/*-->*/</style><style type=\"text/css\">body{font-family: Arial;}span{font-weight: bold;}span.ok {color: #009900;}span.error {color: #dd0000;}table, th, td, tr {border: solid 1px #000000;border-collapse:collapse;padding: 5px;}th{background-color: #eeeeee;}img{border:none;}</style>\r\n"
      output+="<script src=\"../core/WIRISplugins.js?viewer=image\" ></script>\r\n"
      output+="</head><body><h1>WIRIS plugin test page</h1>\r\n"
      output+="<table><tr><th>Test</th><th>Report</th><th>Status</th></tr>\r\n"
      testName = "WIRIS plugin version"
      begin
      s = Storage::newResourceStorage("VERSION")::read()
      reportText = ("<b>"+s)+"</b>"
      solutionLink = ""
      condition = true
      end
      output+=createTableRow(testName,reportText,solutionLink,condition)
      testName = "Creating and storing data"
      solutionLink = ""
      param = PropertiesTools::newProperties()
      outp = PropertiesTools::newProperties()
      provider = @plugin::newGenericParamsProvider(param)
      imageUrl = plugin::newRender()::createImage(mml,provider,outp)
      reportText = ((("<a href=\""+imageUrl)+"\" />")+imageUrl)+"</a>"
      condition = true
      output+=createTableRow(testName,reportText,solutionLink,condition)
      testName = "Retrieving data"
      solutionLink = ""
      reportText = ("<img src=\""+imageUrl)+"\" />"
      output+=createTableRow(testName,reportText,solutionLink,condition)
      testName = "JavaScript MathML filter"
      solutionLink = ""
      reportText = mml
      output+=createTableRow(testName,reportText,solutionLink,condition)
      testName = "Host platform"
      solutionLink = ""
      platform = plugin::getConfiguration()::getProperty(ConfigurationKeys::HOST_PLATFORM,"failed")
      reportText = platform
      output+=createTableRow(testName,reportText,solutionLink,condition)
      testName = "Filter test"
      solutionLink = ""
      condition = true
      p = PropertiesTools::newProperties()
      PropertiesTools::setProperty(p,"savemode","safeXml")
      s2 = StringTools::replace(mml,"<",Std::fromCharCode(171))
      s2 = StringTools::replace(s2,">",Std::fromCharCode(187))
      s2 = StringTools::replace(s2,"\"",Std::fromCharCode(168))
      reportText = plugin::newTextService()::filter("square root: "+s2,p)
      output+=createTableRow(testName,reportText,solutionLink,condition)
      testName = "Connecting to www.wiris.net"
      solutionLink = ""
      condition = true
      begin
      h = HttpImpl.new("http://www.wiris.net",nil)
      h::request(true)
      end
      reportText = "Checking if WIRIS server is reachable"
      output+=createTableRow(testName,reportText,solutionLink,condition)
      if Type::resolveClass("com.wiris.editor.services.PublicServices")!=nil
        condition = true
        testName = "Testing integrated services"
        reportText = "WIRIS Services installed"
        solutionLink = ""
        output+=createTableRow(testName,reportText,solutionLink,condition)
        isLicensed = plugin::isEditorLicensed()
        condition = false
        testName = "WIRIS editor license"
        reportText = "Checking WIRIS editor valid license"
        output+=createTableRow(testName,reportText,solutionLink,isLicensed)
      else 
        reportText = "WIRIS Services not installed"
      end
      debug = (plugin::getConfiguration()::getProperty(ConfigurationKeys::DEBUG,"false")=="true")
      if debug
        testName = "Font family"
        solutionLink = ""
        condition = true
        reportText = plugin::getConfiguration()::getProperty(ConfigurationKeys::FONT_FAMILY,"")
        output+=createTableRow(testName,reportText,solutionLink,condition)
        testName = "Configuration file"
        solutionLink = ""
        condition = true
        reportText = plugin::getConfiguration()::getProperty(ConfigurationKeys::CONFIGURATION_PATH,"")+"\\configuration.ini"
        output+=createTableRow(testName,reportText,solutionLink,condition)
        testName = "Cache path"
        solutionLink = ""
        condition = true
        reportText = plugin::getConfiguration()::getProperty(ConfigurationKeys::CACHE_FOLDER,"")
        output+=createTableRow(testName,reportText,solutionLink,condition)
        testName = "Formula path"
        solutionLink = ""
        condition = true
        reportText = plugin::getConfiguration()::getProperty(ConfigurationKeys::FORMULA_FOLDER,"")
        output+=createTableRow(testName,reportText,solutionLink,condition)
        testName = "Integration path"
        solutionLink = ""
        condition = true
        reportText = plugin::getConfiguration()::getProperty(ConfigurationKeys::INTEGRATION_PATH,"")
        output+=createTableRow(testName,reportText,solutionLink,condition)
        testName = "Context path"
        solutionLink = ""
        condition = true
        reportText = plugin::getConfiguration()::getProperty(ConfigurationKeys::CONTEXT_PATH,"")
        output+=createTableRow(testName,reportText,solutionLink,condition)
        testName = "default-configuration.ini load"
        solutionLink = ""
        defaultConfiguration = Storage::newResourceStorage("default-configuration.ini")::read()
        condition = (defaultConfiguration!=nil)&&(defaultConfiguration::length()>0)
        if condition
          reportText = "Length: "+defaultConfiguration::length().to_s
        else 
          reportText = "Not found!"
        end
        output+=createTableRow(testName,reportText,solutionLink,condition)
        testName = "cas.png load"
        solutionLink = ""
        casPng = Storage::newResourceStorage("cas.png")::readBinary()
        casPngLength = 0
        if casPng!=nil
          casPngLength = Bytes::ofData(casPng)::length()
          condition = casPngLength>0
        else 
          condition = false
        end
        if condition
          reportText = "Length: "+casPngLength.to_s
        else 
          reportText = "Not found!"
        end
        output+=createTableRow(testName,reportText,solutionLink,condition)
      end
      output+="<div id=\"haxe:trace\"></div>"
      return output
    end
    def createTableRow(testName,reportText,solutionLink,condition)
      output = ""
      output+="<tr>"
      output+=("<td>"+testName)+"</td>"
      output+=("<td>"+reportText)+"</td>"
      output+="<td>"
      if condition
        output+="<span class=\"ok\">OK</span><br/>"
      else 
        output+="<span class=\"error\">ERROR</span><br/>"
      end
      output+="</td>"
      output+="</tr>\r\n"
      return output
    end
  end
end
