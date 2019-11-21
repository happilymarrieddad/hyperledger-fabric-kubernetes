#!/bin/bash

apt update -y && apt install curl -y

sleep 10

URL=http://$CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME:$CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD@$CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS

DBS=$(curl $URL/_all_dbs)

if [ "$DBS" == "[]" ]; then
    curl -X PUT $URL/_users
    curl -X PUT $URL/_replicator
fi

sleep 5

peer node start
