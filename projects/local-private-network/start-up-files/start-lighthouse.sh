#!/bin/bash

# This bash script will be used to start the lighthouse client

# Does the beacon node actually need to connect to geth???

lighthouse bn  \
    --http --metrics --private --network mainnet &

tail -f /dev/null

## Potentially useful flags
## --reconstruct-historic-states --checkpoint-block xxxx --checkpoint-state xxxx --slots-per-restore-point 32