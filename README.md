rOCCI-cli - A Ruby OCCI Framework
=================================

[![Build Status](https://secure.travis-ci.org/EGI-FCTF/rOCCI-cli.png)](http://travis-ci.org/EGI-FCTF/rOCCI-cli)
[![Dependency Status](https://gemnasium.com/EGI-FCTF/rOCCI-cli.png)](https://gemnasium.com/EGI-FCTF/rOCCI-cli)
[![Gem Version](https://fury-badge.herokuapp.com/rb/occi-cli.png)](https://badge.fury.io/rb/occi-cli)
[![Code Climate](https://codeclimate.com/github/EGI-FCTF/rOCCI-cli.png)](https://codeclimate.com/github/EGI-FCTF/rOCCI-cli)

Requirements
------------

### Ruby
* Ruby 1.9.3 or newer is required
* RubyGems have to be installed

### Examples
#### For distros based on Debian:
~~~
apt-get install ruby rubygems ruby-dev
~~~
~~~
ruby -v
~~~

**Unless you have Ruby >= 1.9.3, please, go to [rOCCI-cli#RVM](#rvm) and install RVM with a newer Ruby version.**

#### For distros based on RHEL:
~~~
yum install ruby-devel openssl-devel gcc gcc-c++ ruby rubygems
~~~
~~~
ruby -v
~~~

**Unless you have Ruby >= 1.9.3, please, go to [rOCCI-cli#RVM](#rvm) and install RVM with a newer Ruby version.**

To use rOCCI-cli with Java, you need JRE 6 or 7. To build rOCCI-cli for Java, you need JDK 6 or 7.

Installation
------------

### From RubyGems.org

**[Mac OS X has some special requirements for the installation. Detailed information can be found in doc/macosx.md.](doc/macosx.md)**

To install the most recent stable version

    gem install occi-cli

To install the most recent beta version

    gem install occi-cli --pre

### From source (dev)

**Installation from source should never be your first choice! Especially, if you are not familiar with RVM, Bundler, Rake and other dev tools for Ruby!**

**However, if you wish to contribute to our project, this is the right way to start.**

To build and install the bleeding edge version from master

    git clone git://github.com/EGI-FCTF/rOCCI-cli.git
    cd rOCCI-cli
    gem install bundler
    bundle install
    bundle exec rake test
    rake install

### From source, for Java

**Notice:** In order to build rOCCI-cli for Java, you need working jRuby installation. We recommend using [rOCCI-cli#RVM](#rvm).

To build a Java jar file from master use

    git clone git://github.com/EGI-FCTF/rOCCI-cli.git
    cd rOCCI-cli
    gem install bundler
    bundle install
    warble

For Linux / Mac OS X you can create a OCCI Java executable from the jar file using

    sudo echo '#!/usr/bin/java -jar' | cat - occi-cli.jar > occi ; sudo chmod +x occi

### RVM

**Notice:** Follow the RVM installation guide linked below, we recommend using the default 'Single-User installation'.

**Warning:** NEVER install RVM as root! If you choose the 'Multi-User installation', use a different user account with sudo access instead!

* [Installing RVM](https://rvm.io/rvm/install#explained)
* Install Ruby

~~~
rvm requirements
rvm install 1.9.3
rvm use 1.9.3 --default
~~~
~~~
ruby -v
~~~

Usage
-----
### Client
The OCCI gem includes a client you can use directly from shell with the following auth methods: x509 (with --password, --user-cred and --ca-path), basic (with --username and --password), digest (with --username and --password), none. If you won't set a password using --password, the client will ask for it later on.

To find out more about available options and defaults use

    occi --help

To list available resources use

    occi --endpoint https://<ENDPOINT>:<PORT>/ --action list --resource compute --auth x509
    occi --endpoint https://<ENDPOINT>:<PORT>/ --action list --resource storage --auth x509
    occi --endpoint https://<ENDPOINT>:<PORT>/ --action list --resource network --auth x509

To describe available resources use

    occi --endpoint https://<ENDPOINT>:<PORT>/ --action describe --resource compute --auth x509
    occi --endpoint https://<ENDPOINT>:<PORT>/ --action describe --resource storage --auth x509
    occi --endpoint https://<ENDPOINT>:<PORT>/ --action describe --resource network --auth x509

To describe specific resources use

    occi --endpoint https://<ENDPOINT>:<PORT>/ --action describe --resource /compute/<OCCI_ID> --auth x509
    occi --endpoint https://<ENDPOINT>:<PORT>/ --action describe --resource /storage/<OCCI_ID> --auth x509
    occi --endpoint https://<ENDPOINT>:<PORT>/ --action describe --resource /network/<OCCI_ID> --auth x509

To list available OS templates or Resource templates use

    occi --endpoint https://<ENDPOINT>:<PORT>/ --action list --resource os_tpl --auth x509
    occi --endpoint https://<ENDPOINT>:<PORT>/ --action list --resource resource_tpl --auth x509

To describe a specific OS template or Resource template use

    occi --endpoint https://<ENDPOINT>:<PORT>/ --action describe --resource os_tpl#debian6 --auth x509
    occi --endpoint https://<ENDPOINT>:<PORT>/ --action describe --resource resource_tpl#small --auth x509

To create a compute resource with mixins use

    occi --endpoint https://<ENDPOINT>:<PORT>/ --action create --resource compute --mixin os_tpl#debian6 --mixin resource_tpl#small --attribute occi.core.title="My rOCCI VM" --auth x509

To delete a compute resource use

    occi --endpoint https://<ENDPOINT>:<PORT>/ --action delete --resource /compute/<OCCI_ID> --auth x509

Changelog
---------

### Version 4.3
* Updated dependencies
* Powered by rOCCI-core 4.3.x
* New `discover` functionality

### Version 4.2
* Droppped the interactive mode (it might return in the future)
* Updated internals
* Updated user interface and human-readable rendering
* __Includes interface changes incompatible with v4.1.x__

### Version 4.1
* Dropped Ruby 1.8.x support
* Dropped jRuby 1.6.x support
* Updated dependencies

### Version 4.0
* added extended support for OCCI-OS
* updated human-readable output rendering
* split the code into rOCCI-core, rOCCI-api and rOCCI-cli
* internal changes, refactoring and some bugfixes

### Version 3.1
* added basic OS Keystone support
* added support for PKCS12 credentials for X.509 authN
* updated templates for plain output formatting
* minor client API changes
* several bugfixes

### Version 3.0

* many bugfixes
* rewrote Core classes to use metaprogramming techniques
* added VCR cassettes for reliable testing against prerecorded server responses
* several updates to the OCCI Client
* started work on an OCCI Client using AMQP as transport protocol
* added support for keystone authentication to be used with the OpenStack OCCI server
* updated dependencies
* updated rspec tests
* started work on cucumber features

### Version 2.5

* improved OCCI Client
* improved documentation
* several bugfixes

### Version 2.4

* Changed OCCI attribute properties from lowercase to first letter uppercase (e.g. type -> Type, default -> Default, ...)

### Version 2.3

* OCCI objects are now initialized with a list of attributes instead of a hash. Thus it is easier to check which
attributes are expected by a class and helps prevent errors.
* Parsing of a subset of the OVF specification is supported. Further parts of the specification will be covered in
future versions of rOCCI.

### Version 2.2

* OCCI Client added. The client simplifies the execution of OCCI commands and provides shortcuts for often used steps.

### Version 2.1

* Several improvements to the gem structure and code documentation. First rSpec test were added. Readme has been extended to include instructions how the gem can be used.

### Version 2.0

* Starting with version 2.0 Florian Feldhaus and Piotr Kasprzak took over the development of the OCCI gem. The codebase was taken from the rOCCI framework and improved to be bundled as a standalone gem.

### Version 1.X

* Version 1.X of the OCCI gem has been developed by retr0h and served as a simple way to access the first OpenNebula OCCI implementation.

Development
-----------

Checkout latest version from GIT:

    git clone git://github.com/EGI-FCTF/rOCCI-cli.git

Change to rOCCI-cli folder

    cd rOCCI-cli

Install dependencies for deployment

    bundle install

### Code Documentation

[Code Documentation for rOCCI-cli by YARD](http://rubydoc.info/github/EGI-FCTF/rOCCI-cli/)

### Continuous integration

[Continuous integration for rOCCI-cli by Travis-CI](http://travis-ci.org/EGI-FCTF/rOCCI-cli/)

### Contribute

1. Fork it.
2. Create a branch (git checkout -b my_markup)
3. Commit your changes (git commit -am "My changes")
4. Push to the branch (git push origin my_markup)
5. Create an Issue with a link to your branch
