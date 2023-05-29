require 'scnr/introspector/execution_flow/scope'
require 'scnr/introspector/execution_flow/point'

module SCNR
class Introspector

class ExecutionFlow

    # @return   [Scope]
    attr_accessor :scope

    # @return   [Array<Point>]
    attr_reader   :points

    # @param    [Hash]  options
    # @option   options     [Scope,Hash,nil]    :scope
    #   * {Scope}:  Configured {Scope} to use.
    #   * `Hash`:  `Hash` to use for {Scope#initialize}.
    #   * `nil`:  Will default to an empty {Scope}.
    # @param    [Block] block
    #   Code to {#trace}.
    #
    # @raise    [Introspector::Scope::Error::Invalid]
    #   On unsupported `:scope` option.
    def initialize( options = {}, &block )
        options = options.dup

        if (scope = options.delete(:scope)).is_a? ExecutionFlow::Scope
            @scope = scope
        elsif scope.is_a? Hash
            @scope = ExecutionFlow::Scope.new( scope )
        elsif scope.nil?
            @scope = ExecutionFlow::Scope.new
        else
            fail ExecutionFlow::Scope::Error::Invalid
        end

        @points = []

        trace( &block ) if block_given?
    end

    # Traces code execution events as {Point points} and populates {#points}.
    #
    # @param    [Block] block
    #   Code to trace.
    #
    # @return   [ExecutionFlow]
    #   `self`
    def trace( &block )
        TracePoint.new do |tp|
            next if @scope.out?( tp.path )

            @points << create_point_from_trace_point( tp )
        end.enable(&block)

        self
    end

    def to_rpc_data
        data = {}
        instance_variables.each do |iv|
            case iv
                when :@points
                    data['points'] = @points.map(&:to_rpc_data)

                when :@scope
                    next

            else
                v = instance_variable_get( iv )
                next if !v
                data[iv.to_s.gsub('@','')] = v.to_rpc_data

            end
        end
        data
    end

    def self.from_rpc_data( h )
        n = self.new

        h.each do |k, v|
            case k
                when 'points'
                    n.instance_variable_set( "@#{k}", v.map { |pd| Point.from_rpc_data( pd ) } )

                else
                    n.instance_variable_set( "@#{k}", v )
            end
        end

        n
    end

    private

    def create_point_from_trace_point( tp )
        Point.from_trace_point( tp  )
    end

end

end
end
