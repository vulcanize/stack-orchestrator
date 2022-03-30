#!/bin/bash
  for add in $(cat ./genesis.json | jq '.alloc' | jq -r 'keys | .[]'); do
    echo $add
    address_value="address_value_${add}"
    address+=( $address_value )
    jq '.alloc | with_entries(if .key == "'"$add"'" then .key = "'"$address_value"'" else . end)' genesis.json
    #jq '.alloc."'"$add"'" = "'"$address_value"'" ' genesis.json
    #jq --arg add "$add" --arg address_value "$address_value" '.alloc.val = address_value' genesis.json
    #jq --arg address_value "$address_value" address "$i" '.alloc.$address = $address_value' genesis.json
  done

echo ${address[@]}
