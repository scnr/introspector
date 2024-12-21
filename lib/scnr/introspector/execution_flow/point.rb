require 'thread'

module SCNR
class Introspector
class ExecutionFlow

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

    attr_accessor :source

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
        marshal_dump
    end

    def self.from_rpc_data( data )
        n = self.new
        n.marshal_load( data )
        n
    end

    class <<self

        # @param    [TracePoint]    tp
        #   Ruby TracePoint object.
        #
        # @return   [Point]
        def from_trace_point( tp )
            defined_class =
                (tp.defined_class.is_a?( Class ) || tp.defined_class.is_a?( Module ) ?
                    tp.defined_class.name : tp.defined_class.class.name)

            new({
                path:        tp.path,
                line_number: tp.lineno,
                class_name:  defined_class,
                method_name: tp.method_id,
                event:       tp.event,
                source:      source_line( tp.path, tp.lineno )
            })
        end

        def source_line_mutex( &block )
            (@mutex ||= Mutex.new).synchronize( &block )
        end

        def source_line( path, line )
            return if !path || !line

            source_line_mutex do
                @@lines ||= {}
                @@lines[path] ||= IO.readlines( path )
                @@lines[path][line]
            end
        end
    end
    source_line_mutex {}

end

end
end
end
