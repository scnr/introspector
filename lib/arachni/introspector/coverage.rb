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
        Point.from_trace_point( tp, coverage: self )
    end

end

end
end
