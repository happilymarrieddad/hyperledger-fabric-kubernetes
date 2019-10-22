#!/bin/bash

USER=$1
PASS=$2
TYPE=${3-orderer}
ORG=${4-org1}

echo ""
echo "=== Registering entity ==="
fabric-ca-client register --id.secret $PASS --id.name $USER --id.type $TYPE --id.affiliation $ORG
sleep 1
echo "=== Finished registering entity ==="
echo ""
