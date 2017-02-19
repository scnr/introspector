module SCNR
module Engine
class Issue

    # Reproduces the issue with HTTP request tracing enabled, retrieve via
    # `issue.request.trace`.
    #
    # @param    [Hash]  options
    #   Scan `:trace` options.
    #
    # @return   [Issue, nil]
    #   Issue with traced requests, `nil` if the issue could not be reproduced.
    def with_trace( options = {} )
        Introspector.recheck_issue( self, trace: options.merge( with_context: true ) )
    end

end
end
end
