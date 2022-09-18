// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "ens-contracts/wrapper/NameWrapper.sol";
import "ens-contracts/registry/ENS.sol";
import "ens-contracts/ethregistrar/IBaseRegistrar.sol";
import "test/mocks/MockMetadataService.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() external {
        vm.startBroadcast();
        ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        MockMetadataService metadata = new MockMetadataService();
        IBaseRegistrar registrar = IBaseRegistrar(0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85);
        NameWrapper nw = new NameWrapper(ens, registrar, metadata);
        vm.stopBroadcast();

    }
}