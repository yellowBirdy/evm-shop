# Minimal onchain shop - order keeping system

Minimal order keeping system for an e-shop application. Allows for creating and canceling orders by users. Admin may change order status to `canceled`, `processing`, `fullfilled`, `failed` and `invalid`.
Order is viewable onchain only to the admin and it's creator. Note that anyone can read the contents from offchain, hence it is not functionally private.

Deploys with two hardcoded products for showcasing purposes.

## Architecture overview
`IShop.sol` contains the interface of the main contract.
`Shop.sol` is the only contract and entrypoint for all interctions.
`Order.sol` contains the data structures of `Order` and `Product` and functions validating and modifying the orders.

## Documentation 
Documentation is avaialble in `html` format in `docgen/index.html`

## Testing
In order to execute  the tests run
```
forge test
```

## Deployment
In order to deploy fill out the `.evn`file. Project requires an existing (free) [Alchemy](https://www.alchemy.com/) rpc endpoint and [etherscan](https://etherscan.io/) api key.

Deployment command:

```
forge create --rpc-url mainnet src/Shop.sol:Shop --private-key <deployer_private_key> --verify --etherscan-api-key mainnet
```

Notes:
* Should another rpc be used replace `mainnet` with your rpc url.
* Should contract verification be ommited (not reccomended), ommit `--verify --etherscan-api-key mainnet`


Testnet deployment avaialbe under address [0x391805d58Fc27280Ed3b6469C1350b02A872cB2d](https://goerli.etherscan.io/address/0x391805d58Fc27280Ed3b6469C1350b02A872cB2d)
It is possible to interact with the contract via [ehterscan inteface](https://goerli.etherscan.io/address/0x391805d58Fc27280Ed3b6469C1350b02A872cB2d#readContract)



