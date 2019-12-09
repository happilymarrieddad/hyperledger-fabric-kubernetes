#!/bin/bash

export SHA=$(git rev-parse HEAD)

docker build -t happilymarrieddadudemy/udemy-kubernetes-front-end:${SHA} -f Dockerfile .

docker push happilymarrieddadudemy/udemy-kubernetes-front-end:${SHA}

sleep 5

kubectl set image deployments/web-deployment web=happilymarrieddadudemy/udemy-kubernetes-front-end:${SHA}
