#!/bin/bash

make clean
make init
sleep 2
make start
sleep 10
make network
sleep 3
make chaincode
sleep 3
make certs