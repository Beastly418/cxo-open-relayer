Welcome to the one stop shop for the open relayer project. 

Restock API link: https://polygonscan.com/address/0x1bB8AFbe938a815367EfE095F7cD73fA86702aeA

Doc API link: https://polygonscan.com/address/0xc67442467b3D6F853b1ED97ce2AD210083075749

Token API link: https://polygonscan.com/address/0xE245a188C475dFe67C0BA3021C9f052B088b6e9A

Immportant notes: The restock API only tracks the current automated restock system. Restock generated prior will be handled in the V3 api. For now, add 21734721.334 to the total restock.

TODO:
* Upload bot scripts for running the api
* Re-open source the relayer code
* Re-write the relayer in zig because zig looks fun to learn (will need to do raw json-rpc calls and manual signing so tons to learn!!) [lowest priority]

API V3 Improvements:
* Integrate the old restock data into the API in a neat way
* Add the actual date information on chain to make it easier to pull data **and** use structs to be more efficient (we don't need 256bits for what we're doing!!)
  * Put this data into a struct and start bit banging
* Build up a "restock fund api" to track usdt inflows into the 0x restock address
* Unite all apis under one hub [undecided]

SDK TODO:
* Zapper
* NFT mint for stake
* Vampire Vaults (automagically convert rewards)
  * Decentralized ownership, all tied to a single factory
  * These will allow end users to open up their own vaults where they can get a % of the platform fees
  * All deposits will filter down to the core Dynamic Relayer Pool
* Steam key encrypter (for stake to buy keys)
* CCIP bridge-to-zapper
* Example code for all of the above
