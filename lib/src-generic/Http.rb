require "net/http"
require "uri"

module Wiris
  class Http
    #
    #  The server myURL.
    #
    #
    @url
    @postData
    @headers
    @params
    @connection
    @@PROXY=nil


    def self.PROXY=(proxy)
      @@PROXY = proxy
    end

    def self.PROXY
      @@PROXY
    end

    def initialize(url)
      @url = url
      @headers = Hash.new()
      @params = Hash.new()
    end

    def request(post)
  #     try{
      serializedParams = formEncode(@params)
      uri = URI.parse(@url)

      unless @@PROXY.nil?
        @connection = @@PROXY.start(uri.host, uri.port)
      else
        @connection = Net::HTTP.new(uri.host, uri.port)
      end

      if !post
        uri.query = serializedParams
        request = Net::HTTP::Get.new(uri.request_uri)
      else
        request = Net::HTTP::Post.new(uri.request_uri)
        # request.set_form_data(@params)
        request.body = @postData != nil ? @postData : serializedParams

      end

      keys = @headers.keys()
      
      while keys.hasNext()
        key = keys.next()
        request.add_field(key, @headers.get(key))
      end

      response = @connection.request(request)

      onData(response.body)
    end

     def formEncode(params)
      i = params.keys()
      sb = StringBuf.new()
      first = true;
      while (i.hasNext())
         if(!first)
           sb.add("&");
         else
           first = false;
         end
        key = i.next();
        sb.add(StringTools.urlEncode(key));
        sb.add("=");
        sb.add(StringTools.urlEncode(params.get(key)));
      end
      return sb.toString();
    end


    def setHeader(header, value)
      @headers.set(header,value)
    end

  #
  #  Sets a parameter to be sent in the request. Multiple parameters can be set 
  #  by making multiple setParameter calls.
  #
    def setParameter(param, value)
      @params.set(param,value);
    end

   def setPostData(data)
      @postData = data;
   end

   def onData(data)
   end

   def onError(msg)
   end

  end
end