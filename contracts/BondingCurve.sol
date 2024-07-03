// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Sigmoid } from "./Sigmoid.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/utils/math/SafeCast.sol";

contract BondingCurve is ERC20 {
    using SafeCast for uint256;

    constructor() ERC20("Kumpool Token", "KUM") {}

    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }

    function getDecimals() public view returns (uint256) {
        return 10**decimals();
    }

    function issueTokens(uint256 _fiatValue) public returns (uint256)
    {
		// Calculate mint amount based on deposit (based on dollar value)
        uint256 amount = Sigmoid.calculateCurvedMintReturn(_fiatValue,getDecimals(), getTotalSupply());
        // Mint KUM token from contract
        _mint(msg.sender, amount);//IKUM.mint(msg.sender, amount);
        // Emit event successful mint
        //emit CurvedMint(msg.sender, kum_amount, _deposit, tx.hash);
        return amount;
    }

    function redeemTokens(uint256 _fiatValue) public returns (uint256)
    {
		// Calculate burn amount based on requested amount (based on dollar value)
        uint256 amount = Sigmoid.calculateCurvedBurnReturn(_fiatValue,getDecimals(), getTotalSupply());
        // Burn KUM token from contract
        _burn(msg.sender, amount);//IKUM.burn(msg.sender, _amount);
        // Emit event successful burn
        //emit CurvedBurn(msg.sender, kum_amount, reimbursement, tx.hash);
        return amount; // KUM token
    }
}