class ConfigurationJson
	def dispatch (request, response, provider, pb)
		variableKeys = provider.getRequiredParameter('variablekeys')
		conf = pb.getConfiguration()
		response.body = conf.getJsonConfiguration(variableKeys)
  	end
end