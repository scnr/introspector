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

Add this line to your application's Gemfile:

```ruby
gem 'arachni-introspector'
```

And then execute:

    bundle

Or install it yourself as:

    gem install arachni-introspector

## Usage

TBD
