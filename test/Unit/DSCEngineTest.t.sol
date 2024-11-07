// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
 
import {Test} from "lib/forge-std/src/Test.sol";
import {DeployDSC} from "script/DeployDSCEngine.s.sol";
import {DecentralizeStableCoin} from "src/DecentralizeStableCoin.sol";
import {DSCEngine} from "src/DSCEngine.sol";


contract DSCEngineTest is Test {
    DeployDSC deployer;
    DecentralizeStableCoin dsc;
    DSCEngine dsce;

    function setUp () public {
        deployer = new DeployDSC();
        (dsc,dsce) = deployer.run();
    }
}