class CleanCache
	def dispatch(request, response, provider, pb)
		cleanCache = pb.newCleanCache()
		cleanCache.init(provider)
		response.content_type = cleanCache.getContentType();
		return cleanCache.getCacheOutput()
	end
end
