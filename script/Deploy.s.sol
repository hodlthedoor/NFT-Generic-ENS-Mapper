// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "src/GenericEnsMapper.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() external {
        vm.startBroadcast();

        GenericEnsMapper mapper = new GenericEnsMapper();

        vm.stopBroadcast();
    }
}
