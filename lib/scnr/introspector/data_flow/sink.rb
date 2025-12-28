require_relative '../utilities/my_method_source/code_helpers'

module SCNR
class Introspector
class DataFlow

class Sink

    attr_accessor :object

    attr_accessor :method_name
    attr_accessor :method_source
    attr_accessor :method_source_location

    attr_accessor :source

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

        if !@method_source && @method_source_location
            filepath = @method_source_location.first
            lineno   = @method_source_location.last

            if File.exist? filepath
                File.open filepath do |f|
                    begin
                        @method_source = MyMethodSource::CodeHelpers.expression_at( File.open( f ), lineno )
                    rescue SyntaxError
                    end
                end
            end
        end

        if !@source && @backtrace
            source_location = @backtrace.first.split( ':' ).first
            if File.exist? source_location
                @source = IO.read( source_location )
            end
        end
    end

    def marshal_dump
        instance_variables.inject( {} ) do |h, iv|
            h[iv.to_s.gsub('@','')] = instance_variable_get( iv )
            h
        end
    end

    def to_rpc_data
        marshal_dump.merge 'arguments' => arguments.map(&:to_json)
    end

    def marshal_load( h )
        h.each { |k, v| instance_variable_set( "@#{k}", v ) }
    end

    def self.from_rpc_data( data )
        n = self.new
        n.marshal_load( data )
        n.arguments = n.arguments.map { |a| ::JSON.load a }
        n
    end

end

end
end
end
