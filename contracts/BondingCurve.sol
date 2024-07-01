// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Sigmoid } from "./Sigmoid.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/utils/math/SafeCast.sol";

contract BondingCurve is ERC20 {
    using SafeCast for uint256;

    constructor() ERC20("Kumpool Token", "KUM") {}

    function getSigmoidValue(uint index) public view returns (uint256) {
        return Sigmoid.getSigmoidValue(index);
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    function getDecimals() public view returns (uint256) {
        return 10**decimals();
    }

    function getNextPricePerToken(uint256 _totalSupply) public view returns (uint256) {
        uint256 decimals = 10**decimals();
        uint256 index = _totalSupply / decimals; //perform integer div. to get the lower bound index
        uint256 nextTokenPrice;
        if (index > 167) {
            nextTokenPrice = getSigmoidValue(167); //saturated price value
        }
        else {
            nextTokenPrice = (decimals*(index+1) - _totalSupply)*getSigmoidValue(index+1);
            nextTokenPrice = nextTokenPrice / decimals;
        }

        return nextTokenPrice;
        
    }

    function issueTokens(uint256 fiatAmount) public returns (uint256) {
        require(fiatAmount > 0, "Insufficient fiat amount for token issuance");
        uint256 decimals = 10**decimals();
        uint256 mint_amount = 0;
        uint256 remainingFiat = fiatAmount; 
        uint256 index = totalSupply() / decimals; //perform integer division
        uint256 token_supply = totalSupply();
        while (remainingFiat > 0) {
            if (index >= 167) //at price saturation range
            {
                uint256 pricePerToken = getSigmoidValue(167);
                uint256 fullTokens = remainingFiat / pricePerToken;
                mint_amount += fullTokens * decimals;
                remainingFiat -= fullTokens * pricePerToken;

                // Add any fractional part
                mint_amount += remainingFiat * decimals / pricePerToken;
                remainingFiat = 0;
                break; //exit loop
            }
            else
            { //index = 0 - 167, s-shaped curve
                uint256 nextPricePerToken = getNextPricePerToken(token_supply);
                if (remainingFiat >= nextPricePerToken) {
                    mint_amount += (index+1)*decimals - token_supply; // Equivalent to 1 unit of token with 6 decimals
                    remainingFiat -= nextPricePerToken;
                    token_supply = (index+1)*decimals; // go to next integer range
                } else {
                    mint_amount += remainingFiat * decimals / nextPricePerToken;
                    remainingFiat = 0;
                    break; //exit loop
                }
            }
            index++;
        }
        _mint(msg.sender, mint_amount);
        return mint_amount;
    }
}