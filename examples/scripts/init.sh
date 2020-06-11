#!/bin/bash

echo
echo "Starting network!"
cryptogen generate --config crypto-config.yaml
sleep 2
echo "Generating certs"
make setup
echo "Finished!"