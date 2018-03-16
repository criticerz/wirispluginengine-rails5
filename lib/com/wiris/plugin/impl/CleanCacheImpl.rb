module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ConfigurationKeys.rb')
require('com/wiris/util/json/JSon.rb')
require('com/wiris/plugin/api/CleanCache.rb')
  class CleanCacheImpl
  extend CleanCacheInterface

  include Wiris

    attr_accessor :plugin
    attr_accessor :token
    attr_accessor :newToken
    attr_accessor :wirisCleanCacheToken
    attr_accessor :validToken
    attr_accessor :accept
    attr_accessor :gui
    attr_accessor :storage
    attr_accessor :cleanCachePath
    attr_accessor :resourcePath
    def initialize(pb)
      super()
      @plugin = pb
    end
    def init(param)
      @storage = @plugin::getStorageAndCache()
      @token = param::getParameter("token",nil)
      @newToken = param::getParameter("newtoken",nil)
      @wirisCleanCacheToken = @plugin::getConfiguration()::getProperty(ConfigurationKeys::CLEAN_CACHE_TOKEN,nil)
      @accept = (param::getParameter("accept",nil)!=nil)&&(param::getParameter("accept","")=="application/json") ? true : false
      @gui = isGui()
      @validToken = validateToken(@wirisCleanCacheToken,@token)
      @cleanCachePath = @plugin::getConfiguration()::getProperty(ConfigurationKeys::CLEAN_CACHE_PATH,"")
      @resourcePath = @plugin::getConfiguration()::getProperty(ConfigurationKeys::RESOURCE_PATH,"")
      if (@token!=nil)&&@validToken
        deleteCache()
      end
    end
    def deleteCache()
      @storage::deleteCache()
    end
    def getCacheOutput()
      if @gui
        output = ""
        output+="<html><head>\r\n"
        output+="<title>WIRIS plugin clean cache service</title><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\" />\r\n"
        output+=("<link rel=stylesheet type=text/css href="+@resourcePath)+"?resourcefile=wirisplugin.css />"
        output+="</head>"
        output+="<div class=wirismaincontainer>"
        output+="<body class=wirisplugincleancache>"
        output+="<h2 class=wirisplugincleancache>WIRIS plugin clean cache service</h2>\r\n"
        output+="<div class=wirisplugincleancacheform>"
        if @wirisCleanCacheToken!=nil
          output+=("<form action="+@cleanCachePath)+" method=post>"
          output+="<span class=wirisplugincleancachetextform> Security token </span><input type=password autocomplete=off name=token>"
          output+="<input type=\"submit\" value=\"Submit\">"
          output+="</form>"
        end
        output+=("<form action="+@cleanCachePath)+" method=post>"
        output+="<span class=wirisplugincleancachetextform> Generate token </span> <input type=text name=newtoken>"
        output+="<input type=\"submit\" value=\"Submit\">"
        output+="</form>"
        output+="</div>"
        output+="<div class=wirisplugincleancacheresults>"
        if (@token!=nil)&&!@validToken
          output+="<span class=wirisplugincleancachewarning> Invalid Token </span>"
        else 
          if @validToken&&(@token!=nil)
            output+="<span class=wirisplugincleancachewarning> Cache deleted successfully </span>"
          else 
            if @newToken!=nil
              output+=" Your new token is: <br>"
              output+=("<span class=wirisplugincleancachewarning>"+Md5::encode(@newToken).to_s)+"</span> <br>"
              output+=" Please copy it to your configuration.ini file <br>"
              output+=" For more information see <a href=http://www.wiris.com/plugins/docs/resources/configuration-table style=text-decoration:none>Server configuration file documentation</a>"
            end
          end
        end
        output+="</div>"
        output+="</div>"
        return output
      else 
        jsonOutput = Hash.new()
        if !@validToken
          jsonOutput::set("status","error")
        else 
          jsonOutput::set("status","ok")
        end
        return JSon::encode(jsonOutput)
      end
    end
    def getContentType()
      if !@gui
        return "application/json"
      else 
        return "text/html charset=UTF-8"
      end
    end
    def validateToken(md5Token,token)
      if (token!=nil)&&(md5Token!=nil)
        return (md5Token==Md5Tools::encodeString(token))
      else 
        return false
      end
    end
    def isGui()
      wirisCacheGui = (@plugin::getConfiguration()::getProperty(ConfigurationKeys::CLEAN_CACHE_GUI,"false")=="true")
      return wirisCacheGui&&!@accept
    end
  end
end
