# 1. Import Module
import json
from web3 import Web3, HTTPProvider

def deploy(self):
    # 2. Access Ganache local server
    settingFile = json.load(open('./setting.json'))
    url = settingFile['url']
    web3 = Web3(HTTPProvider(url))
    print(web3.is_connected())

    # 3. private key
    key = settingFile['privateKey']
    acct = web3.eth.account.from_key(key)

    truffleFile = json.load(open('./build/contracts/deploy.json'))
    abi = truffleFile['abi']
    bytecode = truffleFile['bytecode']
    contract= web3.eth.contract(bytecode=bytecode, abi=abi)

    # 5. Building transaction information
    construct_txn = contract.constructor().build_transaction({
        'from': acct.address,
        'nonce': web3.eth.get_transaction_count(acct.address),
        'gas': 30000000,
        'gasPrice': web3.to_wei('21', 'gwei')})

    # 6. Send Transaction
    signed = acct.sign_transaction(construct_txn)
    tx_hash = web3.eth.send_raw_transaction(signed.rawTransaction)
    print(tx_hash.hex())

    # 7. Display contract address
    tx_receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
    print("Contract Deployed At:", tx_receipt['contractAddress'])

    with open('./contractAddress.json') as f:
        update = json.load(f)

    update['deploy'] = tx_receipt['contractAddress']

    with open('./contractAddress.json', 'w') as f:
        json.dump(update, f, indent=2)
    

