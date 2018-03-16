module WirisPlugin
include  Wiris
require('com/wiris/plugin/api/ServiceResourceLoader.rb')
  class ServiceResourceLoaderImpl
  extend ServiceResourceLoaderInterface

  include Wiris

    def initialize()
      super()
    end
    def getContent(resource)
      return Storage::newResourceStorage(resource)::read()
    end
    def getContentType(name)
      ext = Std::substr(name,name::lastIndexOf(".")+1)
      if (ext=="png")
        return "image/png"
      else 
        if (ext=="gif")
          return "image/gif"
        else 
          if (ext=="jpg")||(ext=="jpeg")
            return "image/jpeg"
          else 
            if (ext=="html")||(ext=="htm")
              return "text/html"
            else 
              if (ext=="css")
                return "text/css"
              else 
                if (ext=="js")
                  return "application/javascript"
                else 
                  if (ext=="txt")
                    return "text/plain"
                  else 
                    if (ext=="ini")
                      return "text/plain"
                    else 
                      return "application/octet-stream"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
