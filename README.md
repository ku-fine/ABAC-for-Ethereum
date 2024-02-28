# Attrebute-Based Access Control (ABAC) for Ethereum

<!-- このプロジェクトは，Ethereum上での属性ベースアクセス制御フレームワークに関するポリシー検索効率の改善を目指す．
1. 新規ポリシー追加に伴う重複の判定
2. 属性情報をキーとしたポリシーの取得
の二つに対して，GASと実行時間を削減することを目的とした手法を二つを提案している．
一つ目は，Add using Counting Bloom Filter で，これはCounting Bloom Filterにてポリシーの包含判定を低コストで行っている．
二つ目は，Get using Ring Buffe で，これはRing Buffer をキャッシュとして実装することで，再参照のコストを削減している． -->

This project aims to improve the efficiency of policy search on an attribute-based access control framework for Ethereum. Two methods are proposed to reduce GAS and execution time for:

1. Detection of duplicates upon adding new policies.
2. Retrieval of policies based on attribute information.

The first method is **Add using Counting Bloom Filter**, which utilizes a Counting Bloom Filter to perform inclusion checks for policies at a low cost.

The second method is **Get using Ring Buffer**, which reduces the cost of re-referencing by implementing a Ring Buffer as a cache.

## Requirements
- solc 0.8.19
- Python 3.9
   - `pip3 install web3`

## Usage

To build this whole project (including clone and compile APGAS and GLB as necessary components), run:

```shell
./ElasticJobScheduler/scripts/cloneAndCompileAll.sh
```

## Usage

### SAMC.sol, OAMC.sol を用いてサブジェクトとオブジェクトの属性情報を追加する



## Contributors

In alphabetical order:

- Janek Bürger
- Patrick Finnerty
- Jonas Posner
