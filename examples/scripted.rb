require 'arachni/introspector'
require 'sinatra/base'

include Arachni

# Include the Arachni::UI::CLI's Arachni::UI::Output interface to show how the
# Introspector's behavior fits in with the usual Framework scan process.
Introspector.enable_output

# Utility method to print out coverage data.
#
# @param    [Arachni::Introspector::Coverage]   coverage
def print_coverage( coverage )
    return if !coverage

    last_timestamp          = nil
    last_instance_variables = nil
    last_local_variables    = nil

    coverage.points.each.with_index do |point, i|
        time_diff = last_timestamp ? point.timestamp - last_timestamp : 0

        puts "[#{i + 1}] [+#{time_diff}] #{point.inspect}"
        if File.exist? point.path
            puts "#{IO.read( point.path ).lines[point.line_number-1]}"
        end
        puts

        if frame = point.stack_frame
            local_variables    = frame.local_variables
            instance_variables = frame.instance_variables

            if local_variables != last_local_variables
                ap 'LOCAL VARIABLES'
                ap '-' * 80
                ap local_variables.my_stringify
            end

            if instance_variables != last_instance_variables
                ap 'INSTANCE VARIABLES'
                ap '~' * 80
                ap instance_variables.my_stringify
            end

            last_local_variables    = frame.local_variables
            last_instance_variables = frame.instance_variables
        end

        last_timestamp = point.timestamp
    end

end

# Sample Sinatra application, vulnerable to XSS.
class MyApp < Sinatra::Base

    def noop
    end

    def process_params( params )
        noop
        params.values.join( ' ' )
    end

    get '/' do
        @instance_variable = {
            blah: 'foo'
        }
        local_variable = 1

        <<EOHTML
#{process_params( params )}
        <a href="?v=stuff">XSS</a>
EOHTML
    end

end

scan_options = {

    # Better disable coverage tracking during the scan to enjoy some really
    # spectacular (> x10) performance, you can do that by not including the
    # :coverage option.
    # It's better to only enable coverage when rechecking issues.
    #
    # However, if you do need to track overall scan coverage you can configure
    # the scope here and then monitor HTTP::Client traffic to retrieve it for
    # each request, as you'll see bellow.
    coverage: {

        scope: {

            # Only keep track of code in files that start with __FILE__.
            #
            # This will exclude library calls and will keep the instrumentation
            # and coverage entries short and sweet and to the point.
            # Not to mention the huge effect it'll have on performance.
            path_start_with: __FILE__
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
            #
            # Wouldn't make any difference during the scan, but makes boot-up faster.
            pool_size: 0
        }
    }
}

# Go full coverage when rechecking issues, context and everything.
issue_recheck_options = {
    coverage: {
        scope: {
            path_start_with: __FILE__,
            with_context:    true
        }
    }
}

# You can hook into the HTTP::Client interface to monitor all responses and
# keep track of the coverage of their requests.
HTTP::Client.on_complete do |response|
    request = response.request

    puts request.inspect
    # <Arachni::HTTP::Request @id=2 @mode=async @method=get @url="http://myapp/"
    #   @parameters={"v"=>"stuff<some_dangerous_input_511ae323ed73c1a2348be673dc8360ef/>"}
    #   @high_priority= @performer=#<Arachni::Element::Link (get)
    #   auditor=Arachni::Checks::Xss url="http://myapp/" action="http://myapp/"
    #   default-inputs={"v"=>"stuff"} inputs={"v"=>"stuff<some_dangerous_input_511ae323ed73c1a2348be673dc8360ef/>"}
    #   seed="<some_dangerous_input_511ae323ed73c1a2348be673dc8360ef/>"
    #   affected-input-name="v" affected-input-value="stuff<some_dangerous_input_511ae323ed73c1a2348be673dc8360ef/>">>

    print_coverage request.coverage
end

# Simple scan using one of the Introspector helper methods.
# Runs a scan and give us the usual Arachni::Report, easy peasy.
Introspector.scan_and_report( MyApp, scan_options ).issues.each do |issue|

    # Now that we've got some issues let's recheck them with full coverage in
    # order to get the juicy runtime context.
    issue = Introspector.recheck_issue( MyApp, issue.variations.first, issue_recheck_options )

    puts "#{issue.name} in '#{issue.vector.type}' input '#{issue.affected_input_name}':"
    puts
    print_coverage issue.variations.first.request.coverage
end

