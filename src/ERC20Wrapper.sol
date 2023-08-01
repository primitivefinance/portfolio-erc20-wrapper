// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

import "solmate/tokens/ERC20.sol";
import "solmate/tokens/ERC1155.sol";

contract ERC20Wrapper is ERC20, ERC1155TokenReceiver {
    address immutable PORTFOLIO;
    uint64 immutable POOL_ID;

    constructor(
        address portfolio_,
        uint64 poolId_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_, 18) {
        PORTFOLIO = portfolio_;
        POOL_ID = poolId_;
    }

    function mint(address to, uint256 amount) external {
        ERC1155(PORTFOLIO).safeTransferFrom(
            msg.sender, address(this), POOL_ID, amount, ""
        );

        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external {
        _burn(msg.sender, amount);

        ERC1155(PORTFOLIO).safeTransferFrom(
            address(this), to, POOL_ID, amount, ""
        );
    }
}
