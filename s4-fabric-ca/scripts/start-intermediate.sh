#!/bin/bash

sleep 5

if fabric-ca-server init \
    -b $ROOT_USERNAME:$ROOT_PASSWORD \
    -u http://$ROOT_USERNAME:$ROOT_PASSWORD@$ROOT_HOST:$ROOT_PORT \
    --csr.hosts "ca-root"; then

    fabric-ca-server start \
        -b $INTERMEDIATE_USERNAME:$INTERMEDIATE_PASSWORD \
        --cfg.affiliations.allowremove \
        --cfg.identities.allowremove \
        --csr.hosts "ca-intermediate"

else
    echo "Failed to initialize intermediate CA..."
    sleep infinity
fi
