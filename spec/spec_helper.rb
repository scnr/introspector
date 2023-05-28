require 'simplecov'
require 'faker'
require 'scnr/introspector'
require 'scnr/engine'

# Enable extra output options in order to get full coverage...
# SCNR::UI::CLI::Output.verbose_on
# SCNR::UI::CLI::Output.debug_on( 999999 )
# SCNR::UI::CLI::Output.mute

# Uncomment to show output from spawned processes.
SCNR::Engine::Processes::Manager.preserve_output

RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true

    config.alias_example_to :expect_it

    # These two settings work together to allow you to limit a spec run
    # to individual examples or groups you care about by tagging them with
    # `:focus` metadata. When nothing is tagged with `:focus`, all examples
    # get run.
    config.filter_run :focus
    config.run_all_when_everything_filtered = true

    # Print the 10 slowest examples and example groups at the
    # end of the spec run, to help surface which specs are running
    # particularly slow.
    config.profile_examples = 10

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    # config.order            = :random

    # Seed global randomization in this process using the `--seed` CLI option.
    # Setting this allows you to use `--seed` to deterministically reproduce
    # test failures related to randomization by passing the same `--seed` value
    # as the one that triggered the failure.
    # Kernel.srand config.seed

    # rspec-expectations config goes here. You can use an alternate
    # assertion/expectation library such as wrong or the stdlib/minitest
    # assertions if you prefer.
    config.expect_with :rspec do |expectations|
        # Enable only the newer, non-monkey-patching expect syntax.
        # For more details, see:
        #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
        expectations.syntax = :expect
    end

    # rspec-mocks config goes here. You can use an alternate test double
    # library (such as bogus or mocha) by changing the `mock_with` option here.
    config.mock_with :rspec do |mocks|
        # Enable only the newer, non-monkey-patching expect syntax.
        # For more details, see:
        #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
        mocks.syntax                 = :expect

        # Prevents you from mocking or stubbing a method that does not exist on
        # a real object. This is generally recommended.
        # mocks.verify_partial_doubles = true
    end

    config.before( :all ) do
    end

    config.after( :suite ) do
    end
end

RSpec::Core::MemoizedHelpers.module_eval do
    alias to should
    alias to_not should_not
end

engine_root_dir = Gem::Specification.find_by_name( 'scnr-engine' ).gem_dir
support_path    = "#{engine_root_dir}/spec/support"

require "#{support_path}/lib/factory"
Dir.glob( "#{support_path}/{factories}/**/*.rb" ).each { |f| require f }

Dir.glob( "#{File.dirname( __FILE__ )}/support/{lib,helpers,shared,factories,webapps}/**/*.rb" ).each { |f| require f }
