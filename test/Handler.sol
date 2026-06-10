// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LendingPool.sol";
import "../src/MockDex.sol";
import "../src/MockToken.sol";

contract Handler is Test {
    LendingPool public pool;
    MockDex public dex;
    MockToken public tokenA;
    MockToken public tokenB;

    address public user = address(0x1337);

    constructor(
        LendingPool _pool,
        MockDex _dex,
        MockToken _tokenA,
        MockToken _tokenB
    ) {
        pool = _pool;
        dex = _dex;
        tokenA = _tokenA;
        tokenB = _tokenB;

        tokenA.mint(user, 1_000_000e18);
        tokenB.mint(user, 1_000_000e18);

        vm.startPrank(user);
        tokenA.approve(address(pool), type(uint256).max);
        tokenB.approve(address(pool), type(uint256).max);
        tokenA.approve(address(dex), type(uint256).max);
        tokenB.approve(address(dex), type(uint256).max);
        vm.stopPrank();
    }

    function deposit(uint256 amount) public {
        amount = bound(amount, 1e18, 1000e18);
        vm.prank(user);
        pool.deposit(amount);
    }

    function borrow(uint256 amount) public {
        amount = bound(amount, 1e18, 5000e18);
        vm.prank(user);
        try pool.borrow(amount) {} catch {}
    }

    function swapAforB(uint256 amount) public {
        amount = bound(amount, 1e18, 50_000e18);
        vm.prank(user);
        try dex.swap(address(tokenA), amount) {} catch {}
    }

    function swapBforA(uint256 amount) public {
        amount = bound(amount, 1e18, 50_000e18);
        vm.prank(user);
        try dex.swap(address(tokenB), amount) {} catch {}
    }
}