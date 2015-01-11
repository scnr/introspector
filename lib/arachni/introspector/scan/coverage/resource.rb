require 'arachni/introspector/scan/coverage/resource/line'

module Arachni
module Introspector
class Scan
class Coverage

class Resource

    # @return   [String]
    attr_reader   :path

    # @return   [Array<Line>]
    attr_accessor :lines

    # @param    [String]    path
    #   Path to the resource.
    def initialize( path )
        @path  = path
        @lines = []

        IO.binread( path ).lines.each.with_index do |line, number|
            @lines << Line.new(
                number:   number,
                content:  line.rstrip,
                resource: self
            )
        end
    end

    # @param    [Integer]   line_number
    #   Number of the line to return (0-indexed).
    #
    # @return   [Line]
    def []( line_number )
        @lines[line_number]
    end

    # @return   [Array<Line>]
    #   {Line#hit? Hit} lines.
    def hit_lines
        lines.select(&:hit?)
    end

    # @return   [Array<Line>]
    #   {Line#missed? Missed} lines.
    def missed_lines
        lines.select(&:missed?)
    end

    # @return   [Array<Line>]
    #   {Line#skipped? Skipped} lines.
    def skipped_lines
        lines.select(&:skipped?)
    end

    # @return   [Array<Line>]
    #   Lines which should be considered in coverage (i.e. all lines except for
    #   {#skipped_lines}).
    def included_lines
        lines - skipped_lines
    end

    # @return   [Float]
    #   Percentage of {#hit_line}s.
    def hit_percentage
        return 100.0 if empty?

        lines_to_include = Float(lines.size - skipped_lines.size)
        return 100.0 if lines_to_include == 0

        (hit_lines.size / lines_to_include) * 100.0
    end

    # @return   [Float]
    #   Percentage of {#missed_line}s.
    def miss_percentage
        100.0 - hit_percentage
    end

    # @return   [Bool]
    #   `true` if {#lines} are empty, `false` otherwise.
    def empty?
        lines.empty?
    end

end

end
end
end
end
