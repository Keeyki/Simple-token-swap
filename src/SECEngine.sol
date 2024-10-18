// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title DSCEngine
/// @author Keeyki
/// The system is designed to be as minimal as possible, and have the token maintain a 1token = 1 euro peg.
/// This stablecoin has the properties:
///
/// -Exogenous Collateral
/// -Euro Pegged
/// -Algoritmically Stable
///
/// It is similar to DAI if DAI had no governance , no fees and was only backed by weth and WBTC

/// Our SEC should always be "ovecollateralized". At no point, should the value of all collateral <= the Euro backed value of all the DSC.
///@notice This contract is the core of the SEC System. It handles all the logic for mining and redeeming DSC tokens,as well as depositing and withdrawing collateral.
///@notice This contract is very loosely based on the MakerDAO DSS(DAI) system.

contract DSCEngine {
    /////////////////////
    /// Errors     /////
    ///////////////////

    error DSCEngine_needTobeGreaterThanZero();

    /////////////////////
    /// Modifiers   ////
    ///////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount < 0) {
            revert DSCEngine_needTobeGreaterThanZero();
        }
        _;
    }
    function depositCollateralAndMintSEC(
        address tokenCollateralAddress,
        uint256 amountCollateral
    ) external moreThanZero(amountCollateral) {
        ///@param tokenCollateralAddress The address of the token to deposit as collateral
        ///@param amountCollateral The amount of collateral to deposit
    }

    function redeemCollateralForSEC() external {}

    function redeemCollateral() external {}

    function burnSEC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
