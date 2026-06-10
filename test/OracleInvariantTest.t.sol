// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MockToken.sol";
import "../src/MockDex.sol";
import "../src/SecurePriceOracle.sol";
import "../src/LendingPool.sol";
import "./Handler.sol";

contract OracleInvariantTest is Test {
    MockToken public tokenA;
    MockToken public tokenB;
    MockDex public dex;
    SecurePriceOracle public oracle;
    LendingPool public pool;
    Handler public handler;

    uint256 public constant REAL_PRICE = 1e18;

    function setUp() public {
        tokenA = new MockToken("Token A", "TKNA");
        tokenB = new MockToken("Token B", "TKNB");

        dex = new MockDex(address(tokenA), address(tokenB));

        tokenA.mint(address(this), 100_000e18);
        tokenB.mint(address(this), 100_000e18);
        tokenA.approve(address(dex), type(uint256).max);
        tokenB.approve(address(dex), type(uint256).max);
        dex.addLiquidity(100_000e18, 100_000e18);

        oracle = new SecurePriceOracle(REAL_PRICE);
        pool = new LendingPool(address(tokenA), address(tokenB), address(oracle));

        tokenB.mint(address(pool), 500_000e18);

        handler = new Handler(pool, dex, tokenA, tokenB);

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.borrow.selector;
        selectors[2] = Handler.swapAforB.selector;
        selectors[3] = Handler.swapBforA.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
        targetContract(address(handler));
    }

    function invariant_no_bad_debt() public {
        address user = handler.user();
        uint256 userCollateral = pool.collateral(user);
        uint256 userBorrowed = pool.borrowed(user);

        if (userCollateral > 0) {
            uint256 realCollateralValue = (userCollateral * REAL_PRICE) / 1e18;
            uint256 realMaxBorrow = (realCollateralValue * pool.LTV()) / 100;

            assertLe(userBorrowed, realMaxBorrow, "Oracle manipulated: Bad debt detected!");
        }
    }
}
