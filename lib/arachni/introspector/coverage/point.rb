require 'binding_of_caller'
require 'arachni/introspector/coverage/point/stack_frame'

module Arachni
module Introspector
class Coverage

class Point

    attr_reader :id
    attr_reader :stack_frame

    attr_accessor :coverage
    attr_accessor :path
    attr_accessor :line_number
    attr_accessor :class_name
    attr_accessor :method_name
    attr_accessor :event
    attr_accessor :timestamp

    def initialize( options = {} )
        @id ||= self.class.increment_id

        options.each do |k, v|
            send( "#{k}=", v )
        end

        stack_frame
    end

    def stack_frame
        @stack_frame ||= StackFrame.new( self )
    end

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

        coverage  = @coverage
        @coverage = nil

        instance_variables.inject( {} ) do |h, iv|
            h[iv.to_s.gsub('@','')] = instance_variable_get( iv )
            h
        end
    ensure
        @trace_point = trace_point
        @stack_frame = stack_frame
        @coverage    = coverage
    end

    def marshal_load( h )
        h.each { |k, v| instance_variable_set( "@#{k}", v ) }
    end

    class <<self
        def bindings
            @bindings ||= {}
        end

        def increment_id
            @id ||= 0
            @id += 1
        end

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
