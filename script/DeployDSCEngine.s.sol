// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {DecentralizeStableCoin} from "src/DecentralizeStableCoin.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSC is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;
    function run() external returns(DecentralizedStableCoin,DSCEngine) {
        HelperConfig helperConfig = new HelperConfig();
        tokenAddresses = [weth,wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) = config.activeNetworkConfig();
        vm.startBroadcast();
        DecentralizeStableCoin dsc = new DecentralizeStableCoin();
        DSCEngine dsce = new DSCEngine(tokenAddresses,priceFeedAddresses, address(dsc));
        dsc.transferOwnership(address(dsce));
        vm.stopBroadcast();
        return(dsc, dsce);
    }
}