#!/bin/bash

if [ ! -d $1/tlscacerts ]; then
    mkdir $1/tlscacerts
    cp $1/cacerts/* $1/tlscacerts
    if [ -d $1/intermediatecerts ]; then
        mkdir $1/tlsintermediatecerts
        cp $1/intermediatecerts/* $1/tlsintermediatecerts
    fi
fi
