// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BytesLib.sol";

library Sigmoid {
    bytes constant sigmoidValues = hex"000fe0d200115f030013047b0014d5260016d551001909b0001b7764001e2405002115aa002452f20027e30d002bcdc000301b740034d535003a04c0003fb4800045ef98004cc1dc005437d3005c5eaf00654441006ef6e9007985800084ff3800917378009ef1ab00ad890900bd485400ce3d8c00e0759500f3fbdb0108d9e9011f16f70136b780014fbcca016a24830185e85501a2fd9c01c1552601e0db0e020176bc02230b020245766402689381028c39a502b03d7b02d471d802f8a899031cb39203406573036392ab0386123903a7be5d03c8752d03e81907040690d50423c838043faf80045a3b95047365b2048b2b1e04a18cc704b68ed504ca383f04dc925804eda85e04fd8713050c3c5e0519d6f1052665fa0531f8e3053c9f14054667c8054f61e205579bd0055f23730566060c056c503605720dd805774a26057c0f9f0580681005845c9a0587f5b3058b3b35058e345b0590e7d505935bc6059595d305979b2b0599708a059b1a49059c9c5f059dfa6a059f37b905a0574e05a15be905a2480805a31df205a3dfb805a48f3905a52e2c05a5be1d05a6407405a6b67805a7215205a7820e05a7d9a005a828e705a870a905a8b19e05a8ec6905a921a005a951ca05a97d6105a9a4d505a9c88905a9e8da05aa061805aa208e05aa388105aa4e2d05aa61ca05aa738a05aa839905aa922105aa9f4805aaab2f05aab5f305aabfb205aac88305aad07e05aad7b605aade3e05aae42805aae98105aaee5805aaf2b905aaf6b005aafa4605aafd8505ab007405ab031c05ab058405ab07b105ab09a805ab0b7005ab0d0d05ab0e8205ab0fd405ab110605ab121a05ab131405ab13f705ab14c405ab157d05ab162505ab16bc05ab174605ab17c205ab183205ab189805ab18f405ab194805ab199305ab19d705ab1a1505ab1a4d";
    uint256 constant private maxIndex = 167; //price does not change at this range i.e reaches saturation
    function getSigmoidValue(uint index) internal pure returns (uint32) {
        if (index> maxIndex) {
            return BytesLib.toUint32(sigmoidValues, maxIndex* 4);
        }
        else {
            return BytesLib.toUint32(sigmoidValues, index* 4);
        }
    }

    function getNextPricePerToken(uint256 _totalSupply, uint256 decimals) internal pure returns (uint256) {
        uint256 index = _totalSupply / decimals; //perform integer div. to get the lower bound index
        uint256 nextTokenPrice;
        if (index > maxIndex) {
            nextTokenPrice = getSigmoidValue(maxIndex); //saturated price value
        }
        else {
            nextTokenPrice = (decimals*(index+1) - _totalSupply)*getSigmoidValue(index+1);
            nextTokenPrice = nextTokenPrice / decimals;
        }
        return nextTokenPrice;  
    }

    function getPrevPricePerToken(uint256 _totalSupply, uint256 decimals) internal pure returns (uint256) {
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

    function calculateCurvedMintReturn(uint256 fiatAmount, uint256 decimals, uint256 totalSupply) public pure returns (uint256) {
        require(fiatAmount > 0, "Insufficient fiat amount for token issuance");
        uint256 mint_amount = 0;
        uint256 remainingFiat = fiatAmount; 
        uint256 index = totalSupply / decimals; //perform integer division
        uint256 token_supply = totalSupply;
        while (remainingFiat > 0) {
            if (index >= maxIndex) //at price saturation range
            {
                uint256 pricePerToken = getSigmoidValue(maxIndex);
                uint256 fullTokens = remainingFiat / pricePerToken;
                mint_amount += fullTokens * decimals;
                remainingFiat -= fullTokens * pricePerToken;

                // Add any fractional part
                mint_amount += remainingFiat * decimals / pricePerToken;
                remainingFiat = 0;
                break; //exit loop
            }
            else
            { //index = 0 - Sigmoid.maxIndex, s-shaped curve
                uint256 nextPricePerToken = getNextPricePerToken(token_supply, decimals);
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
        return mint_amount;
    }

    function calculateCurvedBurnReturn(uint256 fiatAmount, uint256 decimals, uint256 totalSupply) public pure returns (uint256) {
        require(fiatAmount > 0, "Insufficient fiat amount for token redemption");
        uint256 burn_amount = 0;
        uint256 remainingFiat = fiatAmount; 
        uint256 prev_index = totalSupply / decimals; //perform integer division
        if (prev_index * decimals == totalSupply && prev_index >= 1)
        {
            prev_index = prev_index - 1; //go to prev index
        }
        uint256 token_supply = totalSupply;
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
                uint256 prevPricePerToken = getPrevPricePerToken(token_supply, decimals);
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
        return burn_amount;
    }
}
