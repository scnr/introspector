module SCNR
module Engine

class Report

    # @return   [Introspector::Scan::Coverage]
    attr_accessor :coverage

    def to_h
        super.merge( coverage: coverage )
    end

    alias :old_to_rpc_data :to_rpc_data
    def to_rpc_data
        old_to_rpc_data.merge( 'coverage' => coverage )
    end

end

end
end
