# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'arachni/introspector/version'

Gem::Specification.new do |spec|
    spec.name        = 'arachni-introspector'
    spec.version     = Arachni::Introspector::VERSION
    spec.authors     = ['Arachni LLC']
    spec.email       = ['introspector@arachni.com']
    spec.summary     = %q{Rack application security scanner built around the Arachni Framework.}
    spec.homepage    = 'http://www.arachni.com/introspector'
    spec.license     = 'Commercial'

    spec.files         = `git ls-files -z`.split("\x0")
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
    spec.require_paths = ['lib']

    spec.add_dependency 'arachni'

    spec.add_development_dependency 'bundler', '~> 1.7'
    spec.add_development_dependency 'rake',    '~> 10.0'
    spec.add_development_dependency 'sinatra'
end
