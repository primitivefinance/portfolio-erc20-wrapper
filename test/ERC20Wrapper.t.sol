// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "portfolio/interfaces/IPortfolio.sol";
import { PortfolioConfig } from "portfolio/strategies/NormalStrategyLib.sol";
import { BURNED_LIQUIDITY } from "portfolio/libraries/PoolLib.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "../src/WrapperFactory.sol";

contract ERC20WrapperTest is Test, ERC1155TokenReceiver {
    // We're using a version of Portfolio deployed on Sepolia Testnet
    IPortfolio portfolio =
        IPortfolio(0x3DedE8F8ac60cAe1f7AA76a92e91ED3ca38ba860);
    WrapperFactory public factory;

    MockERC20 asset;
    MockERC20 quote;

    uint24 pairId;
    uint64 poolId;

    ERC20Wrapper wrapper;

    function setUp() public {
        vm.createSelectFork(
            "https://eth-sepolia.g.alchemy.com/v2/0KtVQbIhpSOMzTrvCdt3XrgJtzknnkVB"
        );
        factory = new WrapperFactory(address(portfolio));

        asset = new MockERC20("Asset", "ASSET", 18);
        quote = new MockERC20("Quote", "QUOTE", 18);

        pairId = portfolio.createPair(address(asset), address(quote));

        poolId = portfolio.createPool(
            pairId,
            1,
            1,
            100,
            0,
            address(0),
            address(0),
            abi.encode(
                PortfolioConfig(
                    100,
                    100,
                    uint32(100) * 1 days,
                    uint32(block.timestamp),
                    true
                )
            )
        );

        asset.mint(address(this), 1000 ether);
        quote.mint(address(this), 1000 ether);

        asset.approve(address(portfolio), type(uint256).max);
        quote.approve(address(portfolio), type(uint256).max);

        wrapper = ERC20Wrapper(factory.deploy(poolId));
    }
}
