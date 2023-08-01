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
        IPortfolio(0x3DedE8F8ac60cAe1f7AA76a92e91ED3ca38ba860);
    WrapperFactory public factory;

    MockERC20 asset;
    MockERC20 quote;

    uint24 pairId;
    uint64 poolId;

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
    }

    function test_deploy_returns_wrapper_address() public {
        address wrapper = factory.deploy(poolId);
        assertEq(wrapper, predictAddress());
    }

    event Deploy(
        address indexed portfolio,
        uint24 indexed pairId,
        uint64 poolId,
        address tokenAsset,
        address tokenQuote,
        address wrapper
    );

    function test_deploy_emits_Deploy() public {
        vm.expectEmit();

        emit Deploy(
            address(portfolio),
            pairId,
            poolId,
            address(asset),
            address(quote),
            predictAddress()
        );

        factory.deploy(poolId);
    }

    function test_deploy_revert_on_invalid_poolId() public {
        vm.expectRevert();
        factory.deploy(5352);
    }

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
}
