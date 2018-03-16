class WirisTest
	def dispatch(request, pb)
		r = pb.newTest().getTestPage()
		return r
	end
end