require 'coverage'
require 'arachni/introspector/scan/coverage/resource'
require 'arachni/introspector/scan/coverage/scope'

module Arachni
module Introspector
class Scan
class Coverage

    # @return   [Scope]
    attr_accessor :scope

    # @return   [Hash<String, Resource>]
    #   All in-scope web application resources, per path.
    attr_reader   :resources

    # @param    [Hash]  options
    # @option   options     [Scope,Hash,nil]    :scope
    #   * {Scope}:  Configured {Scope} to use.
    #   * `Hash`:  `Hash` to use for {Scope#initialize}.
    #   * `nil`:  Will default to an empty {Scope}.
    #
    # @raise    [Introspector::Scope::Error::Invalid]
    #   On unsupported `:scope` option.
    def initialize( options = {} )
        options = options.dup

        if (scope = options.delete(:scope)).is_a? Scope
            @scope = scope
        elsif scope.is_a? Hash
            @scope = Scope.new( scope )
        elsif scope.nil?
            @scope = Scope.new
        else
            fail Scope::Error::Invalid
        end

        @resources = {}
    end

    def retrieve_results
        import_native( ::Coverage.result )
    end

    def import_native( coverage )
        coverage.each do |path, lines|
            next if @scope.out?( path )

            @resources[path] ||= Resource.new( path )

            lines.each.with_index do |hits, line_number|
                @resources[path][line_number].hit( hits )
            end
        end

        self
    end

    # @return   [Float]
    #   Percentage of coverage for all application resources which are within scope.
    def percentage
        return 100.0 if resources.empty?

        total_coverages = 0
        resources.each do |_, resource|
            total_coverages += resource.hit_percentage
        end

        total_coverages / resources.size
    end

    def hash
        [resources, scope].hash
    end

    def ==( other )
        hash == other.hash
    end

end

end
end
end
