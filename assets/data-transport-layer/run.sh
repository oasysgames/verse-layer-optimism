#!/bin/sh

set -xe

envSet () {
  VAR=$1
  export $VAR=$(jq -r .$2 /assets/addresses.json)
}

envSet DATA_TRANSPORT_LAYER__ADDRESS_MANAGER Lib_AddressManager

exec node dist/src/services/run.js
