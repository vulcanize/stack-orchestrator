#!/bin/bash

# This bash script will be used to start the lighthouse client
# The 0.0.0.0 is not safe.

lighthouse bn  \
    --http --http-address 0.0.0.0 --metrics --private --reconstruct-historic-states --network $NETWORK &

tail -f /dev/null
