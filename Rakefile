require 'rspec'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec)

desc 'Generate docs.'
task :docs do

    outdir = "../scnr-introspector-docs"
    sh "rm -rf #{outdir}"
    sh "mkdir -p #{outdir}"

    sh "yardoc -o #{outdir}"

    sh "rm -rf .yardoc"
end

desc 'Remove reporter and log files.'
task :clean do
    files = %w(error.log *.crf *.csf *.yaml *.json *.marshal *.gem pkg/*.gem
        reports/*.crf snapshots/*.csf logs/*.log spec/support/logs/*.log
        spec/support/reports/*.crf spec/support/snapshots/*.csf
    ).map { |file| Dir.glob( file ) }.flatten

    next if files.empty?

    puts 'Removing:'
    files.each { |file| puts "  * #{file}" }
    FileUtils.rm files
end

desc 'Build the gem.'
task build: [ :clean ] do
    sh "gem build scnr-introspector.gemspec"
end

desc 'Build and install the gem.'
task install: [ :build ] do
    sh "gem install scnr-introspector-#{SCNR::Introspector::VERSION}.gem"
end

desc 'Push a new version to Rubygems'
task publish: [ :build ] do
    sh "git tag -a v#{SCNR::Introspector::VERSION} -m 'Version #{SCNR::Introspector::VERSION}'"
    sh "gem push scnr-introspector-#{SCNR::Introspector::VERSION}.gem"
end
task release: [ :publish ]
