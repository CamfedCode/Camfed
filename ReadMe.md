## Build Status

[![Join the chat at https://gitter.im/CamfedCode/Camfed](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/CamfedCode/Camfed?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/CamfedCode/Camfed.png)](https://travis-ci.org/CamfedCode/Camfed)

## Environment Setup

Install ruby 1.9.2-p180

    rvm install ruby-1.9.2-p180

Create camfed gemset

    rvm gemset create camfed

Install required gems

    bundle install

Setup database

    rake db:migrate

Seed database (settings + initial account)

    rake db:seed

Accept the rvmrc file

## License

Apache License, Version 2.0

Copyright (c) Camfed International 2011-2013
http://www.camfed.org
