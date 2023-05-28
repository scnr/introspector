require 'pp'

module SCNR
module Introspector
module Helpers
module Output

    #     [1] [+0] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:13 MyApp#GET / call in MyApp#HEAD /
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
    #                       "HTTP_USER_AGENT" => "SCNR/v2.0dev",
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
    #     [2] [+0.000293043] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:13 MyApp#HEAD / b_call in MyApp#HEAD /
    #         get '/' do
    #
    #     [3] [+0.000176832] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:14 MyApp#HEAD / line in MyApp#HEAD /
    #             @instance_variable = {
    #
    #     [4] [+0.000186541] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:17 MyApp#HEAD / line in MyApp#HEAD /
    #             local_variable = 1
    #
    #     [5] [+0.000175247] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:19 MyApp#HEAD / line in MyApp#HEAD /
    #             <<EOHTML
    #
    #     [6] [+0.000182992] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:8 MyApp#process_params call in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
    #         def process_params( params )
    #
    #     "LOCAL VARIABLES"
    #     "--------------------------------------------------------------------------------"
    #     {
    #         "params" => {
    #             "v" => "stuff<some_dangerous_input_0a309824e84a7f61835ecd241e135cf9/>"
    #         }
    #     }
    #     [7] [+0.000180429] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:9 MyApp#process_params line in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
    #             noop
    #
    #     [8] [+0.000206118] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:5 MyApp#noop call in MyApp#noop@/home/zapotek/workspace/scnr-introspector/examples/app.rb:5
    #         def noop
    #
    #     "LOCAL VARIABLES"
    #     "--------------------------------------------------------------------------------"
    #     {}
    #     [9] [+0.000177894] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:6 MyApp#noop return in MyApp#noop@/home/zapotek/workspace/scnr-introspector/examples/app.rb:5
    #         end
    #
    #     [10] [+0.000202177] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 MyApp#process_params line in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
    #             params.values.join( ' ' )
    #
    #     "LOCAL VARIABLES"
    #     "--------------------------------------------------------------------------------"
    #     {
    #         "params" => {
    #             "v" => "stuff<some_dangerous_input_0a309824e84a7f61835ecd241e135cf9/>"
    #         }
    #     }
    #     [11] [+0.000184974] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 Hash#values c_call in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
    #             params.values.join( ' ' )
    #
    #     [12] [+0.000174446] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 Hash#values c_return in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
    #             params.values.join( ' ' )
    #
    #     [13] [+0.000177579] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 Array#join c_call in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
    #             params.values.join( ' ' )
    #
    #     [14] [+0.000183137] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:10 Array#join c_return in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
    #             params.values.join( ' ' )
    #
    #     [15] [+0.000188445] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:11 MyApp#process_params return in MyApp#process_params@/home/zapotek/workspace/scnr-introspector/examples/app.rb:8
    #         end
    #
    #     [16] [+0.000204568] [2015-01-10 03:51:05 +0200] /home/zapotek/workspace/scnr-introspector/examples/app.rb:23 MyApp#HEAD / b_return in MyApp#HEAD /
    #         end
    #
    #     "LOCAL VARIABLES"
    #     "--------------------------------------------------------------------------------"
    #     {
    #         "local_variable" => "1"
    #     }
    #
    # @param    [SCNR::HTTP::Request::Trace]   trace
    def print_request_trace( trace )
        return if !trace

        last_instance_variables = nil

        trace.points.each.with_index do |point, i|
            puts "[#{i + 1}] #{point.inspect}"
            if File.exist? point.path
                puts "#{IO.read( point.path ).lines[point.line_number-1]}"
            end
            puts

            if (frame = point.stack_frame)
                local_variables    = frame.local_variables
                instance_variables = frame.instance_variables

                if local_variables.any?
                    puts "\tLOCAL VARIABLES"
                    puts "\t" + ('-' * 80)
                    pp local_variables.my_stringify
                    puts
                end

                if instance_variables != last_instance_variables
                    puts "\tINSTANCE VARIABLES"
                    puts "\t" + ('~' * 80)
                    pp instance_variables.my_stringify
                    puts
                end

                last_instance_variables = frame.instance_variables
            end

            last_timestamp = point.timestamp
        end
    end

    #     100.0% coverage
    #     ----------------------------------------------------------------------------------------------------
    #     -- /home/zapotek/workspace/scnr-introspector/examples/app.rb
    #     ---- Total:    25
    #     ---- Skipped:  15
    #     ---- Hit:      10 (100.0%)
    #     ---- Missed:   0 (0.0%)
    #
    #     Hit (+), missed (-) or skipped lines:
    #      1 | + | require 'sinatra/base'
    #      2 |   |
    #      3 | + | class MyApp < Sinatra::Base
    #      4 |   |
    #      5 | + |     def noop
    #      6 |   |     end
    #      7 |   |
    #      8 | + |     def process_params( params )
    #      9 | + |         noop
    #     10 | + |         params.values.join( ' ' )
    #     11 |   |     end
    #     12 |   |
    #     13 | + |     get '/' do
    #     14 | + |         @instance_variable = {
    #     15 |   |             blah: 'foo'
    #     16 |   |         }
    #     17 | + |         local_variable = 1
    #     18 |   |
    #     19 | + |         <<EOHTML
    #     20 |   | #{process_params( params )}
    #     21 |   |         <a href="?v=stuff">XSS</a>
    #     22 |   | EOHTML
    #     23 |   |     end
    #     24 |   |
    #     25 |   | end
    #
    # @param    [SCNR::Introspector::Scan::Coverage]   coverage
    def print_scan_coverage( coverage )
        return if !coverage

        puts "#{coverage.percentage}% coverage"
        puts '-' * 100

        coverage.resources.each do |path, resource|
            next if resource.empty?

            puts "-- #{path}"
            puts "---- Total:    #{resource.lines.size}"
            puts "---- Skipped:  #{resource.skipped_lines.size}"
            puts "---- Hit:      #{resource.hit_lines.size} " <<
                     "(#{resource.hit_percentage}%)"
            puts "---- Missed:   #{resource.missed_lines.size} " <<
                     "(#{resource.miss_percentage}%)"

            puts
            puts 'Hit (+), missed (-) or skipped lines:'

            max = (resource.lines.size + 1).to_s.size
            resource.lines.each do |line|
                legend = ' '
                if line.state == :hit
                    legend = '+'
                elsif line.state == :missed
                    legend = '-'
                end

                number = line.number + 1
                just   = ' ' * (max - number.to_s.size)
                puts "#{just}#{line.number+1} | #{legend} | #{line.content}"
            end

            puts
            puts '--------------------'
            puts
        end
    end

    extend self
end
end
end
end
