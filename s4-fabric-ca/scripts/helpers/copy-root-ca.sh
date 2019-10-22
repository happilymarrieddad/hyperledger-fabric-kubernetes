#!/bin/bash

if [ -f $2/ca/middleCa/ca-chain.pem ];then
    cp -rf $2/ca/middleCa/ca-chain.pem $1/ca.crt
fi
