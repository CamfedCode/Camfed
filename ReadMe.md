## Build Status
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

Copyright (c) Camfed 2010-2013
http://www.camfed.org
