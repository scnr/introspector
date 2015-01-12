source 'https://rubygems.org'

group :docs do
    gem 'yard'
    gem 'redcarpet'
end

group :spec do
    gem 'simplecov', require: false, group: :test

    gem 'rspec'
    gem 'faker'
end

group :prof do
    gem 'sys-proctable'
    gem 'ruby-prof'
    gem 'stackprof'
    gem 'ruby-mass'
end

gem 'arachni-reactor', github: 'arachni/arachni-reactor', branch: 'experimental'
gem 'arachni-rpc',     github: 'arachni/arachni-rpc',     branch: 'experimental'
gem 'arachni',         path: '../arachni/'

gemspec
