#!/bin/bash
set -e
set -x

TAG=$TRAVIS_TAG
BRANCH=$TRAVIS_BRANCH
PR=$TRAVIS_PULL_REQUEST

echo $TAG
echo $BRANCH
echo $PR

if [ -z $TAG ]
then
    echo "No tags, tagging as: latest"
    TAG="latest"
fi

# if this is on the develop branch and this is not a PR, deploy it
if [ $BRANCH = "develop" -a $PR = "false" ]
then
    aws ecr get-login --region=us-east-1 | bash
    docker tag -f ureport_ureport:latest 387526361725.dkr.ecr.us-east-1.amazonaws.com/ureport:$TAG
    docker push 387526361725.dkr.ecr.us-east-1.amazonaws.com/ureport:$TAG

    fab -f eb_fabfile.py stage prepare_deploy

    # we never want our elastic beanstalk to use tag "latest" so if this is an
    # un-tagged build, use the commit hash
    if [ $TAG = "latest" ]
    then
        TAG=$TRAVIS_COMMIT
    fi
    eb deploy -l $TAG
fi
