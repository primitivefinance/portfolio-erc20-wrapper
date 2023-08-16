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
        IPortfolio(0x00fCd05052Bc1ADA7a4a4509A8876fC4DAa43fB6);
    WrapperFactory public factory;

    MockERC20 asset;
    MockERC20 quote;

    uint24 pairId;
    uint64[] poolIds;

    ERC20Wrapper wrapper;

    function setUp() public {
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        factory = new WrapperFactory(address(portfolio));

        asset = new MockERC20("Asset", "ASSET", 18);
        quote = new MockERC20("Quote", "QUOTE", 18);

        pairId = portfolio.createPair(address(asset), address(quote));

        uint64 poolId = portfolio.createPool(
            pairId,
            1,
            1,
            100,
            0,
            address(0),
            address(0),
            abi.encode(
                PortfolioConfig(
                    1 ether,
                    100,
                    uint32(100) * 1 days,
                    uint32(block.timestamp),
                    true
                )
            )
        );

        poolIds.push(poolId);

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
                    2 ether,
                    100,
                    uint32(100) * 1 days,
                    uint32(block.timestamp),
                    true
                )
            )
        );

        poolIds.push(poolId);

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
                    3 ether,
                    100,
                    uint32(100) * 1 days,
                    uint32(block.timestamp),
                    true
                )
            )
        );

        poolIds.push(poolId);

        asset.mint(address(this), 1000 ether);
        quote.mint(address(this), 1000 ether);

        asset.approve(address(portfolio), type(uint256).max);
        quote.approve(address(portfolio), type(uint256).max);

        wrapper = ERC20Wrapper(factory.deploy("", "", poolIds));
    }

    function test_mint_updates_balances() public {
        uint256 liquidity = 999999999000000000;

        portfolio.allocate(
            false,
            address(this),
            poolIds[0],
            1000000000000000000,
            type(uint128).max,
            type(uint128).max
        );

        portfolio.allocate(
            false,
            address(this),
            poolIds[1],
            1000000000000000000,
            type(uint128).max,
            type(uint128).max
        );

        portfolio.allocate(
            false,
            address(this),
            poolIds[2],
            1000000000000000000,
            type(uint128).max,
            type(uint128).max
        );

        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(this), poolIds[0]),
            liquidity
        );
        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(this), poolIds[1]),
            liquidity
        );
        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(this), poolIds[2]),
            liquidity
        );

        console.log("Liquidity is OOK");

        ERC1155(address(portfolio)).setApprovalForAll(address(wrapper), true);
        wrapper.mint(address(this), liquidity);

        // The wrapper should hold the ERC1155 tokens
        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(wrapper), poolIds[0]),
            liquidity
        );
        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(wrapper), poolIds[1]),
            liquidity
        );
        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(wrapper), poolIds[2]),
            liquidity
        );

        // The sender should have no ERC1155 tokens left
        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(this), poolIds[0]), 0
        );
        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(this), poolIds[1]), 0
        );
        assertEq(
            ERC1155(address(portfolio)).balanceOf(address(this), poolIds[2]), 0
        );

        // The sender should now own the ERC20 tokens
        assertEq(wrapper.balanceOf(address(this)), liquidity);

        // The total supply should be updated
        assertEq(wrapper.totalSupply(), liquidity);
    }

    function test_burn_gives_back_tokens() public {
        uint256 liquidity = 1 ether;

        portfolio.allocate(
            false,
            address(this),
            poolIds[0],
            uint128(liquidity),
            type(uint128).max,
            type(uint128).max
        );

        portfolio.allocate(
            false,
            address(this),
            poolIds[1],
            uint128(liquidity),
            type(uint128).max,
            type(uint128).max
        );

        portfolio.allocate(
            false,
            address(this),
            poolIds[2],
            uint128(liquidity),
            type(uint128).max,
            type(uint128).max
        );

        liquidity = 999999999000000000;

        ERC1155(address(portfolio)).setApprovalForAll(address(wrapper), true);
        wrapper.mint(address(this), liquidity);
        wrapper.burn(address(this), liquidity);

        address[] memory holders = new address[](6);
        holders[0] = address(wrapper);
        holders[1] = address(wrapper);
        holders[2] = address(wrapper);
        holders[3] = address(this);
        holders[4] = address(this);
        holders[5] = address(this);

        uint256[] memory ids = new uint256[](6);
        ids[0] = poolIds[0];
        ids[1] = poolIds[1];
        ids[2] = poolIds[2];
        ids[3] = poolIds[0];
        ids[4] = poolIds[1];
        ids[5] = poolIds[2];

        uint256[] memory balances =
            ERC1155(address(portfolio)).balanceOfBatch(holders, ids);

        // The wrapper should send back the ERC1155 tokens
        assertEq(balances[0], 0);
        assertEq(balances[1], 0);
        assertEq(balances[2], 0);

        // The sender should have received the ERC1155 tokens
        assertEq(balances[3], liquidity);
        assertEq(balances[4], liquidity);
        assertEq(balances[5], liquidity);

        // The sender should now own NO ERC20 tokens
        assertEq(wrapper.balanceOf(address(this)), 0);

        // The total supply should be updated
        assertEq(wrapper.totalSupply(), 0);
    }
}
