# U-report  

[![Build Status][master-build-image]][travis-ci]

[travis-ci]: https://travis-ci.org/rapidpro/ureport/
[master-build-image]: https://travis-ci.org/rapidpro/ureport.svg?branch=master

This is the U-report dashboard built on data collected by RapidPro.

Built for UNICEF by Nyaruka - http://nyaruka.com

## Getting Started with docker ##

### Install docker-compose ###

Even though we run this project in docker, we still have some dependencies 
like `docker-compose`.

It's recommended you install `docker-compose` in a virtualenv to avoid 
dependency clashes with other python libraries (e.g., it clashes with the 
awsebcli).

    virtualenv ~/virtualenvs/ureport
    source ~/virtualenvs/ureport/bin/activate
    pip install docker-compose

### Local development ###

First you'll need to authenticate to ECR:

    $(aws ecr get-login us-east-1)

Then pull the docker image:

    docker pull 387526361725.dkr.ecr.us-east-1.amazonaws.com/ureport:latest

Or, if you don't want to pull the image you can build it yourself:

    docker-compose build

You'll need to sync the database and run migrations:

    docker-compose run ureport setuplocaldb

Then run a local container with:

    docker-compose up

Now you should be able to hit http://localhost/ for a running uReport.

## Deployment ##

We use fabric to prepare our deploys and elastic beanstalk to do the legwork.

At the time of writing there is a dependency clash between docker-compose and 
awsebcli so we create a separate virtualenv for each.

    virtualenv ~/virtualenvs/deploy
    source ~/virtualenvs/deploy/bin/activate
    pip install -r pip-deploy.txt

To prepare a deploy:

    fab -f eb_deploy.py <env> prepare_deploy


To perform a deploy:

     eb deploy <env>

## Getting started without docker ##

Install dependencies
```
% virtualenv env
% source env/bin/activate
% pip install -r pip-requires.txt
```

Link up a settings file (you'll need to create the postgres db first, username: 'ureport' password: 'nyaruka')
```
% ln -s ureport/settings.py.postgres ureport/settings.py
```

Sync the database, add all our models and create our superuser
```
% python manage.py syncdb
% python manage.py migrate
% python manage createsuper
```

At this point everything should be good to go, you can start with:

```
% python manage.py runserver
```

Note that the endpoint called for API calls is by default 'localhost:8001', you can uncomment the RAPIDPRO_API line in settings.py.postgres to go against production servers.
