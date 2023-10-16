// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CoreFunctions} from "../contracts/utils/CoreFunctions.sol";
import {CoreFunctionHelper} from "../contracts/utils/CoreFunctionHelper.sol";
import {Main} from "../contracts/main/Main.sol";

import {Script, console2} from "forge-std/Script.sol";

contract Deploy is Script {

    CoreFunctions coreFunctions ;
    CoreFunctionHelper coreFunctionsHelper ;
    Main main ;


    function run() public{
        vm.broadcast();
        coreFunctions = new CoreFunctions();


        vm.broadcast();
        coreFunctionsHelper = new CoreFunctionHelper(address(coreFunctions));

        vm.broadcast();
        main = new Main(address(coreFunctionsHelper));

    }
}