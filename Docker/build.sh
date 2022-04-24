#!/bin/bash

docker build --no-cache --rm -t ptsim:arch-20220410 -t ptsim:arch-latest --file Dockerfile-arch .
docker build --no-cache --rm -t ptsim:ubuntu-22.04 -t ptsim:ubuntu-latest --file Dockerfile-ubuntu .
