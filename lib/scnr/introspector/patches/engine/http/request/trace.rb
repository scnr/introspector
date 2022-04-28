require 'coverage'
require 'scnr/introspector/patches/engine/http/request/trace/scope'
require 'scnr/introspector/patches/engine/http/request/trace/point'

module SCNR
module Engine
module HTTP
class Request

class Trace

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

        if (scope = options.delete(:scope)).is_a? Request::Trace::Scope
            @scope = scope
        elsif scope.is_a? Hash
            @scope = Request::Trace::Scope.new( scope )
        elsif scope.nil?
            @scope = Request::Trace::Scope.new
        else
            fail Request::Trace::Scope::Error::Invalid
        end

        @with_context = options[:with_context]
        @points       = []

        trace( &block ) if block_given?
    end

    def with_context?
        !!@with_context
    end

    # Traces code execution events as {Point points} and populates {#points}.
    #
    # @param    [Block] block
    #   Code to trace.
    #
    # @return   [Trace]
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
                    data[iv.to_s.gsub('@','')] = instance_variable_get( iv ).to_rpc_data_or_self

            end
        end
        data
    end

    def self.from_rpc_data( h )
        n = self.new

        h.each do |k, v|
            case k
                when 'points'
                    n.instance_variable_set( "@#{k}", v.map { |pd| Point.from_rpc_data( pd ).tap { |p| p.trace = n } } )

                else
                    n.instance_variable_set( "@#{k}", v )
            end
        end

        n
    end

    private

    def create_point_from_trace_point( tp )
        options = {
            trace: self
        }

        if !with_context?
            options[:context] = nil
        end

        Point.from_trace_point( tp, options )
    end

end

end
end
end
end
