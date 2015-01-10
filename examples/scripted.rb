APP_PATH = "#{File.expand_path( File.dirname(__FILE__) )}/app.rb"

require_relative 'helpers/print_request_coverage'
require_relative 'helpers/print_scan_coverage'

# The Introspector **has** to be loaded before the web application environment.
require 'arachni/introspector'

# Include the web application and its environment.
require APP_PATH

include Arachni

# Include the Arachni::UI::CLI's Arachni::UI::Output interface to show how the
# Introspector's behavior fits in with the usual Framework scan process.
#
# This is also **very** helpful during development and debugging.
Introspector.enable_output

# In case you're the curious type:
# UI::Output.debug( 3 )

scan_options = {

    coverage: {

        # Scan coverage provides simple, high-level coverage data, only includes
        # file paths and how much of their source got covered.
        #
        # It does not include any context and thus doesn't really affect performance.
        # (Well, maybe just a tiny bit.)
        scan:   {
            scope: {

                # Only keep track of webapp code.
                #
                # This will exclude library calls and will keep the instrumentation
                # and coverage entries short and sweet and to the point.
                path_start_with: APP_PATH
            }
        },

        # Coverage of HTTP::Request operations can provide a much more in-depth
        # look into the web application's behavior; this is very useful when
        # resolving logged issues.
        #
        # However, it is a bad idea to enable it during the scan, as it can result
        # in a x10 performance decrease (this is a demo so we're alright :)).
        #
        # To disable request coverage, simply avoid setting the `:request` key
        # for this configuration Hash.
        #
        # In general. this option should only be enabled when rechecking issues,
        # so as to fetch the necessary context as required.
        #
        # Although, if you do need to track overall scan coverage in depth, you
        # can configure the scope here and then monitor HTTP::Client traffic to
        # retrieve it for each request (an example will follow).
        request: {
            scope: {

                # Only keep track of webapp code.
                #
                # This will exclude library calls and will keep the instrumentation
                # and coverage entries short and sweet and to the point.
                #
                # Not to mention the huge effect it'll have on performance.
                path_start_with: APP_PATH
            }
        }
    },

    # Framework (scanner) options.
    # (see http://www.rubydoc.info/github/Arachni/arachni/Arachni/Options#update-instance_method)
    framework: {

        audit: {
            # We only care about links in our example.
            elements: [:links]
        },

        # The simple XSS check will do.
        checks: ['xss'],

        browser_cluster: {
            # Don't initialize any browsers, they're not needed for this example.
            # Wouldn't make any difference during the scan, but makes boot-up faster.
            pool_size: 0
        }
    }
}

issue_recheck_options = {
    coverage: {
        request: {
            scope: {
                path_start_with: APP_PATH
            },

            # This is where the real magic is, this will let you traverse up the
            # entire stack at the time the issue was discovered.
            #
            # You can access the, at the time, local and instance variables,
            # evaluate code, get the location of the vulnerable method and lots
            # more.
            #
            # An absolute joy for identifying and debugging issues.
            with_context: true
        }
    }
}

# You can hook into the HTTP::Client interface to monitor all responses and
# keep track of the coverage of their requests, given that request coverage has
# been enabled.
#
# Or, you may just want to keep a close eye on the scan from an HTTP perspective,
# which you can do, as each HTTP::Request includes a sort of breadcrumb to the
# entities which had a hand it.

# HTTP::Client.on_complete do |response|
#     request = response.request
#
#     # The performer can be any entity, although is usually is either the
#     # Framework, or a Browser or an Element being submitted.
#     puts "Performer: #{request.performer.inspect}"
#
#     # If this is an audit request its performer will have an auditor.
#     #
#     # In this example, at some point, the vulnerable Link element (the performer)
#     # will be audited by the XSS check (the auditor).
#     if request.performer.respond_to? :auditor
#         auditor = request.performer.auditor
#
#         puts "Auditor:   #{auditor.class.fullname}"
#         puts "Found in:  #{auditor.page.inspect}"
#     end
#
#     # Print the effect our request had on the web application.
#     print_request_coverage request.coverage
# end

# Simple scan using one of the Introspector helper methods.
# Runs a scan and give us the usual Arachni::Report, easy peasy.
report = Introspector.scan_and_report( MyApp, scan_options )

puts

# Let's see how much of the web application's source code the scan hit.
print_scan_coverage report.coverage

# Shut the system up again, it'll be quite annoying when fetching context data
# by rechecking issues.
Introspector.disable_output

report.issues.each do |issue|
    puts
    puts '-' * 100
    puts "Fetching context data for: #{issue.name} in '#{issue.vector.type}' " <<
             "input '#{issue.affected_input_name}':"

    # Now that we've got some issues let's recheck them with full coverage in
    # order to get the juicy runtime context.
    issue = Introspector.recheck_issue(
        MyApp, issue.variations.first, issue_recheck_options
    )

    puts
    print_request_coverage issue.variations.first.request.coverage
end

