module Wiris
	class HttpResponse
		def actionController
			@actionController
		end

		def actionController=(actionController)
			@actionController=actionController
		end
		def res
			@res
		end
		def headers=(headers)
			@headers = headers
		end

		def headers
			@headers
		end

		def out=(out)
			@out=out
		end

		def out
			@out
		end

		def writing
			@writing
		end

		def writing=(writing)
			@writing=writing
		end

		def writeString(s)
			@writing = true
			@out = @out + s
		end

		def writeBinary(data)
			writeString(data.toString())
		end

		def initialize(actionController)
			@closed=false
			@actionController = actionController
			@writing=false
			@out = ""
			@res = actionController.response
			@headers = Hash.new()
		end

		def setHeader(name, value)
			@headers.set(name, value)
			@res.headers[name] = value
		end

		def getHeader(name)
			return @headers.get(name)
		end

		def close
			@res.close
			if @writing
				actionController.render :text => @out
			end
		end
	end
end