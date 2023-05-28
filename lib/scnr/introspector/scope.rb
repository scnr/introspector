module SCNR
class Introspector
class Scope

    class Error < Introspector::Error
        class Invalid < Error
        end

        class UnknownOption < Error
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

    # @param    [Hash]  options
    #   Sets instance attributes.
    def initialize( options = {} )
        options.each do |k, v|
            begin
                send( "#{k}=", v )
            rescue NoMethodError
                fail "Unknown option: #{k}", Error::UnknownOption
            end
        end

        @path_include_patterns ||= []
        @path_exclude_patterns ||= []
    end

    # @return   [Bool]
    #   `true` if scope has no configuration, `false` otherwise.
    def empty?
        !@path_start_with && !@path_end_with && @path_include_patterns.empty? &&
            @path_exclude_patterns.empty?
    end

    # @param    [String]    path
    #   Path to check.
    #
    # @return   [Bool]
    #   `true` if `path` is not `#in?` scope, `false` otherwise.
    def out?( path )
        !in?( path )
    end

    # @param    [String]    path
    #   Path to check.
    #
    # @return   [Bool]
    #   `true` if `path` is `#in?` scope, `false` otherwise.
    def in?( path )
        if @path_start_with
            return path.to_s.start_with?( @path_start_with )
        end

        if @path_end_with
            return path.to_s.end_with?( @path_end_with )
        end

        if @path_include_patterns.any?
            @path_include_patterns.each do |pattern|
                return true if path =~ pattern
            end

            return false
        end

        if @path_exclude_patterns.any?
            @path_exclude_patterns.each do |pattern|
                return false if path =~ pattern
            end
        end

        true
    end

    def hash
        [@path_start_with, @path_end_with, @path_include_patterns, @path_exclude_patterns].hash
    end

    def ==( other )
        hash == other.hash
    end

end

end
end
