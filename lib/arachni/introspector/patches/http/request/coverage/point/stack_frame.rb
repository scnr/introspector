require 'binding_of_caller'

module Arachni
module HTTP
class Request
class Coverage
class Point

class StackFrame

    # @return   [Point]
    #   Parent {Point}.
    attr_accessor :point

    # @note {#callers} will be captured at this point to avoid losing references
    #   to them due to the stackframe being popped during code execution.
    #
    # @param   [Point]  point
    #   Parent {Point}.
    def initialize( point )
        @point = point
        self.class.callers[@point.id] ||= @point.context.callers if @point.context
    end

    # @return   [Array<Binding>]
    #   Bindings of previous stack frames.
    def callers
        self.class.callers[@point.id]
    end

    # @return (see Point#context)
    def context
        point.context
    end

    # @param   [String]    code
    #   Code to execute under the {#context} of the frame.
    def eval( code )
        context.eval( code )
    end

    # @return   [Array]
    #   Location and line number of the {#container_method}.
    def method_definition
        @method_definition ||= eval( 'method(__method__).source_location' ) rescue nil
    end

    # @return   [Symbol,nil]
    #   Name of the method to which the {#context} belongs.
    def container_method
        @inside_method ||= eval( '__method__' )
    end

    # @return   [Object]
    #   {#context} `self`.
    def object
        eval( 'self' )
    end

    # @return   [Hash]
    #   Local variables under the {#context}.
    def local_variables
        return {} if !context

        context.eval( 'local_variables' ).each_with_object({}) do |name, hash|
            if defined?( context.local_variable_get )
                hash[name] = context.local_variable_get( name )
            else
                hash[name] = context.eval( name.to_s )
            end
        end
    end

    # @return   [Hash]
    #   Instance variables of {#object}.
    def instance_variables
        return {} if !context

        Hash[context.eval( 'instance_variables' ).map { |x|
            [x, context.eval( x.to_s )]
        }]
    end

    def inspect
        s = "#{object.class}"

        return s if !container_method
        s << "##{container_method}"

        mp, ml = method_definition || []
        return s if !ml

        s << "@#{mp}:#{ml}"
    end

    class <<self

        # Provides out-of-instance storage for non-serializable bindings.
        #
        # @private
        def callers
            @callers ||= {}
        end
    end
end

end
end
end
end
end
