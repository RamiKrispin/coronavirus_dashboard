#!/usr/bin/env bash

echo "Build the docker"



if [[ $1 ==  "" ]] ; then
  echo "Tag: 'dev'"
  tag='dev'
else
  echo "Tag: $1"
  tag=$1
fi


docker build . --progress=plain \
                -t rkrispin/coronavirus_dashboard:$tag

if [[ $? = 0 ]] ; then
echo "Pushing docker..."
docker push rkrispin/coronavirus_dashboard:$tag
else
echo "Docker build failed"
fi
