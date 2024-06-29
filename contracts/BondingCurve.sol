// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Sigmoid } from "./Sigmoid.sol";
import { SigmoidV2 } from "./SigmoidV2.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/utils/math/SafeCast.sol";

contract BondingCurve is ERC20 {
    uint32 inflectionPoint; // 1500; default value
    uint128 inflectionPrice; // 102500000000000000; default value
    uint256 price;
    using SafeCast for uint256;

    constructor(uint32 _inflectionPoint, uint128 _inflectionPrice) ERC20("Kumpool Token", "KUM") {
        inflectionPoint = _inflectionPoint;
        inflectionPrice = _inflectionPrice;
    }

    function mint(uint256 quantity) public  {
        uint256 avg_price = Sigmoid.sigmoid2Sum(inflectionPoint, inflectionPrice, totalSupply(), quantity);
        _mint(msg.sender, quantity);
        price = avg_price;
    }

    function burn(uint256 quantity) public returns (uint256) {
        uint256 avg_price = Sigmoid.sigmoid2Sum(inflectionPoint, inflectionPrice, totalSupply(), quantity);
        _burn(msg.sender, quantity);
        price = avg_price;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }

    function getSigmoidValue(uint index) public view returns (uint256) {
        return SigmoidV2.getSigmoidValue(index);
    }
}
