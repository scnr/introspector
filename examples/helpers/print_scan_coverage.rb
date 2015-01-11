#     100.0% coverage
#     ----------------------------------------------------------------------------------------------------
#     -- /home/zapotek/workspace/arachni-introspector/examples/app.rb
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
# @param    [Arachni::Introspector::Scan::Coverage]   coverage
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
            elsif line.state == :miss
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
