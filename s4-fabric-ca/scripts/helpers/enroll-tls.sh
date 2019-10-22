#!/bin/bash

USER=$1
PASS=$2
URL=$3
DIR=$4
DNS=$5
ORG=${6-org1}
SCHEME=${7-http}

echo ""
echo "=== Enrolling TLS ==="
fabric-ca-client enroll \
    --enrollment.profile tls \
    -u $SCHEME://$USER:$PASS@$URL \
    -M $DIR \
    --csr.hosts $DNS \
    --id.affiliation $ORG
sleep 1
echo "=== Finished enrolling TLS ==="
echo ""
