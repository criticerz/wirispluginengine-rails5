class Service
    def dispatch(request, response, provider, pb)
        r = pb.newTextService().service(provider.getRequiredParameter('service'), provider);
        return r
    end
end