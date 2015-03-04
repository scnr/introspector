# Arachni::Introspector

The Arachni Introspector provides an Interactive Application Security Testing (IAST)
solution for Rack-based web applications like Ruby-on-Rails, Sinatra, Merb, etc.

_Powered by the [Arachni Web Application Scanner Framework](http://www.arachni-scanner.com)._

## Features

* Offline testing.
    * No need for a live application supported by an HTTP server.
* Incredible performance for quick scans.
    * Direct communication with the running application.
    * No HTTP, I/O, network overhead.
* Absolutely reliable communication with the application.
    * No need to worry about network conditions, available bandwidth, server
        stress or timed-out requests.
* IAST/Hybrid analysis, offering:
    * Benefits of dynamic analysis:
        * Issues are proven to exist based on the results of code execution.
        * Coverage of dynamic input vectors and workflows.
            * Even when using metaprogramming techniques.
        * Testing of all the usual input vectors:
            * GET and POST parameters.
            * Cookies
            * Headers
            * URL Paths
            * JSON request data
            * XML request data
            * Many more...
        * Real browser analysis, for:
            * Detection of client-side issues.
            * Coverage of applications which rely on HTML5/DOM/JavaScript/AJAX.
        * Detection of issues involving 3rd party entities, like:
            * Operating System command injection
            * SQL injection
            * LDAP injection
            * Unvalidated redirections
            * Lots and lots more...
    * Benefits of static analysis:
        * Access to the application's source code.
        * Access to the application's configuration.
    * Inspection of the application's runtime environment in real-time.
        * Direct access to the internals of the running application.
        * Capture of full context upon detection of a vulnerable state.
            * Stack-traces.
            * Method arguments.
            * Source codes.
    * With special optimizations for:
        * Rails (v3 and v4)
        * Sinatra
        * More to come...
* Code coverage reporting
    * See exactly how much of your codebase was covered by the scan.
    * Examine per issue coverage data, to determine exactly which parts of your
        code contributed to each logged issue.

## Installation

Add these lines to your application's Gemfile:

    gem 'arachni-reactor',      github: 'arachni/arachni-reactor', branch: 'experimental'
    gem 'arachni-rpc',          github: 'arachni/arachni-rpc',     branch: 'experimental'
    gem 'arachni',              github: 'arachni/arachni',         branch: 'v1.1'
    gem 'arachni-introspector', git:    'git@github.com:Zapotek/arachni-introspector.git'

And then execute:

    bundle

## Usage

There are currently no user interfaces (CLI and WebUI are on the way), hence the
only way to perform scans and retrieve results is via custom scripts.

For examples of such scripts please see the [Demos](#demos) section.

### Caution

#### Code reloading and other tricks

Do not scan applications under their development environments as these usually
enable development conveniences such as code-reloading which will severely increase
scan times.

It is best to scan applications under their optimal settings.

## Demos

### Sinatra

A demo Sinatra application can be found at `examples/sinatra/app.rb`, with a
scanner script at `examples/sinatra/scanner.rb`.

    bundle exec ruby examples/sinatra/scanner.rb

### Rails

A demo Rails application can be found at:
[https://github.com/Zapotek/arachni-introspector-demo-rails](https://github.com/Zapotek/arachni-introspector-demo-rails)

The scanner script can be found at:
[https://github.com/Zapotek/arachni-introspector-demo-rails/blob/master/bin/arachni-introspector.rb](https://github.com/Zapotek/arachni-introspector-demo-rails/blob/master/bin/arachni-introspector.rb).
