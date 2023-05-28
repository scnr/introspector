require 'singleton'

module SCNR
class Introspector

class Configuration
    include Singleton

    DEFAULT_FILENAME = 'scnr_introspector.config'
    DEFAULT_LOCATION = "#{Dir.pwd}/#{DEFAULT_FILENAME}"

    # @return   [Hash]
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
        Kernel.load( path )
        self
    end

end

end
end
