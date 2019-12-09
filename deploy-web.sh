#!/bin/bash

export SHA=$(git rev-parse HEAD)

docker build -t happilymarrieddadudemy/udemy-kubernetes-front-end:${SHA} \
    -f ./s5-connecting-everything/front-end/Dockerfile \
    ./s5-connecting-everything/front-end

docker push happilymarrieddadudemy/udemy-kubernetes-front-end:${SHA}

sleep 5

kubectl set image deployments/web-deployment web=happilymarrieddadudemy/udemy-kubernetes-front-end:${SHA}