# And this is what you'll see:
#
# Cross-Site Scripting (XSS) in 'link' input 'v':
#
# [1] [+0] [2015-01-08 04:51:41 +0200] examples/scripted.rb:62 MyApp#GET / call in MyApp#HEAD /
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
#          "@template_cache" => "#<Tilt::Cache:0x00000004873fa8>",
#                     "@env" => {
#                    "REQUEST_METHOD" => "GET",
#                       "SCRIPT_NAME" => "",
#                         "PATH_INFO" => "/",
#                      "REQUEST_PATH" => "/",
#                      "QUERY_STRING" => "v=stuff%3Csome_dangerous_input_5fe1ec85912f023a56d18122d1e3f754/%3E",
#                       "SERVER_NAME" => "localhost",
#                       "SERVER_PORT" => "80",
#                      "HTTP_VERSION" => "HTTP/1.1",
#                       "REMOTE_ADDR" => "localhost",
#                       "HTTP_ACCEPT" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
#                   "HTTP_USER_AGENT" => "Arachni/v2.0dev",
#                   "SERVER_PROTOCOL" => "HTTP/1.1",
#                      "rack.version" => "[1, 3]",
#                        "rack.input" => "#<StringIO:0x00000005497b90>",
#                       "rack.errors" => "#<IO:0x00000001bf1c00>",
#                  "rack.multithread" => "false",
#                 "rack.multiprocess" => "false",
#                     "rack.run_once" => "false",
#                   "rack.url_scheme" => "http",
#                      "rack.hijack?" => "false",
#                       "rack.logger" => "#<Rack::NullLogger:0x000000047e8fe8>",
#         "rack.request.query_string" => "v=stuff%3Csome_dangerous_input_5fe1ec85912f023a56d18122d1e3f754/%3E",
#           "rack.request.query_hash" => {
#             "v" => "stuff<some_dangerous_input_5fe1ec85912f023a56d18122d1e3f754/>"
#         },
#                     "sinatra.route" => "GET /"
#     },
#                 "@request" => "#<Sinatra::Request:0x00000005496ee8>",
#                "@response" => "#<Sinatra::Response:0x00000005496ec0>",
#                  "@params" => {
#         "v" => "stuff<some_dangerous_input_5fe1ec85912f023a56d18122d1e3f754/>"
#     },
#       "@instance_variable" => {
#         "blah" => "foo"
#     }
# }
# [2] [+0.000310807] [2015-01-08 04:51:41 +0200] examples/scripted.rb:62 MyApp#HEAD / b_call in MyApp#HEAD /
#     get '/' do
#
# [3] [+0.000210631] [2015-01-08 04:51:41 +0200] examples/scripted.rb:63 MyApp#HEAD / line in MyApp#HEAD /
#         @instance_variable = {
#
# [4] [+0.000222088] [2015-01-08 04:51:41 +0200] examples/scripted.rb:66 MyApp#HEAD / line in MyApp#HEAD /
#         local_variable = 1
#
# [5] [+0.000205597] [2015-01-08 04:51:41 +0200] examples/scripted.rb:68 MyApp#HEAD / line in MyApp#HEAD /
#         <<EOHTML
#
# [6] [+0.000204948] [2015-01-08 04:51:41 +0200] examples/scripted.rb:57 MyApp#process_params call in MyApp#process_params@examples/scripted.rb:57
#     def process_params( params )
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "params" => {
#         "v" => "stuff<some_dangerous_input_5fe1ec85912f023a56d18122d1e3f754/>"
#     }
# }
# [7] [+0.000209384] [2015-01-08 04:51:41 +0200] examples/scripted.rb:58 MyApp#process_params line in MyApp#process_params@examples/scripted.rb:57
#         noop
#
# [8] [+0.000217401] [2015-01-08 04:51:41 +0200] examples/scripted.rb:54 MyApp#noop call in MyApp#noop@examples/scripted.rb:54
#     def noop
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {}
# [9] [+0.000217095] [2015-01-08 04:51:41 +0200] examples/scripted.rb:55 MyApp#noop return in MyApp#noop@examples/scripted.rb:54
#     end
#
# [10] [+0.000236368] [2015-01-08 04:51:41 +0200] examples/scripted.rb:59 MyApp#process_params line in MyApp#process_params@examples/scripted.rb:57
#         params.values.join( ' ' )
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "params" => {
#         "v" => "stuff<some_dangerous_input_5fe1ec85912f023a56d18122d1e3f754/>"
#     }
# }
# [11] [+0.000205081] [2015-01-08 04:51:41 +0200] examples/scripted.rb:59 Hash#values c_call in MyApp#process_params@examples/scripted.rb:57
#         params.values.join( ' ' )
#
# [12] [+0.000199908] [2015-01-08 04:51:41 +0200] examples/scripted.rb:59 Hash#values c_return in MyApp#process_params@examples/scripted.rb:57
#         params.values.join( ' ' )
#
# [13] [+0.000218121] [2015-01-08 04:51:41 +0200] examples/scripted.rb:59 Array#join c_call in MyApp#process_params@examples/scripted.rb:57
#         params.values.join( ' ' )
#
# [14] [+0.000223225] [2015-01-08 04:51:41 +0200] examples/scripted.rb:59 Array#join c_return in MyApp#process_params@examples/scripted.rb:57
#         params.values.join( ' ' )
#
# [15] [+0.000208526] [2015-01-08 04:51:41 +0200] examples/scripted.rb:60 MyApp#process_params return in MyApp#process_params@examples/scripted.rb:57
#     end
#
# [16] [+0.000208595] [2015-01-08 04:51:41 +0200] examples/scripted.rb:72 MyApp#HEAD / b_return in MyApp#HEAD /
#     end
#
# "LOCAL VARIABLES"
# "--------------------------------------------------------------------------------"
# {
#     "local_variable" => "1"
# }
