// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

import { IPortfolioState } from "portfolio/interfaces/IPortfolio.sol";
import { PoolIdLib, PoolId } from "portfolio/libraries/PoolLib.sol";

import "./ERC20Wrapper.sol";

contract WrapperFactory {
    event Deploy(
        address indexed portfolio,
        uint24 indexed pairId,
        uint64 poolId,
        address tokenAsset,
        address tokenQuote,
        address wrapper
    );

    address immutable PORTFOLIO;

    constructor(address portfolio_) {
        PORTFOLIO = portfolio_;
    }

    function deploy(uint64 poolId) external returns (address) {
        uint24 pairId = PoolIdLib.pairId(PoolId.wrap(poolId));

        (address tokenAsset,, address tokenQuote,) =
            IPortfolioState(PORTFOLIO).pairs(pairId);

        string memory assetName = ERC20(tokenAsset).name();
        string memory assetSymbol = ERC20(tokenAsset).symbol();
        string memory quoteName = ERC20(tokenQuote).name();
        string memory quoteSymbol = ERC20(tokenQuote).symbol();

        string memory name =
            string.concat("Wrapped Portfolio ", assetName, " - ", quoteName);

        string memory symbol =
            string.concat("wP", assetSymbol, "-", quoteSymbol);

        address wrapper = address(
            new ERC20Wrapper(
                PORTFOLIO,
                poolId,
                name,
                symbol
            )
        );

        emit Deploy(PORTFOLIO, pairId, poolId, tokenAsset, tokenQuote, wrapper);

        return wrapper;
    }
}
