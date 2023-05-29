require 'scnr/introspector/data_flow/scope'
require 'scnr/introspector/data_flow/sink'

module SCNR
class Introspector

class DataFlow

  # @return   [Scope]
  attr_accessor :scope

  # @return   [Array<Point>]
  attr_reader   :sinks

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

    if (scope = options.delete(:scope)).is_a? DataFlow::Scope
      @scope = scope
    elsif scope.is_a? Hash
      @scope = DataFlow::Scope.new( scope )
    elsif scope.nil?
      @scope = DataFlow::Scope.new
    else
      fail DataFlow::Scope::Error::Invalid
    end

    @sinks = []
  end

  def to_rpc_data
    data = {}
    instance_variables.each do |iv|
      case iv
      when :@sinks
        data['sinks'] = @sinks.map(&:to_rpc_data)

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
      when 'sinks'
        n.instance_variable_set( "@#{k}", v.map { |pd| Sink.from_rpc_data( pd ) } )

      else
        n.instance_variable_set( "@#{k}", v )
      end
    end

    n
  end

end

end
end
