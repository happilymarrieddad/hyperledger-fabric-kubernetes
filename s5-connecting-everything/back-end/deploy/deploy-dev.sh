#!/bin/bash

docker build -t happilymarrieddad/udemy-kubernetes-back-end:latest-dev -f Dockerfile .

docker push happilymarrieddad/udemy-kubernetes-back-end:latest-dev
