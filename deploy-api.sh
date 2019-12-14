#!/bin/bash

export SHA=$(git rev-parse HEAD)

docker build -t happilymarrieddadudemy/udemy-kubernetes-back-end:${SHA} \
    -f ./s5-connecting-everything/back-end/Dockerfile \
    ./s5-connecting-everything/back-end

docker push happilymarrieddadudemy/udemy-kubernetes-back-end:${SHA}

sleep 10

kubectl set image deployments/api-deployment api=happilymarrieddadudemy/udemy-kubernetes-back-end:${SHA}
