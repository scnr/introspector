module SCNR
module Introspector
class Scan
class Coverage
class Resource

class Line

    # @return   [Integer]
    #   Line number.
    attr_accessor :number

    # @return   [String]
    #   Line content.
    attr_accessor :content

    # @return   [Resource]
    #   Resource containing `self`.
    attr_accessor :resource

    # @return   [nil, Integer]
    #   Amount of times this line was executed:
    #
    #   * `nil` -- {#skipped? Skipped}, irrelevant code.
    #   * `0` -- {#missed? Missed}, line wasn't executed.
    #   *  `>= 1` -- {#hit? Hit}, line was executed.
    attr_accessor :hits

    # @param    [Hash]  options
    # @option   options [Resource]   :resource
    # @option   options [Integer]   :number
    # @option   options [String]   :content
    # @option   options [nil, Integer]   :his
    def initialize( options = {} )
        @resource = options[:resource]
        fail ArgumentError, 'Missing :resource' if !@resource

        @number = options[:number]
        fail ArgumentError, 'Missing :number' if !@number.is_a?( Integer )

        @content = options[:content]
        fail ArgumentError, 'Missing :content' if !@content

        @hits = options[:hits]
    end

    # @return   [Bool]
    #   `true` if the line is irrelevant to the coverage, `false` otherwise.
    def skipped?
        @hits.nil?
    end

    # @return   [Bool]
    #   `true` if the line wasn't executed, `false` otherwise.
    def missed?
        @hits == 0
    end

    # @return   [Bool]
    #   `true` if the line was executed, `false` otherwise.
    def hit?
        @hits.to_i > 0
    end

    # @return   [Symbol]
    #   * `:skipped` if {#skipped?}.
    #   * `:missed` if {#missed?}.
    #   * `:hit` if {#hit?}.
    def state
        [:skipped, :missed, :hit].each do |possible_state|
            return possible_state if send("#{possible_state}?")
        end
    end

    # @param    [Integer]   count
    #   Register `count` amount of hits.
    def hit( count )
        return if !count

        @hits ||= 0
        @hits += count
    end

end

end
end
end
end
end
