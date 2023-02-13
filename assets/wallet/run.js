const fs = require('fs')
const ethwallet = require('ethereumjs-wallet')

const outfile = process.argv[2]

if (!outfile) {
    console.error(`Usage: node ${__filename} /path/to/output.txt`)
    process.exit(1)
}

if (fs.existsSync(outfile)) {
    console.info(`already exists`)
    process.exit(0)
}

const accounts = [ 'builder', 'sequencer', 'proposer', 'message-relayer' ]

let content = `
- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
`.trimStart()

for (let account of accounts) {
    let wallet = ethwallet.default.generate()
    content += `\n---- ${account} ----`
    content += `\nAddress: ${wallet.getAddressString()}`
    content += `\nkey:     ${wallet.getPrivateKeyString()}\n`
}

fs.writeFileSync(outfile, content)

console.log('Success')
