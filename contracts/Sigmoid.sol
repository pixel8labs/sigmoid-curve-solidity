// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BytesLib.sol";

library Sigmoid {
    bytes constant sigmoidValues = hex"00172a8100195e0d001bca27001e74550021629900249b8200282633002c0a6f003050a1003501e9003a2825003fcdfc0045fee5004cc7300054340c005c538c006534a4006ee72c00797bd7008504270091925b009f395600ae0c8000be1f9700cf867b00e254f300f69e5a010c75490123eb32013d0ff10157f14f01749a7c0193138a01b360dc01d5829f01f97447021f2c1c02469adb026fab6f029a42d502c6401d02f37c9b0321cc480350fe4f0380ddc303b1328303e1c2380412516d0442a4ac047281a504a1b04504cffbae04fd331e05292aa50553bbae057cc56505a42cdd05c9dd1d05edc6fb060fe0d506302635064e975c066b38be0686127a069f2fce06b69e8d06cc6e9a06e0b16e06f379a50704da9f0714e8200723b60a0731581b073de1b8074965c10753f673075da54d076682fc076e9f560776094b077cceeb0782fd5f0788a0f5078dc520079274830796b8fa079a9ba0079e24de07a15c7507a4498407a6f29807a95db207ab905407ad8f8807af5fea07b105af07b284b207b3e07507b51c2b07b63ac007b73edc07b82aec07b9012307b9c38207ba73de07bb13df07bba50607bc28b207bca02307bd0c7b07bd6ebf07bdc7df07be18b507be620407bea48007bee0cb07bf177807bf490e07bf760407bf9eca07bfc3c307bfe54907c003b007c01f4007c0383f07c04ee807c0637507c0761707c086fc07c0964d07c0a43107c0b0c907c0bc3407c0c68e07c0cff107c0d87407c0e02b07c0e72a07c0ed8207c0f34207c0f87907c0fd3307c1017d07c1056007c108e607c10c1807c10efd07c1119d07c113ff07c1162807c1181d07c119e307c11b7f07c11cf407c11e4707c11f7a07c1209007c1218d07c1227107c1234107c123fd07c124a707c1254207c125ce07c1264d07c126c007c1272907bfcb90";
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
