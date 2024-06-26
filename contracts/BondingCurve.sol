// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Sigmoid } from "./Sigmoid.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/utils/math/SafeCast.sol";

contract BondingCurve is ERC20 {
    uint32 inflectionPoint;
    uint128 inflectionPrice;
    uint256 price;
    using SafeCast for uint256;

    constructor(uint32 _inflectionPoint, uint128 _inflectionPrice) ERC20("Kumpool Token", "KUM") {
        inflectionPoint = _inflectionPoint;
        inflectionPrice = _inflectionPrice;
    }

    function mint(uint32 quantity) public  {
        uint256 avg_price = Sigmoid.sigmoid2Sum(inflectionPoint, inflectionPrice, totalSupply(), quantity);
        _mint(msg.sender, quantity);
        price = avg_price;
    }

    function burn(uint32 quantity) public returns (uint256) {
        uint256 avg_price = Sigmoid.sigmoid2Sum(inflectionPoint, inflectionPrice, totalSupply(), quantity);
        _burn(msg.sender, quantity);
        price = avg_price;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }
}
