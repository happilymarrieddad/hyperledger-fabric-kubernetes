#!/bin/bash

bash ./deploy-api.sh

sleep 5

bash ./deploy-web.sh

sleep 1

echo "Completed!"
