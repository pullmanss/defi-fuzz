// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecurePriceOracle {
    uint256 private price;
    address public owner;

    constructor(uint256 _initialPrice) {
        price = _initialPrice;
        owner = msg.sender;
    }

    // Возвращает стабильную цену, защищенную от спотовых манипуляций
    function getPrice() external view returns (uint256) {
        return price;
    }

    // Обновление цены доверенным источником
    function updatePrice(uint256 _newPrice) external {
        require(msg.sender == owner, "Only owner");
        price = _newPrice;
    }
}