class CreateImage
	def dispatch(request, response, provider, pb)
		mml = provider.getRequiredParameter('mml');
		render = pb.newRender()
		a = render.createImage(mml, provider, nil)
		return a
	end
end