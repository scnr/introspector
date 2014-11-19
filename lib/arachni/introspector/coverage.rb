require 'coverage'
require 'arachni/introspector/coverage/point'

module Arachni
module Introspector

class Coverage

    attr_accessor :scope

    # @return   [Array<Point>]
    attr_accessor :points

    def initialize( options = {}, &block )
        options.each do |k, v|
            send( "#{k}=", v )
        end

        @points ||= []
        @scope  ||= {}

        trace( &block ) if block_given?
    end

    def trace( &block )
        TracePoint.new do |tp|
            next if !log_point?( tp )

            @points << create_point_from_trace_point( tp )
        end.enable(&block)
    end

    def marshal_dump
        scope = @scope.dup
        @scope.delete :filter

        instance_variables.inject( {} ) do |h, iv|
            h[iv.to_s.gsub('@','')] = instance_variable_get( iv )
            h
        end
    ensure
        @scope = scope
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

    def log_point?( point )
        if @scope[:path_start_with]
            return point.path.to_s.start_with?( @scope[:path_start_with] )
        end

        if @scope[:path_end_with]
            return point.path.to_s.end_with?( @scope[:path_end_with] )
        end

        if @scope[:path_include_patterns]
            @scope[:path_include_patterns].each do |pattern|
                return true if point.path =~ pattern
            end

            return false
        end

        if @scope[:path_exclude_patterns]
            @scope[:path_exclude_patterns].each do |pattern|
                return false if point.path =~ pattern
            end
        end

        return @scope[:filter].call( point ) if @scope[:filter]

        true
    end

end

end
end
