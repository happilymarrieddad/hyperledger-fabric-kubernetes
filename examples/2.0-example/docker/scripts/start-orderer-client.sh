#!/bin/bash

. /scripts/start-client-ca.sh

sleep 5

. /scripts/create-orderer-certs.sh \
    ${CA_SCHEME} \
    ${CA_USERNAME} \
    ${CA_PASSWORD} \
    ${CA_URL} \
    ${CA_CERT_PATH}

sleep infinity
