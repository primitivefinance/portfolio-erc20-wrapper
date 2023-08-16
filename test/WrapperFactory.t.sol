// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "portfolio/interfaces/IPortfolio.sol";
import { PortfolioConfig } from "portfolio/strategies/NormalStrategyLib.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "../src/WrapperFactory.sol";

contract WrapperFactoryTest is Test, ERC1155TokenReceiver {
    // We're using a version of Portfolio deployed on Sepolia Testnet
    IPortfolio portfolio =
        IPortfolio(0x00fCd05052Bc1ADA7a4a4509A8876fC4DAa43fB6);
    WrapperFactory public factory;

    MockERC20 asset;
    MockERC20 quote;

    uint24 pairId;
    uint64[] poolIds;

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
    }

    function test_deploy_returns_wrapper_address() public {
        address wrapper = factory.deploy("Wrapped Pools", "wPools", poolIds);
        assertEq(wrapper, computeCreateAddress(address(factory), 1));
    }

    event Deploy(
        address indexed portfolio,
        string name,
        string symbol,
        uint64[] poolIds,
        address wrapper
    );

    function test_deploy_emits_Deploy() public {
        vm.expectEmit();

        emit Deploy(
            address(portfolio),
            "Wrapped Pools",
            "wPools",
            poolIds,
            computeCreateAddress(address(factory), 1)
        );

        factory.deploy("Wrapped Pools", "wPools", poolIds);
    }

    /*
    function test_deploy_revert_on_invalid_poolId() public {
        vm.expectRevert();
        uint64[] memory badPoolIds = new uint64[](1);
        badPoolIds[0] = 3535;
        factory.deploy("", "", badPoolIds);
    }
    */

    /*
    function predictAddress() public view returns (address) {
        string memory name =
            string.concat("Wrapped Portfolio ", "Asset", " - ", "Quote");

        string memory symbol = string.concat("wP", "ASSET", "-", "QUOTE");

        bytes32 salt = keccak256(abi.encodePacked(asset, quote, poolId));
        return address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(factory),
                            salt,
                            keccak256(
                                abi.encodePacked(
                                    type(ERC20Wrapper).creationCode,
                                    abi.encode(
                                        address(portfolio), poolId, name, symbol
                                    )
                                )
                            )
                        )
                    )
                )
            )
        );
    }
    */
}
