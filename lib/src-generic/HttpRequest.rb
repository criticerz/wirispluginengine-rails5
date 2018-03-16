module Wiris
	class HttpRequest
		attr_accessor  :params

		def initialize(params)
			@params = params;
		end

		def getParameter(key)
			if (self.params[key].nil?)
				return nil
			end
			return self.params[key]
		end

		def getContextURL()
			return nil
		end

		def getParameterNames
			return params.keys
		end
	end
end

