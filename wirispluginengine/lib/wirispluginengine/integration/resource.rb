class Resource
	def dispatch(response, provider, pb)
		resource = provider.getRequiredParameter('resourcefile');
		resourceLoader = pb.newResourceLoader()
		response.content_type = resourceLoader.getContentType(resource)
		return resourceLoader.getContent(resource)
	end
end
