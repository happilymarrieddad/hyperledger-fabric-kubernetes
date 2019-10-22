#!/bin/bash

fabric-ca-server start \
    -b $ROOT_USERNAME:$ROOT_PASSWORD \
    --cfg.affiliations.allowremove \
    --cfg.identities.allowremove \
    --csr.hosts "ca-root"
