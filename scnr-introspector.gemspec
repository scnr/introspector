# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'scnr/introspector/version'

Gem::Specification.new do |spec|
    spec.name        = 'scnr-introspector'
    spec.version     = SCNR::Introspector::VERSION
    spec.authors     = ['Tasos Laskos']
    spec.email       = ['tasos.laskos@gmail.com']
    spec.summary     = %q{Rack application security scanner built around the SCNR::Engine.}
    spec.homepage    = 'http://ecsypno.com'
    spec.license     = 'Commercial'

    spec.files       = Dir.glob( 'bin/.gitkeep' )
    spec.files       = Dir.glob( 'lib/**/*' )

    spec.add_development_dependency 'bundler'
    spec.add_development_dependency 'rake',    '~> 10.0'
    spec.add_development_dependency 'puma'
    spec.add_development_dependency 'sinatra'
    spec.add_development_dependency 'sinatra-contrib'
end