# And this is what you'll see:
#
# 100.0% coverage
# ----------------------------------------------------------------------------------------------------
# -- /home/zapotek/workspace/arachni-introspector/examples/app.rb
# ---- Total:    25
# ---- Skipped:  15
# ---- Hit:      10 (100.0%)
# ---- Missed:   0 (0.0%)
#
#  1 | + | require 'sinatra/base'
#  2 |   |
#  3 | + | class MyApp < Sinatra::Base
#  4 |   |
#  5 | + |     def noop
#  6 |   |     end
#  7 |   |
#  8 | + |     def process_params( params )
#  9 | + |         noop
# 10 | + |         params.values.join( ' ' )
# 11 |   |     end
# 12 |   |
# 13 | + |     get '/' do
# 14 | + |         @instance_variable = {
# 15 |   |             blah: 'foo'
# 16 |   |         }
# 17 | + |         local_variable = 1
# 18 |   |
# 19 | + |         <<EOHTML
# 20 |   | #{process_params( params )}
# 21 |   |         <a href="?v=stuff">XSS</a>
# 22 |   | EOHTML
# 23 |   |     end
# 24 |   |
# 25 |   | end
#
# ----------------------------------------------------------------------------------------------------
# Fetching context data for: Cross-Site Scripting (XSS) in 'link' input 'v':
#
# [1] [+0] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:13 MyApp#GET / call in MyApp#HEAD /
#     get '/' do
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "local_variable" => "1"
# }
# "INSTANCE VARIABLES"
# "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# {
#          "@default_layout" => "layout",
#     "@preferred_extension" => "",
#                     "@app" => "",
#          "@template_cache" => "#<Tilt::Cache:0x00000002c40d18>",
#                     "@env" => {
#                    "REQUEST_METHOD" => "GET",
#                       "SCRIPT_NAME" => "",
#                         "PATH_INFO" => "/",
#                      "REQUEST_PATH" => "/",
#                      "QUERY_STRING" => "v=stuff%3Csome_dangerous_input_39a1723e5d93bf73e212d57281539bb5/%3E",
#                       "SERVER_NAME" => "localhost",
#                       "SERVER_PORT" => "80",
#                      "HTTP_VERSION" => "HTTP/1.1",
#                       "REMOTE_ADDR" => "localhost",
#                       "HTTP_ACCEPT" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
#                   "HTTP_USER_AGENT" => "Arachni/v2.0dev",
#                   "SERVER_PROTOCOL" => "HTTP/1.1",
#                      "rack.version" => "[1, 3]",
#                        "rack.input" => "#<StringIO:0x000000049edac8>",
#                       "rack.errors" => "#<IO:0x00000001bd1bf8>",
#                  "rack.multithread" => "false",
#                 "rack.multiprocess" => "false",
#                     "rack.run_once" => "false",
#                   "rack.url_scheme" => "http",
#                      "rack.hijack?" => "false",
#                       "rack.logger" => "#<Rack::NullLogger:0x00000004baa988>",
#         "rack.request.query_string" => "v=stuff%3Csome_dangerous_input_39a1723e5d93bf73e212d57281539bb5/%3E",
#           "rack.request.query_hash" => {
#             "v" => "stuff<some_dangerous_input_39a1723e5d93bf73e212d57281539bb5/>"
#         },
#                     "sinatra.route" => "GET /"
#     },
#                 "@request" => "#<Sinatra::Request:0x000000049ed2a8>",
#                "@response" => "#<Sinatra::Response:0x000000049ed280>",
#                  "@params" => {
#         "v" => "stuff<some_dangerous_input_39a1723e5d93bf73e212d57281539bb5/>"
#     },
#       "@instance_variable" => {
#         "blah" => "foo"
#     }
# }
# [2] [+0.000361505] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:13 MyApp#HEAD / b_call in MyApp#HEAD /
#     get '/' do
#
# [3] [+0.000231479] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:14 MyApp#HEAD / line in MyApp#HEAD /
#         @instance_variable = {
#
# [4] [+0.000201383] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:17 MyApp#HEAD / line in MyApp#HEAD /
#         local_variable = 1
#
# [5] [+0.000155073] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:19 MyApp#HEAD / line in MyApp#HEAD /
#         <<EOHTML
#
# [6] [+0.000182906] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:8 MyApp#process_params call in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#     def process_params( params )
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "params" => {
#         "v" => "stuff<some_dangerous_input_39a1723e5d93bf73e212d57281539bb5/>"
#     }
# }
# [7] [+0.000182013] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:9 MyApp#process_params line in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#         noop
#
# [8] [+0.000208563] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:5 MyApp#noop call in MyApp#noop@/home/zapotek/workspace/arachni-introspector/examples/app.rb:5
#     def noop
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {}
# [9] [+0.000212117] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:6 MyApp#noop return in MyApp#noop@/home/zapotek/workspace/arachni-introspector/examples/app.rb:5
#     end
#
# [10] [+0.000202927] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 MyApp#process_params line in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "params" => {
#         "v" => "stuff<some_dangerous_input_39a1723e5d93bf73e212d57281539bb5/>"
#     }
# }
# [11] [+0.00018936] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 Hash#values c_call in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# [12] [+0.000177726] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 Hash#values c_return in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# [13] [+0.000190877] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 Array#join c_call in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# [14] [+0.00018111] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 Array#join c_return in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# [15] [+0.000188217] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:11 MyApp#process_params return in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#     end
#
# [16] [+0.00018215] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:23 MyApp#HEAD / b_return in MyApp#HEAD /
#     end
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "local_variable" => "1"
# }
