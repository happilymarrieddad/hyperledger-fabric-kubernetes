#!/bin/bash

URL=$1
DIR=$2
TYPE=${3-client}
SCHEME=${4-http}
ORG=${5-org1}

echo ""
echo "=== Getting ca cert '$DIR' ==="
fabric-ca-client getcacert -u $SCHEME://$URL -M $DIR --id.type $TYPE --id.affiliation $ORG
sleep 1
echo "=== Finished getting ca cert '$DIR' ==="
echo ""
