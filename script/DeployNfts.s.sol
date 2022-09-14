// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "test/mocks/Mock721.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() external {
        vm.startBroadcast();

        Mock721 nft1 = new Mock721();
        Mock721 nft2 = new Mock721();
        Mock721 nft3 = new Mock721();
        Mock721 nft4 = new Mock721();
        Mock721 nft5 = new Mock721();

        vm.stopBroadcast();
    }
}
