#!/bin/bash

sleep 5
fabric-ca-client enroll \
    -u ${CA_SCHEME}://${CA_USERNAME}:${CA_PASSWORD}@${CA_URL} \
    --tls.certfiles ${CA_CERT_PATH}
