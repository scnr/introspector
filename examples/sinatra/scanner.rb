require 'pry'
require 'scnr/introspector'
require 'scnr/introspector/helpers/output'

include SCNR
include Introspector::Helpers::Output

# Location of the web application environment loader.
APP_PATH = "#{File.expand_path( File.dirname(__FILE__) )}/app.rb"

# Introspection and scan options.
OPTIONS = {

  # Scan coverage provides simple, high-level coverage data, it includes
  # file paths and the source lines that were executed.
  coverage: {
    scope: {
      # Only keep track of webapp code.
      path_start_with: APP_PATH
    },
  },

  # Tracing HTTP::Request operations can provide a much more in-depth
  # look into the web application's behavior; this is very useful when
  # resolving logged issues.
  trace: {
    scope: {
      # Only keep track of webapp code.
      path_start_with: APP_PATH
    }
  },

  scan: {
    audit: {
      # We only care about links in our example.
      elements: [:links]
    },

    # The simple XSS check will do.
    checks: ['xss'],

    # We don't need any browsers for this particular scan.
    dom: {
      pool_size: 0
    }
  }
}

# Enable coverage tracking of the web application's source code.
Introspector::Scan::Coverage.enable

# Include the web application and its environment.
require APP_PATH

# Runs a scan and give us the usual SCNR::Report, easy peasy.
# Although, **this** report will include some really cool extra goodies.
report = Introspector.scan_and_report( OPTIONS )

# Let's see how much of the web application's source code the scan hit, file by
# file, line by line.
puts
print_scan_coverage report.coverage

# Shut the system up, it'll be quite annoying during tracing.
Introspector.disable_output

# Will be an XSS issue.
issue = report.issues.first

puts
puts '-' * 100
puts "Trace for: #{issue.name} in '#{issue.vector.type}' input '#{issue.affected_input_name}':"

# This is where the real magic happens, this will trace the issue through
# the web application's execution flow and provide you with an abundance of
# context.
# An absolute joy for identifying and debugging issues.
traced_issue = issue.with_trace( scope: { path_start_with: APP_PATH } )

puts
print_request_trace traced_issue.request.trace

# Re-enter the context the webapp was in during its vulnerable state with pry.
traced_issue.request.trace.points.last.context.pry

# And this is what you'll see:
#
# 100.0% coverage
# ----------------------------------------------------------------------------------------------------
# -- /home/zapotek/workspace/scnr-introspector/examples/app.rb
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
# [1] [+0] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:13 MyApp#GET / call in MyApp#HEAD /
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
#                   "HTTP_USER_AGENT" => "SCNR/v2.0dev",
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
# [2] [+0.000361505] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:13 MyApp#HEAD / b_call in MyApp#HEAD /
#     get '/' do
#
# [3] [+0.000231479] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:14 MyApp#HEAD / line in MyApp#HEAD /
#         @instance_variable = {
#
# [4] [+0.000201383] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:17 MyApp#HEAD / line in MyApp#HEAD /
#         local_variable = 1
#
# [5] [+0.000155073] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:19 MyApp#HEAD / line in MyApp#HEAD /
#         <<EOHTML
#
# [6] [+0.000182906] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:8 MyApp#process_params call in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
#     def process_params( params )
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "params" => {
#         "v" => "stuff<some_dangerous_input_39a1723e5d93bf73e212d57281539bb5/>"
#     }
# }
# [7] [+0.000182013] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:9 MyApp#process_params line in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
#         noop
#
# [8] [+0.000208563] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:5 MyApp#noop call in MyApp#noop@/home/zapotek/workspace/scnr-introspector/examples/app.rb:5
#     def noop
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {}
# [9] [+0.000212117] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:6 MyApp#noop return in MyApp#noop@/home/zapotek/workspace/scnr-introspector/examples/app.rb:5
#     end
#
# [10] [+0.000202927] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 MyApp#process_params line in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "params" => {
#         "v" => "stuff<some_dangerous_input_39a1723e5d93bf73e212d57281539bb5/>"
#     }
# }
# [11] [+0.00018936] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 Hash#values c_call in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# [12] [+0.000177726] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 Hash#values c_return in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# [13] [+0.000190877] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 Array#join c_call in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# [14] [+0.00018111] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 Array#join c_return in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
#         params.values.join( ' ' )
#
# [15] [+0.000188217] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:11 MyApp#process_params return in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
#     end
#
# [16] [+0.00018215] [2015-01-10 02:10:13 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:23 MyApp#HEAD / b_return in MyApp#HEAD /
#     end
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "local_variable" => "1"
# }
