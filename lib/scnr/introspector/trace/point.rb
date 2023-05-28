module SCNR
class Introspector
class Trace

# Trace point, similar in function to a native Ruby TracePoint.
# Points to a code execution {#event}.
class Point

    # @return   [String,nil]
    #   Path to the source file, `nil` if no file is available (i.e. compiled code).
    attr_accessor :path

    # @return   [Integer,nil]
    #   File line number, `nil` if no file is available (i.e. compiled code).
    attr_accessor :line_number

    # @return   [String]
    #   Class name containing the point.
    attr_accessor :class_name

    # @return   [Symbol]
    #   Name of method associated with the {#event}.
    attr_accessor :method_name

    # @return   [Symbol]
    #   Event name.
    attr_accessor :event

    # @return   [Time]
    #   Time of logging.
    attr_accessor :timestamp

    # @param    [Hash]  options
    def initialize( options = {} )
        options.each do |k, v|
            next if v.nil?

            send( "#{k}=", v )
        end
    end

    def inspect
        "#{path}:#{line_number} #{class_name}##{method_name} #{event}"
    end

    def marshal_dump
        instance_variables.inject( {} ) do |h, iv|
            h[iv.to_s.gsub('@','')] = instance_variable_get( iv )
            h
        end
    end

    def marshal_load( h )
        h.each { |k, v| instance_variable_set( "@#{k}", v ) }
    end

    def to_rpc_data
        marshal_dump.merge( 'timestamp' => timestamp.to_s )
    end

    def self.from_rpc_data( data )
        n = self.new
        n.marshal_load( data )
        n.timestamp = Time.new( n.timestamp )
        n
    end

    class <<self

        # @param    [TracePoint]    tp
        #   Ruby TracePoint object.
        # @param    [Hash]  options
        #   Options for {#initialize}, will override the `tp` data.
        #
        # @return   [Point]
        def from_trace_point( tp, options = {} )
            defined_class =
                (tp.defined_class.is_a?( Class ) || tp.defined_class.is_a?( Module ) ?
                    tp.defined_class.name : tp.defined_class.class.name)

            new({
                path:        tp.path,
                line_number: tp.lineno,
                class_name:  defined_class,
                method_name: tp.method_id,
                event:       tp.event,
                timestamp:   Time.now
            }.merge( options ))
        end
    end

    protected

    def context=( b )
        self.class.bindings[@id] ||= b
    end

end

end
end
end
