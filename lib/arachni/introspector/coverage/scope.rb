module Arachni
module Introspector
class Coverage

class Scope

    # @return   [String,nil]
    #   Include trace points whose file path starts with this string.
    attr_accessor :path_start_with

    # @return   [String,nil]
    #   Include trace points whose file path ends with this string.
    attr_accessor :path_end_with

    # @return   [Array<Regexp>,nil]
    #   Include trace points whose file path matches this pattern.
    attr_accessor :path_include_patterns

    # @return   [Array<Regexp>,nil]
    #   Exclude trace points whose file path matches this pattern.
    attr_accessor :path_exclude_patterns

    # @return   [#call,nil]
    #   Block used to determine whether or not to include a native `TracePoint`
    #   in the trace.
    attr_accessor :filter

    # @param    [Hash]  options
    #   Sets instance attributes.
    def initialize( options = {} )
        options.each do |k, v|
            send( "#{k}=", v )
        end
    end

    # @param    [TracePoint]    point
    #   Point to check. This is a native Ruby TracePoint, not an {Introspector}
    #   {Point}.
    #
    # @return   [Bool]
    #   `true` if `point` is not `#in?` scope, `false` otherwise.
    def out?( point )
        !in?( point )
    end

    # @param    [TracePoint]    point
    #   Point to check. This is a native Ruby TracePoint, not an {Introspector}
    #   {Point}.
    #
    # @return   [Bool]
    #   `true` if `point` is `#in?` scope, `false` otherwise.
    def in?( point )
        if @path_start_with
            return point.path.to_s.start_with?( @path_start_with )
        end

        if @path_end_with
            return point.path.to_s.end_with?( @path_end_with )
        end

        if @path_include_patterns
            @path_include_patterns.each do |pattern|
                return true if point.path =~ pattern
            end

            return false
        end

        if @path_exclude_patterns
            @path_exclude_patterns.each do |pattern|
                return false if point.path =~ pattern
            end
        end

        return !!@filter.call( point ) if @filter

        true
    end

end

end
end
end
