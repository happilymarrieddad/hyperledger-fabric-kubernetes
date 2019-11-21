#!/bin/bash


docker build -t happilymarrieddad/udemy-kubernetes-front-end:latest-dev -f Dockerfile.dev .

docker push happilymarrieddad/udemy-kubernetes-front-end:latest-dev
