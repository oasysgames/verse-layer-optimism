#!/bin/sh

set -xe

RETRIES=${RETRIES:-10000}

envSet () {
  VAR=$1
  export $VAR=$(jq -r .$2 /assets/addresses.json)
}

envSet MESSAGE_RELAYER__ADDRESS_MANAGER Lib_AddressManager
envSet MESSAGE_RELAYER__L1_CROSS_DOMAIN_MESSENGER Proxy__OVM_L1CrossDomainMessenger
envSet MESSAGE_RELAYER__L1_STANDARD_BRIDGE Proxy__OVM_L1StandardBridge
envSet MESSAGE_RELAYER__STATE_COMMITMENT_CHAIN StateCommitmentChain
envSet MESSAGE_RELAYER__CANONICAL_TRANSACTION_CHAIN CanonicalTransactionChain
envSet MESSAGE_RELAYER__BOND_MANAGER BondManager

# waits for l2geth to be up
curl --fail \
    --show-error \
    --silent \
    --retry $RETRIES \
    --retry-connrefused \
    --retry-delay 3 \
    --output /dev/null \
    $MESSAGE_RELAYER__L2_RPC_PROVIDER

exec yarn start
