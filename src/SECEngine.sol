// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {decentralizeStableCoin} from "src/DecentralizeStableCoin.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title DSCEngine
/// @author Zyrrow
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

contract DSCEngine is ReentrancyGuard {
    /////////////////////
    /// Errors     /////
    ///////////////////

    error DSCEngine_needTobeGreaterThanZero();
    error DSCEngine_TokenAddressesAndPricefeedAddressMustBeSameLenght();
    error DSCEngine_NotAllowedToken();
    error DSCEngine_TransferFromFailed();
    /////////////////////////
    /// State Variable /////
    ///////////////////////

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    mapping(address => address) private s_PriceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDSCcMinted) private s_DSCMinted;
    address[] private s_collateralToken;


    decentralizeStableCoin private immutable i_DSC;
    /////////////////////
    /// Event  /////////
    ///////////////////

    event CollateralDeposit(address indexed user, address indexed token, uint256 indexed amount);


    /////////////////////
    /// Modifiers   ////
    ///////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount  <= 0) {
            revert DSCEngine_needTobeGreaterThanZero();
        }
        _;
    }
    modifier isAllowedToken(address token) {
        if (s_PriceFeeds[token] == address(0)) {
            revert DSCEngine_NotAllowedToken();
        }
        _;
    }

    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddress,
        address DSCAddress
    ) {
        // EUR pricefeed
        if (tokenAddresses.length != priceFeedAddress.length) {
            revert DSCEngine_TokenAddressesAndPricefeedAddressMustBeSameLenght();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_PriceFeeds[tokenAddresses[i]] = priceFeedAddress[i];
            s_collateralToken.push(tokenAddresses[i]);
        }
        i_DSC = decentralizeStableCoin(DSCAddress);
    }

    





    ////////////////////////////
    /// External Functions ////
    //////////////////////////

    function depositCollateralAndMintDSC( address tokenCollateralAddress,uint256 amountCollateral ) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant {
        ///@param tokenCollateralAddress The address of the token to deposit as collateral
        ///@param amountCollateral The amount of collateral to deposit

        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposit(msg.sender, tokenCollateralAddress, amountCollateral);
       bool success =  IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
       if(!success) {
        revert DSCEngine_TransferFromFailed();
       }
    }

    function redeemCollateralForDSC() external {}

    function redeemCollateral() external {}

    /// @notice Follows  CEI
    /// @param amountDSCToMint The amount of decentralized stablecoin to mint
    /// @notice they must have more collateral value than the minimum threshold
   
    function mintDSC(uint256 amountDSCToMint) external  moreThanZero(amountDSCToMint) nonReentrant{
        s_DSCMinted[msg.sender] += amountDSCToMint;
        _revertIfHealthFactorIsBroken(msg.sender);

    }
    function burnDSC() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    ///////////////////////////////////////////
    /// Private & internal View Functions ////
    /////////////////////////////////////////

    
    function _getAccountInformation(address user) private view returns(uint256 totalDSCMinted, uint256 collateralValueInEuro) {
        totalDSCMinted = s_DSCMinted[user];
        collateralValueInEuro = getAccountCollateralValue(user);
    }

    /// @notice How close to liquidation a user is . If a user goes below 1 they can get liquidated

    function _healthFactor(address user) private view returns(uint256){
        // 1. total DSC minted
        // 2. total collateral Value
        (uint256 totalDSCMinted, uint256 collateralValueInEuro) = _getAccountInformation(user);
    }
    function _revertIfHealthFactorIsBroken(address user) internal view {
        // 1. check HealthFactor(do they have enough collateral ?)
        // 2. Revert If they don't
    }


    //////////////////////////////////////////
    /// Public & external View Functions ////
    ////////////////////////////////////////
    function  getAccountCollateralValue(address user) public view returns(uint256 totalCollateralValueInUsd) {
        for (uint256 i = 0; i < s_collateralToken.length; i++) {
            address token = s_collateralToken[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }
    function getUsdValue(address token, uint256 amount) public view returns(uint256){
        AggregatorV3Interface pricefeed = AggregatorV3Interface(s_PriceFeeds[token]);
        (,int256 price,,,) = pricefeed.latestRoundData();

        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}
