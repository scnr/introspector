require 'bundler/gem_tasks'

desc 'Generate docs.'
task :docs do

    outdir = "../arachni-introspector-docs"
    sh "rm -rf #{outdir}"
    sh "mkdir -p #{outdir}"

    sh "yardoc -o #{outdir}"

    sh "rm -rf .yardoc"
end

