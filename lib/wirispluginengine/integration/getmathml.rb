class GetMathMLDispatcher
    def dispatch(request, response, provider, pb)
        digest = nil
        latex = provider.getParameter("latex", nil)
        md5Parameter = provider.getParameter("md5", nil)

        if (md5Parameter != nil && md5Parameter.length() == 32)  # Support for "generic simple" integration.
            digest = md5Parameter
        else
            String digestParameter = request.getParameter("digest")
            if (digestParameter != nil) # Support for future integrations (where maybe they aren't using md5 sums).
                digest = digestParameter
            end
        end
        r = pb.newTextService().getMathML(digest, latex)
        return r
    end
end
