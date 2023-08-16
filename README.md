# Portfolio ERC20 Wrapper

Wrap Portfolio liquidity pool tokens into ERC20!

## Overview

Portfolio positions are represented as ERC1155 tokens, this wrapper allows you to convert one or multiple of these tokens into a single ERC20 token.

## How does it work?

Wrapped tokens are deployed by calling the `deploy()` function of the factory contract and passing the following parameters:

| Parameter | Description |
|---|---|
| name | Name of the ERC20 token |
| symbol | Symbol of the ERC20 token |
| poolIds | Array of pool ids to wrap |

Please note that the factory contract is linked to a specific Portfolio contract, so the pool ids must exist in that specific contract. You can check the address of the Portfolio contract in the factory contract by calling `PORTFOLIO()`.

## Current deployments

| Network | Address |
|---|---|
| Sepolia | [0xDccA88Cd8eEA8d5ff81cC7a2382B865240668444](https://sepolia.etherscan.io/address/0xDccA88Cd8eEA8d5ff81cC7a2382B865240668444) |
