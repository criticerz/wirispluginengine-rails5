module WirisPlugin
include  Wiris
  class HttpConnection < Http
  include Wiris

    attr_accessor :listener
    def initialize(url,listener)
      super(url)
      @listener = listener
    end
    def onData(data)
      listener::onHTTPData(data)
    end
    def onError(error)
      listener::onHTTPError(error)
    end
  end
end
