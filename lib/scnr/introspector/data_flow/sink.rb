module SCNR
class Introspector
class DataFlow

class Sink

    attr_accessor :object

    attr_accessor :method_name

    attr_accessor :arguments

    attr_accessor :tainted_argument_index

    attr_accessor :tainted_value

    attr_accessor :backtrace

    # @param    [Hash]  options
    def initialize( options = {} )
        options.each do |k, v|
            next if v.nil?

            send( "#{k}=", v )
        end
    end

    def marshal_dump
        instance_variables.inject( {} ) do |h, iv|
            h[iv.to_s.gsub('@','')] = instance_variable_get( iv )
            h
        end
    end

    def to_rpc_data
        marshal_dump.merge 'arguments' => arguments.map(&:to_s)
    end

    def marshal_load( h )
        h.each { |k, v| instance_variable_set( "@#{k}", v ) }
    end

    def self.from_rpc_data( data )
        n = self.new
        n.marshal_load( data )
        n
    end

end

end
end
end
