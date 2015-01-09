module Arachni
module Introspector

class Scope

    class Error < Introspector::Error
        class Invalid < Error
        end
    end

    # @return   [String,nil]
    #   Include trace points whose file path starts with this string.
    attr_accessor :path_start_with

    # @return   [String,nil]
    #   Include trace points whose file path ends with this string.
    attr_accessor :path_end_with

    # @return   [Array<Regexp>]
    #   Include trace points whose file path matches this pattern.
    attr_accessor :path_include_patterns

    # @return   [Array<Regexp>]
    #   Exclude trace points whose file path matches this pattern.
    attr_accessor :path_exclude_patterns

    # @return   [Bool]
    #   Include runtime {Point#context} in the coverage data.
    attr_accessor :with_context

    # @param    [Hash]  options
    #   Sets instance attributes.
    def initialize( options = {} )
        options.each do |k, v|
            send( "#{k}=", v )
        end

        @path_include_patterns ||= []
        @path_exclude_patterns ||= []
    end

    def with_context?
        !!@with_context
    end

    def without_context?
        !with_context?
    end

    # @return   [Bool]
    #   `true` if scope has no configuration, `false` otherwise.
    def empty?
        !@path_start_with && !@path_end_with && @path_include_patterns.empty? &&
            @path_exclude_patterns.empty?
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

        if @path_include_patterns.any?
            @path_include_patterns.each do |pattern|
                return true if point.path =~ pattern
            end

            return false
        end

        if @path_exclude_patterns.any?
            @path_exclude_patterns.each do |pattern|
                return false if point.path =~ pattern
            end
        end

        true
    end

end

end
end
