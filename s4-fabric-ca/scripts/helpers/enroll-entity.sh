#!/bin/bash

USER=$1
PASS=$2
URL=$3
ORG=${4-org1}
SCHEME=${5-http}

echo ""
echo "=== Enrolling entity ==="
fabric-ca-client enroll -u $SCHEME://$USER:$PASS@$URL --id.affiliation $ORG
sleep 1
echo "=== Finished enrolling entity ==="
echo ""
