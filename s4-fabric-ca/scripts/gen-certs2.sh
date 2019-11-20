#!/bin/bash

# Allows for the file to be run anywhere
export SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

fabric-ca-client enroll -u http://admin:adminpw@ca-root:7054

bash $SCRIPTDIR/helpers/crypto.sh orderer:default.svc.cluster.local:default.svc.cluster.local:3

bash $SCRIPTDIR/helpers/crypto.sh peer:org1:default.svc.cluster.local:2
bash $SCRIPTDIR/helpers/crypto.sh peer:org2:default.svc.cluster.local:2
