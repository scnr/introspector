require 'rspec'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec)

desc 'Generate docs.'
task :docs do

    outdir = "../arachni-introspector-docs"
    sh "rm -rf #{outdir}"
    sh "mkdir -p #{outdir}"

    sh "yardoc -o #{outdir}"

    sh "rm -rf .yardoc"
end

