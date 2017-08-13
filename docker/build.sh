#!/bin/bash

#docker login

docker build -t alastair -f Dockerfile.dev .
docker tag alastair aegee/alastair:dev
#docker push aegee/omsevents:dev