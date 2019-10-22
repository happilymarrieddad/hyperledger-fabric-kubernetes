#!/bin/bash

USER=$1
PASS=$2
URL=$3
DIR=$4
ORG=${5-org1}
SCHEME=${6-http}

echo ""
echo "=== Enrolling entity MSP ==="
fabric-ca-client enroll -u $SCHEME://$USER:$PASS@$URL -M $DIR --id.affiliation $ORG
sleep 1
echo "=== Finished enrolling entity MSP ==="
echo ""
