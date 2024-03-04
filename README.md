# Attribute-Based Access Control (ABAC) for Ethereum

<!-- このプロジェクトは，Ethereum上での属性ベースアクセス制御フレームワークに関するポリシー検索効率の改善を目指す．
1. 新規ポリシー追加に伴う重複の判定
2. 属性情報をキーとしたポリシーの取得
の二つに対して，GASと実行時間を削減することを目的とした手法を二つを提案している．
一つ目は，Add using Counting Bloom Filter で，これはCounting Bloom Filterにてポリシーの包含判定を低コストで行っている．
二つ目は，Get using Ring Buffe で，これはRing Buffer をキャッシュとして実装することで，再参照のコストを削減している． -->

This project aims to improve the efficiency of policy search on an Attribute-Based Access Control (ABAC) framework for Ethereum. Two methods are proposed to reduce GAS and execution time for:

1. Detection of duplicates upon adding new policies.
2. Retrieval of policies based on attribute information.

The first method is **Add using Counting Bloom Filter**, which utilizes a Counting Bloom Filter to perform inclusion checks for policies at a low cost.

The second method is **Get using Ring Buffer**, which reduces the cost of re-referencing by implementing a Ring Buffer as a cache.

## Requirements
- solc 0.8.19
- truffle 5.11.5
- Python 3.9
   - `pip3 install web3`

## Compile
You can compile all contracts using the command `truffle compile`.

## Deployment
You can deploy the contract to any blockchain using the included [deploy.py](python/deploy.py) script.
1. Retrieve the HTTP URL of the blockchain you want to connect to and establish the connection.
2. Retrieve the private key of the account from which you want to send the transaction.
3. Select the JSON file of the contract you want to deploy.
4. Select the JSON file to save the contract address.
5. Execute Deploy.py to complete the deployment.

## Usage
```solidity:Difinition
struct ObjectAttribute {
        string name;
        string place;
    }

    struct Object {
        string id;
        ObjectAttribute attribute;
    }

    struct SubjectAttribute {
        string name;
        string role;
    }

    struct Subject {
        string id;
        SubjectAttribute attribute;
    }

    struct Action {
        bool write;
        bool read;
        bool execute;
    }

    struct Context {
        uint start;
        uint end;
    }

    struct Policy {
        Subject subject;
        Object object;
        Action action;
        Context context;
    }
```
### Using [SAMC.sol](contracts/SAMC.sol) and [OAMC.sol](contracts/OAMC.sol) , you can add attribute information for subjects and objects.
- addSubject(id, name, role)
- addObject(id, name, place)
### Using [ACBF.sol](contracts/ACBF.sol), you can add policies.
- addPolicy(Subject, Object, Action, Context)
### Using [GRB.sol](contracts/GRB.sol), you can get access permissions.
- getAccessResult(subjectId, objectId)
### [PMC.sol](contracts/PMC.sol) and [ACC.sol](contracts/ACC.sol) utilize linear search.
Comparison with ACBF and GRB is possible.

## Related Works
- Y. Zhang, M. Yutaka, M. Sasabe, and S. Kasahara, “Attribute-based access control for smart cities: A smart-contract-driven framework,” IEEE Internet of Things Journal, vol. 8, no. 8, pp. 6372–6384, 2020. [10.1109/JIOT.2020.3033434](https://doi.org/10.1109/JIOT.2020.3033434)
- [solidity-bloom-filter](https://github.com/wanseob/solidity-bloom-filter.git)

## Publications
- S. Kuroki, .... "" (In Japanese), ２０２４年IEICE総合大会   
<!-- <-- 発表スライドをZenodoなどにアップロードした後に，ここに url を載せるといいです ;-) -->

## Contributors
- Shouta Kuroki