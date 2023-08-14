// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

import { IPortfolioState } from "portfolio/interfaces/IPortfolio.sol";
import { PoolIdLib, PoolId } from "portfolio/libraries/PoolLib.sol";

import "./ERC20Wrapper.sol";

contract WrapperFactory {
    event Deploy(
        address indexed portfolio,
        string name,
        string symbol,
        uint64[] poolIds,
        address wrapper
    );

    address immutable PORTFOLIO;

    constructor(address portfolio_) {
        PORTFOLIO = portfolio_;
    }

    function deploy(
        string memory name,
        string memory symbol,
        uint64[] memory poolIds
    ) external returns (address) {
        address wrapper = address(
            new ERC20Wrapper(
                PORTFOLIO,
                poolIds,
                name,
                symbol
            )
        );

        emit Deploy(PORTFOLIO, name, symbol, poolIds, wrapper);

        return wrapper;
    }
}
