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

    function redeemTokens(uint256 fiatAmount) public returns (uint256) {
        require(fiatAmount > 0, "Insufficient fiat amount for token redemption");
        uint256 decimals = 10**decimals();
        uint256 burn_amount = 0;
        uint256 remainingFiat = fiatAmount; 
        uint256 prev_index = totalSupply() / decimals; //perform integer division
        if (prev_index * decimals == totalSupply() && prev_index >= 1)
        {
            prev_index = prev_index - 1; //go to prev index
        }
        uint256 token_supply = totalSupply();
        while (remainingFiat > 0) {
            if (prev_index < 1) //at price saturation range
            {
                uint256 pricePerToken = getSigmoidValue(0);
                uint256 fullTokens = remainingFiat / pricePerToken;
                burn_amount += fullTokens * decimals;
                remainingFiat -= fullTokens * pricePerToken;

                // Add any fractional part
                burn_amount += remainingFiat * decimals / pricePerToken;
                remainingFiat = 0;
                break; //exit loop
            }
            else {
                uint256 prevPricePerToken = getPrevPricePerToken(token_supply);
                if (remainingFiat >= prevPricePerToken) {
                    burn_amount += token_supply - prev_index*decimals; // Equivalent to 1 unit of token with 6 decimals
                    remainingFiat -= prevPricePerToken;
                    token_supply = prev_index*decimals; // go to prev. integer range
                } else {
                    burn_amount += remainingFiat * decimals / prevPricePerToken;
                    remainingFiat = 0;
                    break; //exit loop
                }
            }
            prev_index--;
        }
        //HERE: Needs to add a check whether user has enough balance of KUM Token > burn_amount
        //balance[msg.sender] > burn_amount
        _burn(msg.sender, burn_amount);
        return burn_amount;
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

    function getPrevPricePerToken(uint256 _totalSupply) public view returns (uint256) {
        uint256 decimals = 10**decimals();
        uint256 prev_index = _totalSupply / decimals; //need to round up i.e ceil function
        uint256 prevTokenPrice;
        if (prev_index * decimals == _totalSupply && prev_index >= 1)
        {
            prev_index = prev_index - 1; //go to prev index
        }
        //compute the price using linear interpolation
        if (prev_index < 1) {
            prevTokenPrice = getSigmoidValue(0); //min price
        }
        else {
            prevTokenPrice = (_totalSupply - prev_index*decimals)*getSigmoidValue(prev_index);
            prevTokenPrice = prevTokenPrice / decimals;
        }
        return prevTokenPrice;  
    }
}