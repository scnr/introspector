#     [1] [+0] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:13 MyApp#GET / call in MyApp#HEAD /
#         get '/' do
#
#     "LOCAL VARIABLES"
#     "--------------------------------------------------------------------------------"
#     {
#         "local_variable" => "1"
#     }
#     "INSTANCE VARIABLES"
#     "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#     {
#              "@default_layout" => "layout",
#         "@preferred_extension" => "",
#                         "@app" => "",
#              "@template_cache" => "#<Tilt::Cache:0x00000002896910>",
#                         "@env" => {
#                        "REQUEST_METHOD" => "GET",
#                           "SCRIPT_NAME" => "",
#                             "PATH_INFO" => "/",
#                          "REQUEST_PATH" => "/",
#                          "QUERY_STRING" => "v=stuff%3Csome_dangerous_input_0a309824e84a7f61835ecd241e135cf9/%3E",
#                           "SERVER_NAME" => "localhost",
#                           "SERVER_PORT" => "80",
#                          "HTTP_VERSION" => "HTTP/1.1",
#                           "REMOTE_ADDR" => "localhost",
#                           "HTTP_ACCEPT" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
#                       "HTTP_USER_AGENT" => "Arachni/v2.0dev",
#                       "SERVER_PROTOCOL" => "HTTP/1.1",
#                          "rack.version" => "[1, 3]",
#                            "rack.input" => "#<StringIO:0x00000004579be0>",
#                           "rack.errors" => "#<IO:0x00000001871c10>",
#                      "rack.multithread" => "false",
#                     "rack.multiprocess" => "false",
#                         "rack.run_once" => "false",
#                       "rack.url_scheme" => "http",
#                          "rack.hijack?" => "false",
#                           "rack.logger" => "#<Rack::NullLogger:0x00000004de7a98>",
#             "rack.request.query_string" => "v=stuff%3Csome_dangerous_input_0a309824e84a7f61835ecd241e135cf9/%3E",
#               "rack.request.query_hash" => {
#                 "v" => "stuff<some_dangerous_input_0a309824e84a7f61835ecd241e135cf9/>"
#             },
#                         "sinatra.route" => "GET /"
#         },
#                     "@request" => "#<Sinatra::Request:0x00000004578380>",
#                    "@response" => "#<Sinatra::Response:0x00000004578358>",
#                      "@params" => {
#             "v" => "stuff<some_dangerous_input_0a309824e84a7f61835ecd241e135cf9/>"
#         },
#           "@instance_variable" => {
#             "blah" => "foo"
#         }
#     }
#     [2] [+0.000293043] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:13 MyApp#HEAD / b_call in MyApp#HEAD /
#         get '/' do
#
#     [3] [+0.000176832] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:14 MyApp#HEAD / line in MyApp#HEAD /
#             @instance_variable = {
#
#     [4] [+0.000186541] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:17 MyApp#HEAD / line in MyApp#HEAD /
#             local_variable = 1
#
#     [5] [+0.000175247] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:19 MyApp#HEAD / line in MyApp#HEAD /
#             <<EOHTML
#
#     [6] [+0.000182992] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:8 MyApp#process_params call in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#         def process_params( params )
#
#     "LOCAL VARIABLES"
#     "--------------------------------------------------------------------------------"
#     {
#         "params" => {
#             "v" => "stuff<some_dangerous_input_0a309824e84a7f61835ecd241e135cf9/>"
#         }
#     }
#     [7] [+0.000180429] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:9 MyApp#process_params line in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#             noop
#
#     [8] [+0.000206118] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:5 MyApp#noop call in MyApp#noop@/home/zapotek/workspace/arachni-introspector/examples/app.rb:5
#         def noop
#
#     "LOCAL VARIABLES"
#     "--------------------------------------------------------------------------------"
#     {}
#     [9] [+0.000177894] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:6 MyApp#noop return in MyApp#noop@/home/zapotek/workspace/arachni-introspector/examples/app.rb:5
#         end
#
#     [10] [+0.000202177] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 MyApp#process_params line in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#             params.values.join( ' ' )
#
#     "LOCAL VARIABLES"
#     "--------------------------------------------------------------------------------"
#     {
#         "params" => {
#             "v" => "stuff<some_dangerous_input_0a309824e84a7f61835ecd241e135cf9/>"
#         }
#     }
#     [11] [+0.000184974] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 Hash#values c_call in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#             params.values.join( ' ' )
#
#     [12] [+0.000174446] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 Hash#values c_return in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#             params.values.join( ' ' )
#
#     [13] [+0.000177579] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 Array#join c_call in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#             params.values.join( ' ' )
#
#     [14] [+0.000183137] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:10 Array#join c_return in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#             params.values.join( ' ' )
#
#     [15] [+0.000188445] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:11 MyApp#process_params return in MyApp#process_params@/home/zapotek/workspace/arachni-introspector/examples/app.rb:8
#         end
#
#     [16] [+0.000204568] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/arachni-introspector/examples/app.rb:23 MyApp#HEAD / b_return in MyApp#HEAD /
#         end
#
#     "LOCAL VARIABLES"
#     "--------------------------------------------------------------------------------"
#     {
#         "local_variable" => "1"
#     }
#
# @param    [Arachni::HTTP::Request::Coverage]   coverage
def print_request_coverage( coverage )
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
