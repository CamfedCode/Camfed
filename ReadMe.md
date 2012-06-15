## Build Status
![Current Build Status](http://travis-ci.org/CamfedCode/Camfed.png)

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
