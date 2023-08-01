// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

interface IPortfolioState {
    /// @notice Current semantic version of the Portfolio smart contract.
    function VERSION() external pure returns (string memory);

    /// @notice Wrapped Ether address initialized on creating the Portfolio.
    function WETH() external view returns (address);

    /// @notice Contract for storing canonical Portfolio deployments.
    function REGISTRY() external view returns (address);

    /// @notice Contract for rendering position tokens.
    function POSITION_RENDERER() external view returns (address);

    /// @notice Default strategy contract used in pool creation.
    function DEFAULT_STRATEGY() external view returns (address);

    /// @notice Proportion of swap fee allocated to the Registry controller.
    function protocolFee() external view returns (uint256);

    /// @notice Incremented when a new pair of tokens is made and stored in the `pairs` mapping.
    function getPairNonce() external view returns (uint24);

    /// @notice Incremented when a pool is created.
    function getPoolNonce(uint24 pairNonce) external view returns (uint32);

    /**
     * @notice
     * Get the id of the stored pair of two tokens, if it exists.
     *
     * @dev
     * Reverse lookup to find the `pairId` of a given `asset` and `quote`.
     *
     * note
     * Order matters! There can be two pairs for every two tokens.
     */
    function getPairId(
        address asset,
        address quote
    ) external view returns (uint24 pairId);

    /// @dev Tracks the amount of protocol fees collected for a given `token`.
    function protocolFees(address token) external view returns (uint256);

    /// @dev Data structure of the state that holds token pair information. All immutable.
    function pairs(uint24 pairId)
        external
        view
        returns (
            address tokenAsset,
            uint8 decimalsAsset,
            address tokenQuote,
            uint8 decimalsQuote
        );

    /// @dev Data structure of the state of pools. Only controller is immutable.
    function pools(uint64 poolId)
        external
        view
        returns (
            uint128 virtualX,
            uint128 virtualY,
            uint128 liquidity,
            uint32 lastTimestamp,
            uint16 feeBasisPoints,
            uint16 priorityFeeBasisPoints,
            address controller,
            address strategy
        );
}
