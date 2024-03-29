# verse-layer-optimism

## 1. Requirements

Docker Engine v20.10.0 or later and docker-compose v2.0 or later are required.

## 2. Create Wallets

Create Ethereum wallets (address and private key) to be used by Builder, Sequencer, and Proposer.

```shell
docker-compose run --rm wallet
```

The created wallets will be saved to `./data/wallet/keys.txt`.

Notes:  
**1. These wallets requires some tokens to run Verse-Layer. For testnet, you can get a token from [Faucet](https://faucet.testnet.oasys.games/).**  
**2. Be sure to back up this file!**

```text:./data/wallet/keys.txt
- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!

---- builder ----
Address: 0x0123456789abcdef0123456789abcdef
key:     0x0123456789abcdef0123456789abcdef0123456789abcdef

---- sequencer ----
Address: 0x0123456789abcdef0123456789abcdef
key:     0x0123456789abcdef0123456789abcdef0123456789abcdef

---- proposer ----
Address: 0x0123456789abcdef0123456789abcdef
key:     0x0123456789abcdef0123456789abcdef0123456789abcdef

---- message-relayer ----
Address: 0x0123456789abcdef0123456789abcdef
key:     0x0123456789abcdef0123456789abcdef0123456789abcdef
```

## 3. Deploy contracts for Verse-Layer to Hub-Layer.

### 3-1. Clone oasys-optimism repository

```shell
git clone https://github.com/oasysgames/oasys-optimism.git /path/to/oasys-optimism

cd /path/to/oasys-optimism/packages/contracts/

git checkout v0.1.2
```

### 3-2. Install dependencies and Build contracts

```shell
npm install  # or "yarn install"

npx hardhat run scripts/generate-artifacts.ts
```

### 3-3. Set environment variables

```shell
export CONTRACTS_TARGET_NETWORK=oasys

# Private key of the "builder" wallet
export CONTRACTS_DEPLOYER_KEY=0x...

# Address of created wallets
export BUILDER_ADDRESS=0x...
export SEQUENCER_ADDRESS=0x...
export PROPOSER_ADDRESS=0x...

# Your Verse-Layer chain ID. Can't change it later.
export CHAIN_ID=

# For mainnet
export CONTRACTS_RPC_URL=https://rpc.mainnet.oasys.games/
export DEPOSIT_AMOUNT=1000000000000000000000000

# For testnet
export CONTRACTS_RPC_URL=https://rpc.testnet.oasys.games/
export DEPOSIT_AMOUNT=1000000000
```

### 3-4. Deposit OAS token

```shell
npx hardhat verse:deposit \
  --network $CONTRACTS_TARGET_NETWORK \
  --builder $BUILDER_ADDRESS \
  --amount $DEPOSIT_AMOUNT

# output
depositing (tx: 0x2faa04c92222133e83eb350f03ec698a4b0d2cfe0a549a118401cdc8c1f5efb8)...: success with 70490 gas
```

### 3-5. Deploy contracts

```shell
npx hardhat verse:build \
  --network $CONTRACTS_TARGET_NETWORK \
  --chain-id $CHAIN_ID \
  --sequencer $SEQUENCER_ADDRESS \
  --proposer $PROPOSER_ADDRESS \
  --fee-wallet $BUILDER_ADDRESS \
  --gpo-owner $BUILDER_ADDRESS

# output
building (tx: 0xc4800ef3dc40a79a10378bf109d192c90b66b6e64a1987ddc6cdbf628d0d7d59)...: success with 17673168 gas
Success writing contract addresses to ./oasys/addresses.json
Success writing genesis block configuration to ./oasys/genesis.json
```

### 3-6. Copy files to verse-layer

Copy the generated configuration filess into the `assets` directory of the `verse-layer` repository.

```shell
cp ./oasys/addresses.json /path/to/verse-layer/assets/

cp ./oasys/genesis.json /path/to/verse-layer/assets/ 
```

When you have completed this step, return to the `verse-layer` repository.

```shell
cd /path/to/verse-layer
```

## 4. Create .env file

Create an environment variable configuration file for containers.

```shell
# Sample for mainnet
cp .env.sample.mainnet .env

# Sample for testnet
cp .env.sample.testnet .env
```

The following settings should be changed.

```shell
# Your Verse-Layer chain ID
L2_CHAIN_ID=

# Private key of created wallets
SEQUENCER_ADDRESS=
SEQUENCER_KEY=

PROPOSER_ADDRESS=
PROPOSER_KEY=

MESSAGE_RELAYER_ADDRESS=
MESSAGE_RELAYER_KEY=
```

> **Warning**  
> Do not change `BLOCK_SIGNER_ADDRESS` and `BLOCK_SIGNER_KEY`. If you change them, the Oasys team will not be able to run replica nodes for Verse-Layer. Furthermore, if the replica node does not exist, the verifier cannot verify the rollup from your Verse-Layer. As a result, the latency of token withdrawal from Verse-Layer to Hub-Layer increases from about 2 minutes to 7 days, resulting in bad UX of the bridge.

## 5. Run Containers

```shell
docker-compose up -d data-transport-layer
docker-compose up -d l2geth
docker-compose up -d batch-submitter
docker-compose up -d message-relayer
```
