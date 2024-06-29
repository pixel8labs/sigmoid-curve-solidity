// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SigmoidV2 } from "./SigmoidV2.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/utils/math/SafeCast.sol";

contract BondingCurveV2 is ERC20 {

    constructor() ERC20("Kumpool Token", "KUM") {
    }

    function getSigmoidValue(uint index) public view returns (uint256) {
        return SigmoidV2.getSigmoidValue(index);
    }
}
