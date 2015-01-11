require 'arachni/introspector/patches/http/request/trace/point/stack_frame'

module Arachni
module HTTP
class Request
class Trace

# Trace point, similar in function to a native Ruby TracePoint.
# Points to a code execution {#event}.
class Point

    # @return   [Integer]
    #   Unique ID.
    attr_reader   :id

    # @return   [Trace]
    #   Parent coverage.
    attr_accessor :trace

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
        @id = self.class.increment_id

        options.each do |k, v|
            next if v.nil?

            send( "#{k}=", v )
        end

        stack_frame
    end

    # @return   [StackFrame, nil]
    #   Associated {StackFrame} or `nil` when not available (when running under
    #   JRuby, for example).
    def stack_frame
        return if !context
        @stack_frame ||= StackFrame.new( self )
    end

    def has_stack_frame?
        !!stack_frame
    end

    # @return   [Binding]
    #   Associated binding.
    def context
        self.class.bindings[@id]
    end

    def inspect
        "[#{timestamp}] #{path}:#{line_number} #{class_name}##{method_name} " +
            "#{event} in #{stack_frame.inspect}"
    end

    def marshal_dump
        trace_point  = @trace_point
        @trace_point = nil

        stack_frame  = @stack_frame
        @stack_frame = nil

        trace  = @trace
        @trace = nil

        instance_variables.inject( {} ) do |h, iv|
            h[iv.to_s.gsub('@','')] = instance_variable_get( iv )
            h
        end
    ensure
        @trace_point = trace_point
        @stack_frame = stack_frame
        @trace       = trace
    end

    def marshal_load( h )
        h.each { |k, v| instance_variable_set( "@#{k}", v ) }
    end

    class <<self

        # Provides out-of-instance storage for non-serializable bindings.
        #
        # @private
        def bindings
            @bindings ||= {}
        end

        # Increments the {Point#id} to be used for the next instance.
        #
        # @private
        def increment_id
            @id ||= 0
            @id += 1
        end

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
                context:     tp.binding,
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
end
