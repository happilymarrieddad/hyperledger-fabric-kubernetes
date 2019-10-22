#!/bin/bash

USER=$1
PASS=$2
URL=$3
SCHEME=${4-http}

echo ""
echo "=== Enrolling CA Client ==="
fabric-ca-client enroll -u $SCHEME://$USER:$PASS@$URL
sleep 1
echo "=== Finished enrolling CA Client ==="
echo ""
