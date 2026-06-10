// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MockDex.sol";

contract PriceOracle {
    MockDex public dex;

    constructor(address _dex) {
        dex = MockDex(_dex);
    }

    function getPrice() external view returns (uint256) {
        (uint256 reserveA, uint256 reserveB) = dex.getReserves();
        require(reserveA > 0, "Empty reserves");
        return (reserveB * 1e18) / reserveA;
    }
}