// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

import "solmate/tokens/ERC20.sol";
import "solmate/tokens/ERC1155.sol";

contract ERC20Wrapper is ERC20, ERC1155TokenReceiver {
    address immutable portfolio;
    uint64 immutable poolId;

    constructor(
        address portfolio_,
        uint64 poolId_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_, 18) {
        portfolio = portfolio_;
        poolId = poolId_;
    }

    function mint(address to, uint256 amount) external {
        ERC1155(portfolio).safeTransferFrom(
            msg.sender, address(this), poolId, amount, ""
        );

        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external {
        _burn(msg.sender, amount);

        ERC1155(portfolio).safeTransferFrom(
            address(this), to, poolId, amount, ""
        );
    }
}
