require 'singleton'

module Arachni
module Introspector

class Configuration
    include Singleton

    DEFAULT_FILENAME = 'arachni_introspector.config'
    DEFAULT_LOCATION = "#{File.dirname( ARGV[0] )}/#{DEFAULT_FILENAME}"

    # @return   [Hash]
    #   {Scan} options, along with `:application`, holding the Rack application
    #   class.
    #
    #   Not used anywhere implicitly, just a way to store configuration options
    #   to be shared between config files and user interfaces.
    attr_accessor :options

    class <<self
        def method_missing( sym, *args, &block )
            if instance.respond_to?( sym )
                instance.send( sym, *args, &block )
            else
                super( sym, *args, &block )
            end
        end

        def respond_to?( *args )
            super || instance.respond_to?( *args )
        end

        # Ruby 2.0 doesn't like my class-level method_missing for some reason.
        # @private
        public :allocate
    end

    def initialize
    end

    def from_file( path = DEFAULT_LOCATION )
        Kernel.load path
    end

end

end
end
