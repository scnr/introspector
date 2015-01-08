require 'coverage'
require 'arachni/introspector/coverage/point'
require 'arachni/introspector/coverage/scope'

module Arachni
module Introspector

class Coverage

    class Error < Introspector::Error
        class InvalidScope < Error
        end
    end

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
    # @raise    [Error::InvalidScope]
    #   On unsupported `:scope` option.
    def initialize( options = {}, &block )
        options = options.dup

        if (scope = options.delete(:scope)).is_a? Scope
            @scope = scope
        elsif scope.is_a? Hash
            @scope = Scope.new( scope )
        elsif scope.nil?
            @scope = Scope.new
        else
            fail Error::InvalidScope
        end

        @points = []

        trace( &block ) if block_given?
    end

    # Traces code execution events as {Point points} and populates {#points}.
    #
    # @param    [Block] block
    #   Code to trace.
    #
    # @return   [Coverage]
    #   `self`
    def trace( &block )
        TracePoint.new do |tp|
            next if @scope.out?( tp )

            @points << create_point_from_trace_point( tp )
        end.enable(&block)

        self
    end

    def marshal_dump
        instance_variables.inject( {} ) do |h, iv|
            next h if iv == :@scope
            h[iv.to_s.gsub('@','')] = instance_variable_get( iv )
            h
        end
    end

    def marshal_load( h )
        h.each { |k, v| instance_variable_set( "@#{k}", v ) }
        points.each { |point| point.coverage = self }
        self
    end

    private

    def create_point_from_trace_point( tp )
        options = {
            coverage: self
        }

        if scope.without_context?
            options[:context] = nil
        end

        Point.from_trace_point( tp, options )
    end

end

end
end
