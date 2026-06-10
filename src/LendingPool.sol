// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOracle {
    function getPrice() external view returns (uint256);
}

contract LendingPool {
    IERC20 public collateralToken;
    IERC20 public borrowToken;
    IOracle public oracle;

    mapping(address => uint256) public collateral;
    mapping(address => uint256) public borrowed;

    uint256 public constant LTV = 80;

    constructor(address _collateral, address _borrow, address _oracle) {
        collateralToken = IERC20(_collateral);
        borrowToken = IERC20(_borrow);
        oracle = IOracle(_oracle);
    }

    function deposit(uint256 amount) external {
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateral[msg.sender] += amount;
    }

    function borrow(uint256 amount) external {
        borrowed[msg.sender] += amount;
        require(isSolvent(msg.sender), "Insolvent: borrowing limit exceeded");
        borrowToken.transfer(msg.sender, amount);
    }

    function isSolvent(address user) public view returns (bool) {
        if (borrowed[user] == 0) return true;
        uint256 price = oracle.getPrice();

        uint256 collateralValueInB = (collateral[user] * price) / 1e18;
        uint256 maxBorrow = (collateralValueInB * LTV) / 100;

        return borrowed[user] <= maxBorrow;
    }
}
