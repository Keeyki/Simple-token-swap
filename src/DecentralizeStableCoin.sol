// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
/// @title decentralizeStableCoin
/// @author Keeyki
/// Collateral : exogenous (ETH & BTC)
/// Minting: Algorithmic
/// Relative Stability: egged to EUR
/// @notice This is the contract meant to be governed by DSCEngine.
/// This contract is just the ERC20 implementation of our stable coin system

contract decentralizeStableCoin is ERC20Burnable, Ownable {
    error CoinMustBeMortThanZero();
    error BurnAmountExceedsBalance();
    error NotZeroAddress();

    constructor() ERC20("StableEuroCoin", "SEC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert CoinMustBeMortThanZero();
        }

        if (balance < _amount) {
            revert BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert NotZeroAddress();
        }
        if (_amount <= 0) {
            revert CoinMustBeMortThanZero();
        }
        _mint(_to, _amount);
        return true;
    }
}
