require 'binding_of_caller'

module Arachni
module Introspector
class Coverage
class Point

class StackFrame

    attr_accessor :point

    def initialize( point )
        @point   = point
        self.class.callers[@point.id] ||= @point.context.callers
    end

    def callers
        self.class.callers[@point.id]
    end

    def context
        point.context
    end

    def eval( code )
        context.eval( code )
    end

    def method_definition
        @method_definition ||= eval( 'method(__method__).source_location' ) rescue nil
    end

    def inside_method
        @inside_method ||= eval( '__method__' )
    end

    def object
        eval( 'self' )
    end

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

    def instance_variables
        return {} if !context

        Hash[context.eval( 'instance_variables' ).map { |x|
            [x, context.eval( x.to_s )]
        }]
    end

    def inspect
        s = "#{object.class}"

        return s if !inside_method
        s << "##{inside_method}"

        mp, ml = method_definition || []
        return s if !ml

        s << "@#{mp}:#{ml}"
    end

    class <<self
        def callers
            @callers ||= {}
        end
    end
end

end
end
end
end
