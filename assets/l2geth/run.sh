#!/bin/sh

set -e

KEY_FILE=$(mktemp)

echo $BLOCK_SIGNER_KEY | cut -c 3-99 > $KEY_FILE

geth account import --password /dev/null $KEY_FILE || true
rm -rf $KEY_FILE

if [ ! -d $DATADIR/geth ]; then
  geth --verbosity $VERBOSITY init $GENESIS_JSON
fi

exec geth \
  --verbosity $VERBOSITY \
  --networkid $CHAIN_ID \
  --password /dev/null \
  --allow-insecure-unlock \
  --unlock $BLOCK_SIGNER_ADDRESS \
  --mine \
  --miner.etherbase $BLOCK_SIGNER_ADDRESS \
  "$@"
