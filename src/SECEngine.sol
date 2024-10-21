// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {decentralizeStableCoin} from "src/DecentralizeStableCoin.sol";
import {ReetrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
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

contract DSCEngine is ReetrancyGuard {
    /////////////////////
    /// Errors     /////
    ///////////////////

    error SECEngine_needTobeGreaterThanZero();
    error SECEngine_TokenAddressesAndPricefeedAddressMustBeSameLenght();
    error SECEngie_NotAllowedToken();

    /////////////////////////
    /// State Variable /////
    ///////////////////////

    mapping(address => address) private s_PriceFeeds;
    mapping(address user => mapping(address token => uint256 amount));
    decentralizeStableCoin private immutable i_sec;

    /////////////////////
    /// Modifiers   ////
    ///////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount < 0) {
            revert SECEngine_needTobeGreaterThanZero();
        }
        _;
    }
    modifier isAllowedToken(address token) {
        if (s_PriceFeeds[token] == address(0)) {
            revert SECEngie_NotAllowedToken();
        }
    }

    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddress,
        address secAddress
    ) {
        // EUR pricefeed
        if (tokenAddresses.length != priceFeedAddress.length) {
            revert SECEngine_TokenAddressesAndPricefeedAddressMustBeSameLenght();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_PriceFeeds[tokenAddresses[i]] = priceFeedAddress[i];
        }
        i_sec = decentralizeStableCoin(secAddress);
    }

    /////////////////////
    /// Functions   ////
    ///////////////////

    ////////////////////////////
    /// External Functions ////
    //////////////////////////

    function depositCollateralAndMintSEC(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReetrant
    {
        ///@param tokenCollateralAddress The address of the token to deposit as collateral
        ///@param amountCollateral The amount of collateral to deposit

        s_collateralDeposited[msg.sender[]]
    }

    function redeemCollateralForSEC() external {}

    function redeemCollateral() external {}

    function burnSEC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
