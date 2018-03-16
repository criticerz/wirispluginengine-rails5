module WirisPlugin
include  Wiris
  class HttpImpl < Http
  include Wiris

    attr_accessor :data
    attr_accessor :listener
    def initialize(url,listener)
      super(url)
      @listener = listener
    end
    def request(post)
      proxy = getProxy()
      if ((proxy!=nil)&&(proxy::host!=nil))&&(proxy::host::length()>0)
        hpa = (proxy::auth)
        if (hpa::user!=nil)&&(hpa::user::length()>0)
          data = Base64.new()::encodeBytes(Bytes::ofString((hpa::user.to_s+":")+hpa::pass.to_s))::toString()
          setHeader("Proxy-Authorization","Basic "+data)
        end
      end
      super(post)
    end
    def onData(data)
      @data = data
      if @listener!=nil
        @listener::onData(data)
      end
    end
    def onError(msg)
      if @listener!=nil
        @listener::onError(msg)
      else 
        raise Exception,msg
      end
    end
    def getData()
      return @data
    end
    def getProxy()
      proxy = Reflect::field(Http,"PROXY")
      if proxy==nil
        return nil
      end
      return (proxy)
    end
    def setProxy(proxy)
      Reflect::setField(Http,"PROXY",proxy)
    end
    def setListener(listener)
      @listener = listener
    end
  end
end
