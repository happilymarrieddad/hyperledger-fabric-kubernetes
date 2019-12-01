#!/bin/bash

docker build -t happilymarrieddadudemy/udemy-kubernetes-back-end:latest -f Dockerfile .

docker push happilymarrieddadudemy/udemy-kubernetes-back-end:latest
